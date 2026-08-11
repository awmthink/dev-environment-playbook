-- Neovim 配置：以读代码为核心，重度依赖 LSP；故意不装补全（写代码交给 coding agent）。
-- 约定见 tools/neovim.md

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("options")
require("keymaps")
require("plugins.init")
