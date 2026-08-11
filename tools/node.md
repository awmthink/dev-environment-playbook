# tool: Node.js

> 前端（TS + Vue）与部分工具链的运行时。包管理用 pnpm（通过 corepack）。

## 为什么用
TypeScript + Vue 栈必备；大量 CLI 工具基于 Node。

## 版本约束
- Node：LTS（通过 **mise** 安装，按项目 `.tool-versions` / `.nvmrc` 锁定）
- pnpm：latest（通过 **corepack** 管理，按项目 `package.json` 的 `packageManager` 字段锁定）

## 安装

| 平台 | 方式 |
|------|------|
| macOS | `brew install mise`；`mise install node@lts`；`mise use --global node@lts`；`corepack enable` |
| Linux | `curl ... | sh` 装 mise；`mise install node@lts`；`corepack enable` |

> 版本管理器：采用 **mise**（polyglot，能同时管 node/go 等，适合多语言栈）。**不要混用多个管理器**（nvm/fnm/asdf 二选一即可，当前定 mise）。
> shell 钩子：`.zshrc` 里 `eval "$(mise activate zsh)"`（mise 动态接管 PATH）。

## 配置思路
- **pnpm 通过 corepack**：node 自带 corepack，`corepack enable` 后 pnpm/yarn 命令由 corepack 提供，无需单独 `brew install pnpm`。
  - 默认版本：`corepack prepare pnpm@latest --activate`。
  - 项目锁版本：`package.json` 的 `"packageManager": "pnpm@x.y.z"`，corepack 自动用对应版本（确定性构建）。
  - 优于 brew pnpm：版本跟随 node、可按项目锁定、少一层 formula。
- `.npmrc`：按需设 registry 镜像（与代理配合，国内可加速）。
- 全局 bin 目录加入 PATH。

## 参考
- `configs/node/.npmrc`（实物，待补充）

## 验证
```sh
node -v            # 期望：LTS（来自 mise）
which node         # 期望：~/.local/share/mise/installs/node/...
pnpm -v            # 期望：较新（来自 corepack）
which pnpm         # 期望：mise node bin 下（corepack shim）
mise --version
corepack --version
```
