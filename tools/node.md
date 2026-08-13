# tool: Node.js

> 前端（TS + Vue）与部分工具链的运行时。**版本由 mise 锁**（`mise use -g node@24`），包管理用 pnpm（通过 corepack）。

## 为什么用
TypeScript + Vue 栈必备；大量 CLI 工具基于 Node。mise 统一声明版本（跨平台一致、per-user、无需 brew force-link 的 keg-only 处理）。

## 最低版本要求
- Node：**>= 24（LTS）**，全局单版本。
- pnpm：latest（通过 **corepack** 管理，按项目 `package.json` 的 `packageManager` 字段锁定）。

## 版本与安装策略

**多版本需求：基本不需要**——所有项目都用同一 LTS（24），全局单版本即可。个别项目要别的 node：项目根放 `mise.toml`（如 `node = "22"`）override，进目录自动切。pnpm 版本由 corepack 按项目 `package.json` 的 `packageManager` 字段锁定，无需额外版本管理。

**管理方式**：仍走版本管理器（mise）——偶尔的项目级 override 需要它，且 brew `node@24` 是 keg-only、需 force-link，不如 mise 干净。

**各平台安装**：

| 平台 | 推荐方式 |
|------|----------|
| macOS / Linux | 都走 **mise**：`mise use -g node@24`（装 + 锁全局默认），随后 `corepack enable` 启用 pnpm |

> macOS 上若确定永不切换版本、只想最省事，`brew install node` 也行，但后续要项目级换版本时还得再上版本管理器。

## 配置思路
- **pnpm 通过 corepack**：node 自带 corepack，装完 node 后手动 `corepack enable`（不靠 mise postinstall 钩子），pnpm/yarn 由 corepack 提供。
  - 默认版本：`corepack prepare pnpm@latest --activate`。
  - 项目锁版本：`package.json` 的 `"packageManager": "pnpm@x.y.z"`，corepack 自动用对应版本。
- **node-based CLI 工具走 `npm install -g`**（如 LSP 的 pyright/vtsls，见 `tools/lsp.md`）：本质是 npm 包，装在当前 node 下，既省磁盘又保证版本跟随 node。
- `.npmrc`：按需设 registry 镜像（与代理配合，国内可加速）。

## 参考
- `configs/node/.npmrc`（实物，待补充）

## 验证
```sh
mise current node
node -v            # 期望：v24.x（LTS）
pnpm -v            # 期望：较新（来自 corepack）
corepack --version
```
