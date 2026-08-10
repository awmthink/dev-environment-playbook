# tool: Node.js

> 前端（TS + Vue）与部分工具链的运行时。包管理用 pnpm。

## 为什么用
TypeScript + Vue 栈必备；大量 CLI 工具基于 Node。

## 版本约束
- Node：LTS（通过版本管理器安装，按项目 `.tool-versions` / `.nvmrc` 锁定）
- pnpm：latest

## 安装

| 平台 | 方式 |
|------|------|
| macOS | `brew install mise pnpm`；`mise install node@lts` |
| Linux | `curl ... | sh` 装 mise；`mise install node@lts`；`brew install pnpm` 或 `corepack enable` |

> 版本管理器：推荐 **mise**（polyglot，能同时管 node/go 等，适合多语言栈）；备选 **fnm**（更专注、更快）。最终选哪个待定，但**不要混用多个管理器**。

## 配置思路
- pnpm 为默认包管理器；`corepack enable` 后 `corepack prepare pnpm` 也可。
- `.npmrc`：按需设 registry 镜像（与代理配合，国内可加速）；`manage-package-manager-versions` 让项目自带 pnpm 版本。
- 全局 bin 目录加入 PATH。

## 参考
- `configs/node/.npmrc`（实物，待补充）

## 验证
```sh
node -v          # 期望：LTS
pnpm -v          # 期望：较新
mise --version   # 若用 mise
```
