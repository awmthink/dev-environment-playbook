#!/usr/bin/env python3
"""从 proxy.env 的两个出口变量渲染 mihomo config.yaml（幂等）。

- MIHOMO_SUB_URL ：订阅连接（必填）
- MIHOMO_NODE_URL：自定义扩展节点，http/socks5 代理 URL 形式（可选；留空则渲染出不带自定义节点的配置）

用法：render.py [--restart]
  --restart 渲染后重启 systemd 用户服务
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
    print('已渲染 %s（sub=yes, node=%s）' % (TARGET, 'yes' if node_url else 'no'))


if __name__ == '__main__':
    render()
    if '--restart' in sys.argv:
        subprocess.run(['systemctl', '--user', 'restart', 'mihomo'], check=True)
        print('mihomo 已重启')
