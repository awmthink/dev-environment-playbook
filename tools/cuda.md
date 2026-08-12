# tool: CUDA / TensorRT

> GPU 算法的**外部 toolchain**——无 brew/mise formula，独立来源。nvcc + TensorRT + 驱动，Linux GPU 机才装（macOS 无原生 CUDA）。

## 为什么单独成章
CUDA 工具链不属于 brew/mise 任何一方（brew 无 cuda formula、mise 无 nvcc），且**版本耦合严格**（驱动 ↔ CUDA ↔ host compiler ↔ PyTorch），踩坑成本高，需要专门记录版本组合与验证。

## 版本约束（按机器实际填；下为示例组合）
- GPU 架构：示例 sm_75（如 T4）；按 `nvidia-smi` 实际填，cmake 用 `CMAKE_CUDA_ARCHITECTURES`
- 驱动 / CUDA Toolkit / TensorRT：版本需互相 + 与 PyTorch 对齐
- **host compiler：clang 18.1.8**（CUDA 12.x 要求 clang<20；见 `tools/c-cpp.md`）

> CUDA 与 host compiler 兼容区间必须对齐（CUDA 12.8：gcc ≤13.2、clang <20）。**用 clang**，不用 gcc。

## 来源（按机器选其一）

| 来源 | 适用 | 说明 |
|------|------|------|
| 集群预装 | 共享 GPU 服务器 | NVIDIA 固定版本副本，省自装 |
| NVIDIA 官方 runfile | 想自管、user-local | 装到 `~/cuda-<ver>`（~5GB） |
| NVIDIA apt/dnf 仓库 | 有 sudo 的自有机 | 系统级 |

## 配置思路（环境变量，进 shell rc / `configs/shell/env.sh`）
```sh
export CUDAToolkit_ROOT=<cuda prefix>        # 集群路径 或 ~/cuda-12.8
export CUDACXX=$CUDAToolkit_ROOT/bin/nvcc
export PATH=$CUDAToolkit_ROOT/bin:$PATH
export LD_LIBRARY_PATH=$CUDAToolkit_ROOT/lib64:<TensorRT>/lib:${LD_LIBRARY_PATH:-}
export CUDAHOSTCXX=clang++    # nvcc 默认找 g++，本环境用 clang
export CC=clang CXX=clang++
```

- **CUDA host compiler 显式指向 clang**：`CUDAHOSTCXX=clang++`（CMake）或 `nvcc -ccbin clang`。
- `compile_commands.json` / 架构：`cmake -DCMAKE_CUDA_ARCHITECTURES=75`（T4=sm_75）。

## 验证（写进 playbook 必跑——确认 host compiler 与 CUDA 真兼容）
```sh
nvcc --version                  # 期望 V12.8.x
nvidia-smi                      # 期望驱动 + GPU 可见
# clang 当 host compiler 编译并跑一个 kernel：
cat > /tmp/t.cu <<'EOF'
#include <cstdio>
__global__ void k(int* a){ *a = 42; }
int main(){ int *d,h=0; cudaMalloc(&d,4); k<<<1,1>>>(d); cudaMemcpy(&h,d,4,cudaMemcpyDeviceToHost); printf("GPU=%d\n",h); cudaFree(d); return 0; }
EOF
nvcc -ccbin clang -arch=sm_75 /tmp/t.cu -o /tmp/t && /tmp/t   # 期望：GPU=42
```

## 已知坑
- CUDA 升级时同步检查 host compiler 区间（gcc/clang 上限随 CUDA 版本变）。
- PyTorch / onnxruntime-gpu 版本要与 CUDA / TensorRT 对齐（记录所用组合，避免反复踩坑）。
