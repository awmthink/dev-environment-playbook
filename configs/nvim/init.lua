-- configs/nvim/init.lua — 参考实物（只读）
-- 真实文件：~/.config/nvim/init.lua（不软链；agent 按本文件思路生成）
-- 极简基础编辑配置，思路见 tools/neovim.md

vim.g.mapleader = " "

-- ===== 选项 =====
local o = vim.opt
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.expandtab = true
o.tabstop = 2
o.shiftwidth = 2
o.smartcase = true
o.ignorecase = true
o.wrap = false
o.scrolloff = 8
o.updatetime = 250
o.splitright = true
o.splitbelow = true
o.termguicolors = true
o.cursorline = true
-- :grep 走 ripgrep（基础搜索，结果进 quickfix）
o.grepprg = "rg --vimgrep --no-heading --smart-case"
o.grepformat = "%f:%l:%c:%m,%f:%l:%m"

-- ===== 通用键位（仅基础）=====
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })
vim.keymap.set("n", "<leader>q", "<cmd>qa<cr>", { desc = "Quit all" })
