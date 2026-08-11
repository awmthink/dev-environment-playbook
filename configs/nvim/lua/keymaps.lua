-- 通用键位（LSP 键位在 LspAttach 里按 buffer 设置）
local map = vim.keymap.set

map("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- 窗口导航
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

map("n", "<leader>q", "<cmd>qa<cr>", { desc = "Quit all" })
