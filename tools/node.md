# tool: Node.js

> 前端（TS + Vue）与部分工具链的运行时。**版本由 mise 声明**（`node = "24"`），包管理用 pnpm（通过 corepack）。

## 为什么用
TypeScript + Vue 栈必备；大量 CLI 工具基于 Node。mise 统一声明版本（跨平台一致、per-user、无需 brew force-link 的 keg-only 处理）。

## 版本约束
- Node：**LTS，全局单版本**（当前 **24**），由 mise 管
- pnpm：latest（通过 **corepack** 管理，按项目 `package.json` 的 `packageManager` 字段锁定）

## 安装

| 平台 | 方式 |
|------|------|
| macOS / Linux | 都走 **mise**：`node = { version = "24", postinstall = "corepack enable" }` 在 `configs/mise/config.toml` |

> **为什么不用版本管理器（nvm/fnm/mise 之外的）也不再用 brew**：实际开发不切换 node 版本（各项目都用同一 LTS），mise 声明单版本即可，跨平台一致、无需 brew 的 `node@24` keg-only force-link 麻烦。真撞上需要切版本的项目，mise 项目级 `mise.toml` override 成本也很低。

## 配置思路
- **pnpm 通过 corepack**：node 自带 corepack，`postinstall = "corepack enable"` 后 pnpm/yarn 由 corepack 提供。
  - 默认版本：`corepack prepare pnpm@latest --activate`。
  - 项目锁版本：`package.json` 的 `"packageManager": "pnpm@x.y.z"`，corepack 自动用对应版本。
- **node-based CLI 工具走 `npm install -g`**（如 LSP 的 pyright/vtsls，见 `tools/lsp.md`）：本质是 npm 包，装在当前 node 下，既省磁盘又保证版本跟随 node。
- `.npmrc`：按需设 registry 镜像（与代理配合，国内可加速）。

## 参考
- `configs/mise/config.toml`（node 声明 + corepack postinstall）
- `configs/node/.npmrc`（实物，待补充）

## 验证
```sh
mise current node
node -v            # 期望：v24.x（LTS）
pnpm -v            # 期望：较新（来自 corepack）
corepack --version
```
