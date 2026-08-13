# tool: LSP servers（跨编辑器共享）

> 语言服务器，为编辑器（Zed）提供代码导航 / 悬浮文档 / 诊断 / 重构能力。**部分走 mise、部分走平台原生编译器**；系统级安装进 PATH，多编辑器共享——不依赖 Mason。

## 为什么用
读代码核心：定义跳转、引用查找、hover 文档、诊断。装在系统 PATH，**Zed 自动检测直接用**（Neovim 已不再配 LSP——终端深度读代码交 agent，见 `tools/neovim.md`）。统一一份 server，避免 Mason 黑盒层、版本统一。

## servers 清单（覆盖 profile 技术栈）

| 语言 | server | 安装 | 备注 |
|------|--------|------|------|
| Python | pyright | **mise**：`mise use -g npm:pyright@latest`（随 node） | 类型 / 定义 / 引用 |
| TypeScript/Vue | vtsls | **mise**：`mise use -g npm:@vtsls/language-server@latest`（随 node） | TS/JS/Vue |
| Rust | rust-analyzer | `rustup component add rust-analyzer` | 跟随 rustup toolchain（见 `tools/rust.md`） |
| C/C++ | clangd | **平台原生**：mac=Xcode CLT；linux=`~/.local/llvm-18.1.8/bin`（见 `tools/c-cpp.md`） | 与 clang-format/clang-tidy 同源 |
| Go | gopls | **待验证**：mise registry 无、go backend 未验证 → 暂在项目内 `go install golang.org/x/tools/gopls@latest` | 验证后再进 mise 全局 config |

## 版本与安装策略

**多版本需求：否**——server 版本跟随各自语言运行时（见上方「安装」列），不单独做多版本管理：
  - pyright / vtsls 随 mise 的 node；
  - rust-analyzer 跟随 rustup toolchain（`rust-toolchain.toml`）；
  - clangd 跟随平台 llvm（锁 18.1.8）。

同一语言要多套 server 版本的情况极少；真要时随对应运行时切换即可。各 server 的具体安装方式见上方「servers 清单」表。

## 配置思路
- **Zed**：自动检测 PATH 的 server 读代码（纯 editor 定位，无需配置；见 `tools/zed.md`）。
- **Neovim**：不使用（终端读代码交 agent；见 `tools/neovim.md`）。
- pyright/vtsls 随 mise 的 node（npm backend），版本跟随 brew 无关；rust-analyzer 跟随 rustup；clangd 跟随平台 llvm。
- **不依赖 Mason**（避免黑盒、版本统一、跨工具共享）。

## 参考
- `tools/c-cpp.md`（clangd 来源）
- `tools/mise.md`（pyright/vtsls 经 mise 全局 config 声明）

## 验证
```sh
mise current node            # pyright/vtsls 依赖 node
which pyright-langserver vtsls rust-analyzer
clangd --version             # mac: CLT；linux: ~/.local/llvm-18.1.8
```
