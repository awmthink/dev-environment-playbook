#!/usr/bin/env python3
"""从 proxy.env 的两个出口变量渲染 mihomo config.yaml（幂等）。

- MIHOMO_SUB_URL   ：订阅连接（必填）
- MIHOMO_NODE_URLS ：自定义扩展节点，空格分隔的 http/socks5 代理 URL（可选；留空则渲染出不带自定义节点的配置）
- 节点入口 DNS：自动从 providers/sub.yaml（mihomo 订阅缓存，每日自动刷新）提取 dns 段的
  proxy-server-nameserver 继承——机场入口域名为 CNAME 链 + IP 轮转型，公共 DNS 拿到死 IP；
  sub.yaml 不存在时回退复用现有 config.yaml 里的 DoH（首次落地需 mihomo 拉取订阅后重跑一次）

用法：render.py [--restart]
  --restart 渲染后重启服务（Linux: systemd 用户服务；macOS: brew services）
依赖：~/.config/mihomo/config.example.yaml 模板（本仓库 configs/mihomo/config.example.yaml 的落地副本）
幂等：已有 config.yaml 的 API secret 会被复用，不重复生成。
"""
import ipaddress
import os
import re
import subprocess
import sys
import urllib.parse

MIHOMO_DIR = os.path.expanduser('~/.config/mihomo')
PROXY_ENV = os.path.expanduser('~/.config/shell/proxy.env')
TEMPLATE = os.path.join(MIHOMO_DIR, 'config.example.yaml')
TARGET = os.path.join(MIHOMO_DIR, 'config.yaml')
SUB_CACHE = os.path.join(MIHOMO_DIR, 'providers', 'sub.yaml')


def extract_nameservers(text):
    """提取 yaml 中 proxy-server-nameserver 的列表项（无关缩进层级），无则空列表。"""
    m = re.search(r'(?m)^\s*proxy-server-nameserver:\s*$', text)
    if not m:
        return []
    urls = []
    for line in text[m.end():].splitlines():
        if re.match(r'^\s+-\s', line):
            u = line.strip()[2:].strip().strip('"\'')
            if u:
                urls.append(u)
        elif line.strip():
            break
    return urls


def load_proxy_env():
    env = {}
    for line in open(PROXY_ENV):
        m = re.match(r'^([A-Z_]+)="(.*)"\s*$', line.strip())
        if m:
            env[m.group(1)] = m.group(2)
    return env


def existing_secret():
    try:
        return re.search(r'^secret:\s*"?([^"\s]+)"?', open(TARGET).read(), re.M).group(1)
    except Exception:
        return subprocess.check_output(['openssl', 'rand', '-hex', '16']).decode().strip()


def sub_direct_rule(sub_url):
    """订阅服务器对应的 DIRECT 规则。

    订阅拉取若不直连，会命中 MATCH→PROXY；当订阅节点全挂时，
    订阅因此拉不到新节点，形成无法自愈的死锁。
    """
    host = urllib.parse.urlparse(sub_url).hostname
    if not host:
        return ''
    try:
        ipaddress.ip_address(host)
        return f'IP-CIDR,{host}/32,DIRECT'
    except ValueError:
        return f'DOMAIN-SUFFIX,{host},DIRECT'


def load_node_urls(env):
    """自定义节点 URL 列表：优先 MIHOMO_NODE_URLS（空格分隔），回退单值 MIHOMO_NODE_URL。"""
    urls = env.get('MIHOMO_NODE_URLS', '').strip()
    if urls:
        return [u for u in urls.split() if u]
    single = env.get('MIHOMO_NODE_URL', '').strip()
    return [single] if single else []


def render_nodes(node_urls):
    """把节点 URL 列表渲染为 proxies 段 YAML，返回 (yaml, 节点名列表)。"""
    blocks = []
    names = []
    for i, url in enumerate(node_urls, start=1):
        u = urllib.parse.urlparse(url)
        ptype = {'http': 'http', 'https': 'http', 'socks5': 'socks5'}.get(u.scheme)
        if not ptype:
            sys.exit('自定义节点仅支持 http/socks5 URL（复杂节点类型直接改 config.yaml），收到: %s' % u.scheme)
        name = '自有节点' if i == 1 else '自有节点%d' % i
        names.append(name)
        lines = [
            '  - name: %s' % name,
            '    type: %s' % ptype,
            '    server: %s' % u.hostname,
            '    port: %d' % (u.port or (1080 if ptype == 'socks5' else 8080)),
        ]
        user = urllib.parse.unquote(u.username or '')
        pw = urllib.parse.unquote(u.password or '')
        if user:
            lines.append('    username: "%s"' % user)
        if pw:
            lines.append('    password: "%s"' % pw)
        blocks.append('\n'.join(lines))
    return '\n'.join(blocks), names


def render():
    env = load_proxy_env()
    sub_url = env.get('MIHOMO_SUB_URL', '').strip()
    node_urls = load_node_urls(env)
    if not sub_url:
        sys.exit('proxy.env 缺少 MIHOMO_SUB_URL（订阅连接）')

    cfg = open(TEMPLATE).read()
    cfg = cfg.replace('__SUB_URL__', sub_url)
    cfg = cfg.replace('__SECRET__', existing_secret())
    cfg = cfg.replace('__SUB_DIRECT_RULE__', sub_direct_rule(sub_url))

    # 节点入口 DoH：优先从订阅缓存提取（机场轮换后重跑即自动跟随）；回退复用现有配置
    ns = extract_nameservers(open(SUB_CACHE).read()) if os.path.exists(SUB_CACHE) else []
    if not ns and os.path.exists(TARGET):
        ns = extract_nameservers(open(TARGET).read())
    if ns:
        cfg = cfg.replace('__PROXY_SERVER_NS__', ''.join("\n    - '%s'" % u for u in ns))
    else:
        cfg = cfg.replace('__PROXY_SERVER_NS__',
                          ' []   # 订阅未提供 DoH；mihomo 首次拉取 providers/sub.yaml 后重跑 render.py 继承')

    if node_urls:
        nodes_yaml, names = render_nodes(node_urls)
        cfg = cfg.replace('__NODES__', nodes_yaml)
        cfg = cfg.replace('__NODE_NAMES__', ', ' + ', '.join(names))
    else:
        # 未配置自定义节点：整段删除 proxies 与策略组内引用
        cfg = re.sub(r'(?ms)^# 自定义扩展节点.*?(?=^proxy-groups:)', '', cfg)
        cfg = cfg.replace('__NODE_NAMES__', '')

    with open(TARGET, 'w') as f:
        f.write(cfg)
    os.chmod(TARGET, 0o600)
    print('已渲染 %s（sub=yes, node=%d, 入口DoH=%d）' % (TARGET, len(node_urls), len(ns)))


if __name__ == '__main__':
    render()
    if '--restart' in sys.argv:
        cmd = (['brew', 'services', 'restart', 'mihomo'] if sys.platform == 'darwin'
               else ['systemctl', '--user', 'restart', 'mihomo'])
        subprocess.run(cmd, check=True)
        print('mihomo 已重启')
