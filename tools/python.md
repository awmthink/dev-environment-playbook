# tool: Python

> 算法主力语言。**版本由 mise 声明**（`python = "3.12"`），**uv 作项目 venv / 依赖 / CLI 工具引擎**。两者分工：mise 定解释器版本，uv 管项目。

## 为什么用
算法 / 数据 / 脚本核心语言；uv 极快，一个工具覆盖虚拟环境、依赖、全局 CLI 工具（替代 pipx/poetry/conda 的多数场景）。mise 统一声明版本（跨机器、跨平台一致），uv 负责项目级管理——各取所长。

## 版本约束
- Python：按项目锁定（mise 管理）；**全局默认 `3.12`**（`configs/mise/config.toml`）
- uv：latest（mise 管 `uv = "latest"`）

## 安装

| 平台 | 方式 |
|------|------|
| macOS / Linux | 都走 **mise**：`python` / `uv` 均在 `configs/mise/config.toml` 声明，`mise install` 一并装 |

> uv 是 mise 管的**独立工具**（aqua backend 拉预编译）；它不是 mise 装 python 的 backend——uv 自己有 `uv python` 能力，但 mise 装的解释器与 uv 互不耦合。项目里 `uv sync` 读 `pyproject.toml` / `uv.lock`。

## 配置思路
- **解释器版本**：`mise.toml`（项目级 override）或 `~/.config/mise/config.toml`（全局默认）。
- **虚拟环境 / 依赖**：`uv venv` / `uv sync` / `uv add`。
- **全局 CLI 工具**：`uv tool install <pkg>`（替代 pipx）。
- `UV_PYTHON_PREFERENCE=only-managed`：优先用 mise/uv 管理的 python，避免落到系统/conda python（见 `configs/shell/env.sh`）。
- 镜像 / 索引：必要时在 `pyproject.toml` 配 `[[tool.uv.index]]`，或 `UV_DEFAULT_INDEX` 走内网 PyPI 源。

> 不再单独装 pipx / conda（被 uv 覆盖）；除非有强 conda 依赖（某些科学计算环境，如 GPU 服务器的旧 ML env）才另议——那种机器 conda 与 uv 共存，conda 管它自己的 env、uv/mise 管新项目。

## 参考
- `configs/mise/config.toml`（python / uv 声明）
- `configs/shell/env.sh`（`UV_PYTHON_PREFERENCE`）

## 验证
```sh
mise current python uv
python --version
uv --version
uv tool list            # 全局 CLI 工具
```
