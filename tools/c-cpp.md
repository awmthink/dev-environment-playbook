# tool: C/C++（含 CUDA）

> 性能 / 系统层与 GPU 算法（CUDA）。

## 为什么用
C/C++ 用于系统与高性能；CUDA 用于 GPU 算法加速。

## 版本约束
- 编译器：macOS 用 Apple clang（Xcode CLT）或 brew llvm 的 clang；Linux 用 gcc（>= 11，版本匹配 CUDA）
- CUDA Toolkit：按 GPU / 驱动匹配（通常 latest 稳定分支，Linux GPU 机才有）

## 工具链（一张表定下来）

| 层 | 工具 | macOS 来源 | Linux 来源 | 说明 |
|----|------|-----------|-----------|------|
| 编译器 | clang / gcc | Xcode CLT（Apple clang，默认） | gcc（`build-essential`，匹配 CUDA） | 算法代码用默认即可；要 clang-tidy / 更新 clang → brew llvm |
| 构建·生成 | CMake | `brew install cmake` | `apt install cmake` / Linuxbrew | 必装（meta-build，生成 Makefile / build.ninja） |
| 构建·执行 | Ninja | `brew install ninja` | `apt install ninja-build` | 可选但推荐，大项目增量构建远快于 Make |
| 调试器 | lldb / gdb | Xcode CLT（lldb） | gdb | |
| 内存/UB 检测 | ASan / UBSan / TSan | 编译 flag `-fsanitize=...` | 同 | 编译器内置，无需单独装 |
| 编译数据库 | `compile_commands.json` | `cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON` | 同 | clangd / clang-tidy 的共同输入 |

### LLVM 语言工具（clangd / clang-format / clang-tidy）
> clang-tidy **无独立 formula、也不在 Xcode CLT**，只能随完整 `llvm` 装。两种取法：

- **完整（含 clang-tidy，推荐用于严肃 C++）**：`brew install llvm`，PATH 前置 `$(brew --prefix llvm)/bin`。一个 formula 给齐 clang、clangd、clang-format、clang-tidy，版本一致、比 CLT 新。代价 ~2GB、keg-only（PATH 前置后覆盖系统 clang/clangd）。
- **精简（无 clang-tidy，日常算法够用）**：clangd 走 Xcode CLT（`/usr/bin/clangd`），格式化走 `brew install clang-format`。轻量，但拿不到 clang-tidy。

> 是否需要 clang-tidy 决定走哪条；日常算法 / CUDA 代码「精简」足矣，严肃 C++ 工程（强类型 / 现代 C++ 最佳实践检查）走「完整」。

## 安装（一行式速装，按「完整」方案）

| 平台 | 命令 |
|------|------|
| macOS | Xcode CLT（见 `platforms/macos.md`「开发者基础」）；`brew install cmake ninja llvm`（**注意：macOS 无原生 CUDA**） |
| Linux | `apt install build-essential cmake ninja-build gdb`；LLVM 工具链 `brew install llvm`（或发行版 `clangd` / `clang-tidy` 包）；CUDA 用 NVIDIA 官方 runfile / apt 仓库 |

## 配置思路
- 编译器：macOS 默认 Apple clang（SDK 感知）即可；要 clang-tidy / 更新 clang 用 brew llvm 并前置 PATH。Linux GPU 机锁定匹配 CUDA 的 gcc 版本，不随意升。
- 构建：`cmake -S . -B build -G Ninja` 生成 `build.ninja` → `cmake --build build`（自动并行）；小项目可不要 ninja，用默认 Makefile。
- 编译数据库：`set(CMAKE_EXPORT_COMPILE_COMMANDS ON)`，把生成的 `compile_commands.json` 软链到项目根，供 clangd / clang-tidy 用。
- 格式化：`clang-format`（C/C++/Obj-C/JS/TS）；风格交项目根 `.clang-format`（LLVM / Google 等预设），不全局固化。
- 静态分析：`clang-tidy -p build <src>`（`-p` 指向 `compile_commands.json` 目录）。
- 内存检测：开发期开 `-fsanitize=address,undefined`，发布关。
- CUDA（仅 Linux GPU 机）：
  - 装 NVIDIA 驱动 + CUDA Toolkit；`nvcc` 入 PATH，`LD_LIBRARY_PATH` 含 cuda lib。
  - 版本与 PyTorch / 驱动兼容性要对齐（记录所用组合，避免反复踩坑）。
- 调试：Linux 用 gdb；macOS 用 lldb。

## 参考
- `configs/c-cpp/`（如 cmake presets、toolchain 文件，待补充）

## 验证
```sh
gcc --version || clang --version
clangd --version            # LSP（CLT 或 brew llvm）
clang-format --version      # 格式化
clang-tidy --version        # 静态分析（仅「完整」方案 / brew llvm）
cmake --version
ninja --version             # 装了才有
nvcc --version   # 仅 Linux GPU 机，期望可见 CUDA 版本
nvidia-smi       # 仅 Linux GPU 机，期望可见驱动 / GPU
```
