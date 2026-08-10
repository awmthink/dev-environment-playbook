# tool: C/C++（含 CUDA）

> 性能 / 系统层与 GPU 算法（CUDA）。

## 为什么用
C/C++ 用于系统与高性能；CUDA 用于 GPU 算法加速。

## 版本约束
- 编译器：macOS 用 clang（Xcode CLT）/ brew llvm；Linux 用 gcc（>= 11）
- CUDA Toolkit：按 GPU / 驱动匹配（通常 latest 稳定分支，Linux GPU 机才有）

## 安装

| 平台 | 方式 |
|------|------|
| macOS | `xcode-select --install`；`brew install cmake llvm`（**注意：macOS 无原生 CUDA**） |
| Linux | `apt install build-essential cmake gdb`；CUDA 用 NVIDIA 官方 runfile / apt 仓库 |

## 配置思路
- 编译器：macOS 默认 clang 即可；如需新版 `brew install llvm` 并把 `$(brew --prefix llvm)/bin` 加 PATH。
- 构建：`cmake` + `ninja`（更快）。
- CUDA（仅 Linux GPU 机）：
  - 装 NVIDIA 驱动 + CUDA Toolkit；`nvcc` 入 PATH，`LD_LIBRARY_PATH` 含 cuda lib。
  - 版本与 PyTorch / 驱动兼容性要对齐（记录所用组合，避免反复踩坑）。
- 调试：Linux 用 gdb；macOS 用 lldb。

## 参考
- `configs/c-cpp/`（如 cmake presets、toolchain 文件，待补充）

## 验证
```sh
gcc --version || clang --version
cmake --version
nvcc --version   # 仅 Linux GPU 机，期望可见 CUDA 版本
nvidia-smi       # 仅 Linux GPU 机，期望可见驱动 / GPU
```
