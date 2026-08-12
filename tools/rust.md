# tool: Rust

> 系统 / 性能敏感场景语言。**版本由 mise 声明**（`rust = "1.97"`），**底层引擎是 rustup**——mise 只决定 toolchain 版本，rustup 的 `component` / `default` 等机制照旧。

## 为什么用
性能 + 安全；适合写高性能工具 / 组件。mise 统一声明版本（跨平台一致），rustup 作 engine 保留其完整能力（component 管理、toolchain 切换）。

## 最低版本要求
- 工具链：stable 默认（mise 管；rustup engine）；按项目需要可加 nightly

## 版本与安装策略

**多版本需求：按项目**——项目根放 `rust-toolchain.toml`（rustup 机制），进目录自动切 channel / 版本。mise 管全局默认 stable；rustup 支持多 toolchain 并存（stable / nightly / 特定版本）。component（rust-analyzer 等）跟随各 toolchain，`rustup component add` 按需装。

**各平台安装**（多版本需求 → 走 mise/rustup）：

| 平台 | 推荐方式 |
|------|----------|
| macOS / Linux | 都走 **mise**：`rust = "1.97"` 在 `configs/mise/config.toml`；`mise install` 即装（底层调 rustup） |

> mise 的 rust backend **就是 rustup**：`rust = "1.97"` 会用 rustup 装该 toolchain。装完后 `rustup component add rust-analyzer`、`rustup default stable` 等命令照常可用。cargo 产物进 `~/.cargo/bin`（PATH 见 `configs/shell/env.sh`）。

## 配置思路
- `mise.toml` 声明 rust 版本（项目级 override / 全局默认）。
- `cargo` 默认即可；用 `--no-modify-path` 思路（PATH 已由 `configs/shell/env.sh` 的 `~/.cargo/bin` 覆盖）。
- 国内加速：`~/.cargo/config.toml` 的 crates.io 镜像 `[source.crates-io]` + `replace-with`。
- LSP：`rustup component add rust-analyzer`（见 `tools/lsp.md`）。

## 参考
- `configs/mise/config.toml`（rust 声明）
- `configs/shell/env.sh`（`~/.cargo/bin` PATH）

## 验证
```sh
mise current rust
rustc --version
cargo --version
rustup show
```
