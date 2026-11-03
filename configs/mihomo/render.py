#!/usr/bin/env python3
"""从 proxy.env 的两个出口变量渲染 mihomo config.yaml（幂等）。

- MIHOMO_SUB_URL ：订阅连接（必填）
- MIHOMO_NODE_URL：自定义扩展节点，http/socks5 代理 URL 形式（可选；留空则渲染出不带自定义节点的配置）
- 节点入口 DNS：自动从 providers/sub.yaml（mihomo 订阅缓存，每日自动刷新）提取 dns 段的
  proxy-server-nameserver 继承——机场入口域名为 CNAME 链 + IP 轮转型，公共 DNS 拿到死 IP；
  sub.yaml 不存在时回退复用现有 config.yaml 里的 DoH（首次落地需 mihomo 拉取订阅后重跑一次）

用法：render.py [--restart]
  --restart 渲染后重启服务（Linux: systemd 用户服务；macOS: brew services）
依赖：~/.config/mihomo/config.example.yaml 模板（本仓库 configs/mihomo/config.example.yaml 的落地副本）
幂等：已有 config.yaml 的 API secret 会被复用，不重复生成。
"""
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


def render():
    env = load_proxy_env()
    sub_url = env.get('MIHOMO_SUB_URL', '').strip()
    node_url = env.get('MIHOMO_NODE_URL', '').strip()
    if not sub_url:
        sys.exit('proxy.env 缺少 MIHOMO_SUB_URL（订阅连接）')

    cfg = open(TEMPLATE).read()
    cfg = cfg.replace('__SUB_URL__', sub_url)
    cfg = cfg.replace('__SECRET__', existing_secret())

    # 节点入口 DoH：优先从订阅缓存提取（机场轮换后重跑即自动跟随）；回退复用现有配置
    ns = extract_nameservers(open(SUB_CACHE).read()) if os.path.exists(SUB_CACHE) else []
    if not ns and os.path.exists(TARGET):
        ns = extract_nameservers(open(TARGET).read())
    if ns:
        cfg = cfg.replace('__PROXY_SERVER_NS__', ''.join("\n    - '%s'" % u for u in ns))
    else:
        cfg = cfg.replace('__PROXY_SERVER_NS__',
                          ' []   # 订阅未提供 DoH；mihomo 首次拉取 providers/sub.yaml 后重跑 render.py 继承')

    if node_url:
        u = urllib.parse.urlparse(node_url)
        ptype = {'http': 'http', 'https': 'http', 'socks5': 'socks5'}.get(u.scheme)
        if not ptype:
            sys.exit('MIHOMO_NODE_URL 仅支持 http/socks5 URL（复杂节点类型直接改 config.yaml），收到: %s' % u.scheme)
        cfg = cfg.replace('__NODE_HOST__', u.hostname)
        cfg = cfg.replace('__NODE_PORT__', str(u.port or (1080 if ptype == 'socks5' else 8080)))
        cfg = cfg.replace('__NODE_USER__', urllib.parse.unquote(u.username or ''))
        cfg = cfg.replace('__NODE_PASSWORD__', urllib.parse.unquote(u.password or ''))
        cfg = cfg.replace('__NODE_TYPE__', ptype)
        # 无凭据节点：去掉空的 username/password 行
        cfg = re.sub(r'\n\s+username: ""\n\s+password: ""', '', cfg)
    else:
        # 未配置自定义节点：整段删除 proxies 与策略组内引用
        cfg = re.sub(r'(?ms)^# 自定义扩展节点.*?(?=^proxy-groups:)', '', cfg)
        cfg = cfg.replace(', 自有节点', '')

    with open(TARGET, 'w') as f:
        f.write(cfg)
    os.chmod(TARGET, 0o600)
    print('已渲染 %s（sub=yes, node=%s, 入口DoH=%d）' % (TARGET, 'yes' if node_url else 'no', len(ns)))


if __name__ == '__main__':
    render()
    if '--restart' in sys.argv:
        cmd = (['brew', 'services', 'restart', 'mihomo'] if sys.platform == 'darwin'
               else ['systemctl', '--user', 'restart', 'mihomo'])
        subprocess.run(cmd, check=True)
        print('mihomo 已重启')
