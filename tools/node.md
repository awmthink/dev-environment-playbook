# tool: Node.js

> 前端（TS + Vue）与部分工具链的运行时。包管理用 pnpm（通过 corepack）。

## 为什么用
TypeScript + Vue 栈必备；大量 CLI 工具基于 Node。

## 版本约束
- Node：**LTS，全局单版本**（当前 **node@24** / 24.19.0），由 brew 安装
- pnpm：latest（通过 **corepack** 管理，按项目 `package.json` 的 `packageManager` 字段锁定）

## 安装

| 平台 | 方式 |
|------|------|
| macOS | `brew install node@24`；`brew link --force node@24`（keg-only，需强制链接到 PATH）；`corepack enable` |
| Linux | 用 nvm/fnm 装一份 LTS（任选其一，不与 macOS 强求一致） |

> **为什么不用版本管理器（mise/nvm/fnm）**：实际开发不切换 node 版本（各项目都用同一 LTS），单版本 brew 直装即可。polyglot 管理器 mise 曾试用，但其 polyglot 价值在本机未兑现（python→uv、go→`GOTOOLCHAIN` 原生、rust→rustup），退化成「只管 node 的重工具」，故弃用。真撞上需要切版本的项目，临时装回 fnm 成本也很低。
>
> **node@24 是 keg-only**：brew 不主动链入 `/opt/homebrew/bin`（避免与 `node` formula 冲突）。`brew link --force node@24` 把 `node`/`npm`/`npx`/`corepack` 软链到 `/opt/homebrew/bin`，使其在 PATH 上生效。

## 配置思路
- **pnpm 通过 corepack**：node 自带 corepack，`corepack enable` 后 pnpm/yarn 命令由 corepack 提供，无需单独 `brew install pnpm`。
  - 默认版本：`corepack prepare pnpm@latest --activate`。
  - 项目锁版本：`package.json` 的 `"packageManager": "pnpm@x.y.z"`，corepack 自动用对应版本（确定性构建）。
- **node-based CLI 工具走 `npm install -g`，不用 brew**：pyright、vtsls 等本质是 npm 包。用 brew 装会让 brew 再拉一份 `node` 作 formula 依赖（与本机 node 重复 ~180MB）。统一 `npm i -g` 装在当前 node 下，既省磁盘又保证版本跟随 node。
- `.npmrc`：按需设 registry 镜像（与代理配合，国内可加速）。

## 参考
- `configs/node/.npmrc`（实物，待补充）

## 验证
```sh
node -v            # 期望：v24.x（LTS，brew node@24）
which node         # 期望：/opt/homebrew/bin/node（force-link 后）
pnpm -v            # 期望：较新（来自 corepack）
corepack --version
```
