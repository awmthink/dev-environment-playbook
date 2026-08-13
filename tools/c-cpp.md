# tool: C/C++（含 CUDA）

> 性能 / 系统层与 GPU 算法（CUDA）。**编译器平台原生（不进 mise）**：mac=Xcode CLT(Apple clang)，linux=per-user 预编译 llvm；**gcc 弃用**（clang 通吃，含 CUDA host compiler）；cmake/ninja 走 mise。

## 为什么这样分工
- mise 管 runtime/build/LSP 很强，但**编译器是弱项**：llvm 在 mise 走源码编译（慢）；无可用 gcc 插件。
- LLVM 官方发 **Linux 预编译**（快），但**不发 macOS 预编译**；且 macOS 编译绕不开 Xcode CLT（SDK 只在 CLT 里）。
- → 编译器留平台原生（最快、最稳），mise 专注 cmake/ninja + dev 工具。

## 最低版本要求
- **clang/llvm**：linux 用 **18.1.8** 预编译（CUDA 12.8 要求 clang<20；选老 glibc 构建兼容更广，含 CentOS 8）；mac 用 Xcode CLT 自带 Apple clang（版本跟随 Xcode）
- **gcc**：**不装**（clang 高度 gcc 兼容；CUDA 也用 clang 当 host；某项目硬要 gcc 时临时 devtoolset/源码，不入全局）
- CUDA Toolkit：按 GPU / 驱动匹配（通常 latest 稳定分支，Linux GPU 机才有，见 `tools/cuda.md`）

## 工具链（一张表）

| 层 | 工具 | macOS 来源 | Linux 来源 | 说明 |
|----|------|-----------|-----------|------|
| 编译器 | clang | Xcode CLT（Apple clang，默认） | per-user 预编译 llvm 18.1.8（`~/.local/llvm-18.1.8`，见下「Linux 安装」） | 算法 / CUDA 代码均用 clang |
| gcc | — | 不装 | 不装 | 弃用；必要时临时 devtoolset |
| 构建·生成 | CMake | mise | mise | 必装 |
| 构建·执行 | Ninja | mise | mise | 大项目增量构建远快于 Make |
| 调试器 | lldb / gdb | Xcode CLT（lldb） | distro gdb | |
| 内存/UB 检测 | ASan/UBSan/TSan | 编译 flag `-fsanitize=...` | 同 | 编译器内置 |
| 编译数据库 | `compile_commands.json` | `cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON` | 同 | clangd / clang-tidy 共同输入 |

### LLVM 语言工具（clangd / clang-format / clang-tidy）
- **macOS**：clangd / clang-format 随 Xcode CLT（`/usr/bin/clangd`）；要 clang-tidy 或更新 clang → 临时装 brew llvm（不入 mise）。
- **Linux**：clang / clangd / clang-format / clang-tidy 全在 `~/.local/llvm-18.1.8/bin`（同一份预编译 tarball 给齐，版本一致）。

## 版本与安装策略

**多版本需求：否（clang 锁 18.1.8）**——CUDA 12.8 兼容区间 clang<20，全局单一，一般不切版本。极少需要多版本 clang；某项目硬要别的版本时临时 devtoolset / 源码另装，不入全局。cmake/ninja 跟随 mise，可项目级 override（`mise.toml`）。

**各平台安装**（编译器平台原生，不进 mise；cmake/ninja 走 mise）：

| 平台 | 推荐方式 |
|------|----------|
| macOS | Xcode CLT（见 `platforms/macos.md`）；cmake/ninja 走 mise |
| Linux | per-user 预编译 llvm 18.1.8 + cmake/ninja（mise）；CUDA 见 `tools/cuda.md` |

**cmake/ninja（mise 安装）**：`mise use -g cmake@latest`、`mise use -g ninja@latest`（装 + 锁全局默认），可项目级 `mise.toml` override 锁版本。

### Linux 安装（per-user llvm 预编译 tarball）
> 选 **ubuntu-18.04 变体**（老 glibc 构建），兼容 CentOS 8（glibc 2.28）等老发行版。装到 `~/.local/llvm-18.1.8`，由 `configs/shell/env.sh` 前置进 PATH。
```sh
LLVM_VER=18.1.8
TARBALL="clang+llvm-$LLVM_VER-x86_64-linux-gnu-ubuntu-18.04.tar.xz"
curl -fL "https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VER/$TARBALL" -o /tmp/llvm.tar.xz
tar -xf /tmp/llvm.tar.xz -C /tmp
mv /tmp/clang+llvm-* ~/.local/llvm-$LLVM_VER
```
> clang/clangd/clang-format/clang-tidy 同一 tarball 给齐，版本一致。aarch64 把 TARBALL 换成 `clang+llvm-$LLVM_VER-aarch64-linux-gnu.tar.xz`。
> **运行时依赖 `libtinfo.so.5`**：clang 等需要（tarball 不自带）。CentOS/RHEL 8 只发 libtinfo 6 → 装 compat 包：`sudo dnf install ncurses-compat-libs`（Ubuntu/Debian 通常自带）。**勿用**「`libtinfo.so.5` → `libtinfo.so.6`」伪软链当 compat——会触发 `no version information available` 警告。

## 配置思路
- **编译器**：mac 默认 Apple clang（SDK 感知）；linux 把 `~/.local/llvm-18.1.8/bin` 前置 PATH（见 `configs/shell/env.sh`），`CC=clang CXX=clang++`。
- **CUDA host compiler**：`CUDAHOSTCXX=clang++`（CMake）/ `nvcc -ccbin clang`；CUDA 12.8 兼容 clang<20，故锁 llvm 18.1.8（详见 `tools/cuda.md`）。不用 gcc。
- **构建**：`cmake -S . -B build -G Ninja` → `cmake --build build`（自动并行）。
- **编译数据库**：`set(CMAKE_EXPORT_COMPILE_COMMANDS ON)`，软链 `compile_commands.json` 到项目根供 clangd/clang-tidy。
- **格式化**：`clang-format`，风格交项目根 `.clang-format`。
- **静态分析**：`clang-tidy -p build <src>`。
- **内存检测**：开发期开 `-fsanitize=address,undefined`，发布关。
- **CUDA**（仅 Linux GPU 机）：见 `tools/cuda.md`。
- **调试**：linux 用 gdb；mac 用 lldb。

## 参考
- `configs/shell/env.sh`（linux llvm PATH 前置、CC/CXX）
- `tools/cuda.md`（CUDA toolchain）

## 验证
```sh
clang --version            # mac: Apple clang；linux: 18.1.8
clangd --version           # LSP
clang-format --version
cmake --version            # mise
ninja --version            # mise
# 仅 Linux GPU 机：
nvcc --version             # CUDA
nvidia-smi                 # 驱动 / GPU
# CUDA + clang host 编译验证（见 tools/cuda.md）
```
