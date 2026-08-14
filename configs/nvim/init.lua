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
o.background = "dark"   -- 显式深色，避免启动时 OSC11 背景检测（SSH 下超时，见 tools/neovim.md）
o.cursorline = true
-- 系统剪切板：macOS=pbcopy(unnamedplus，双向)；Linux=OSC52 只同步 yank 方向。
-- Linux 故意不设 unnamedplus：SSH 无 paste provider，设了会让 p 失灵。详见 tools/neovim.md
if vim.fn.has("mac") == 1 then
  o.clipboard = "unnamedplus,unnamed"
else
  vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
      if vim.v.event.operator ~= "y" then return end
      local b64 = vim.fn.system({ "base64" }, table.concat(vim.v.event.regcontents, "\n"))
      if vim.v.shell_error ~= 0 then return end
      local osc52 = ("\27]52;c;%s\7"):format(b64:gsub("[\r\n]", ""))
      local tty = io.open("/dev/tty", "w")
      if tty then
        tty:write(osc52); tty:flush(); tty:close()
      else
        io.stdout:write(osc52); io.stdout:flush()
      end
    end,
  })
end
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
