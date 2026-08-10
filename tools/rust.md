# tool: Rust

> 系统 / 性能敏感场景语言。工具链用官方 rustup 管理。

## 为什么用
性能 + 安全；适合写高性能工具 / 组件。

## 版本约束
- 工具链：stable 默认（rustup 管理）；按项目需要可加 nightly

## 安装

| 平台 | 方式 |
|------|------|
| macOS | `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \| sh`；或 `brew install rustup-init && rustup-init` |
| Linux | 同上 rustup 脚本 |

## 配置思路
- `rustup default stable`；`cargo` 默认即可。
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
