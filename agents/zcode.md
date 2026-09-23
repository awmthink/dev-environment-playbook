# agent: Zcode

> App 类（GUI）。配置在 App 界面内完成、不落配置文件，无法随 playbook 管理 / 迁移——本卡片只登记分类，不覆盖配置内容。

> 全局指令：`~/.zcode/AGENTS.md`（软链到 `~/.agents/AGENTS.md`）。onboarding 提供「agents-file」迁移步骤，把 `~/.claude/CLAUDE.md` 复制为 `~/.zcode/AGENTS.md`（Claude Code 系血缘）。
>
> 仓库内 `AGENTS.md` 会被自动读取：从当前工作目录向上搜索到项目根；合并顺序为用户 `~/.zcode/AGENTS.md` 先注入、工作区 `AGENTS.md` 后注入（工作区可收窄/覆盖用户默认）。`/init` 命令用于创建/更新当前工作区的 `AGENTS.md`。依据：ZCode 内置 `zcode-configuration-guide` skill。
