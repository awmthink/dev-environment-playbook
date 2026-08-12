# tool: Rust

> 系统 / 性能敏感场景语言。工具链用官方 rustup 管理。

## 为什么用
性能 + 安全；适合写高性能工具 / 组件。

## 版本约束
- 工具链：stable 默认（rustup 管理）；按项目需要可加 nightly

## 安装

| 平台 | 方式 |
|------|------|
| macOS | `brew install rustup && brew link --force rustup && rustup default stable`；或官方脚本 `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \| sh` |
| Linux | 同上 rustup 脚本 |

> **brew `rustup` 是 keg-only**：与已弃用的 `rust` formula 同名空间冲突，brew 不主动链入 `/opt/homebrew/bin`。`brew link --force rustup` 把 `rustup` + `rustc`/`cargo`/`rust-analyzer` 等 **proxy 垫片**链进 PATH——这些垫片统一委托给 rustup，再走当前 toolchain（`~/.rustup`）。**不要同时装 brew `rust` formula**（会与垫片冲突，且带 ~370MB 依赖、把 llvm/python 等一并拉进来）。
>
> **formula 已改名**：旧文档的 `brew install rustup-init && rustup-init` 已失效——该 formula 现叫 `rustup`，不再提供 `rustup-init` 命令，直接用 `rustup` 二进制 bootstrap。

## 配置思路
- `rustup default stable`；`cargo` 默认即可。
- 用 `--no-modify-path` 安装（PATH 已由 `configs/shell/env.sh` 的 `~/.cargo/bin` 覆盖），保持 rc 干净。
- 国内加速：配置 `~/.cargo/config.toml` 的 crates.io 镜像 `[source.crates-io]` + `replace-with`。
- 环境变量：`source "$HOME/.cargo/env"`（rustup 自动写入 shell rc）。

## 参考
- `configs/rust/config.toml`（cargo 镜像配置，待补充）

## 验证
```sh
rustc --version
cargo --version
rustup show
```
