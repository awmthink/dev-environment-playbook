# tool: Python

> 算法主力语言。**统一用 uv** 当 toolchain（版本 + 包 + venv + CLI 工具）。

## 为什么用
算法 / 数据 / 脚本核心语言；uv 极快，一个工具覆盖 Python 版本管理、虚拟环境、依赖、全局 CLI 工具（替代 pipx/poetry/conda 的多数场景）。

## 版本约束
- Python：按项目锁定（uv 管理）；不依赖系统 python
- uv：latest

## 安装

| 平台 | 方式 |
|------|------|
| macOS | `brew install uv` |
| Linux | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |

## 配置思路
- Python 版本：`uv python install <ver>` / `uv python pin`；项目用 `uv` 自动管理。
- 虚拟环境：`uv venv`；项目依赖 `uv sync`（读 `pyproject.toml` / `uv.lock`）。
- 全局 CLI 工具：`uv tool install <pkg>`（替代 pipx）。
- `UV_PYTHON_PREFERENCE=only-managed`：优先用 uv 装的 python，避免污染系统 python。
- 镜像 / 索引：必要时在 `pyproject.toml` 配 `[[tool.uv.index]]`。

> 不再单独装 pipx / conda（被 uv 覆盖）；除非有强 conda 依赖（某些科学计算环境）才另议。

## 参考
- `configs/python/uv.toml` 或项目 `pyproject.toml` 片段（待补充）

## 验证
```sh
uv --version
uv python list          # 期望：可见已安装版本
uv tool list            # 期望：全局 CLI 工具
```
