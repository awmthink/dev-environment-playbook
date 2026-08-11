-- Neovim 极简配置：读代码 + LSP，0 插件（纯 nvim 0.11+ 原生）
-- 高亮：内置 syntax（不依赖 treesitter，避开 tree-sitter CLI / glibc 问题）
-- fuzzy：:grep(rg) + quickfix（不用 telescope）
-- 写代码交给 coding agent（opencode / claude-code / codex / qoder-cli）

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
-- grep 走 ripgrep（结果进 quickfix）
o.grepprg = "rg --vimgrep --no-heading --smart-case"
o.grepformat = "%f:%l:%c:%m,%f:%l:%m"

-- ===== LSP server 配置（手写，不依赖 lspconfig 插件）=====
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
})
vim.lsp.config("clangd", {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
})
vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.mod", ".git" },
})
vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml" },
})
vim.lsp.config("vtsls", {
  cmd = { "vtsls", "--stdio" },
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact", "vue" },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
})
vim.lsp.enable({ "pyright", "clangd", "gopls", "rust_analyzer", "vtsls" })

-- ===== 读代码键位（LSP attach 后 buffer-local）=====
vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP 读代码键位",
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end
    map("gd", vim.lsp.buf.definition, "goto definition")
    map("gr", vim.lsp.buf.references, "references")
    map("gD", vim.lsp.buf.declaration, "goto declaration")
    map("gi", vim.lsp.buf.implementation, "goto implementation")
    map("gy", vim.lsp.buf.type_definition, "goto type definition")
    map("K", vim.lsp.buf.hover, "hover doc")
    map("<leader>rn", vim.lsp.buf.rename, "rename")
    map("<leader>ca", vim.lsp.buf.code_action, "code action")
    map("[d", function() vim.diagnostic.jump({ count = -1, float = false }) end, "prev diagnostic")
    map("]d", function() vim.diagnostic.jump({ count = 1, float = false }) end, "next diagnostic")
    map("<leader>e", function() vim.diagnostic.open_float() end, "line diagnostics")
    map("gq", function() vim.diagnostic.setloclist() end, "diagnostic list")
  end,
})

-- 诊断样式
vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 4 },
  signs = true,
  underline = true,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
})

-- ===== 通用键位 =====
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })
-- grep（输入 pattern 后结果进 quickfix，:copen / <leader>co 查看）
vim.keymap.set("n", "<leader>fg", ":silent grep!<space>", { desc = "grep (rg → quickfix)" })
vim.keymap.set("n", "<leader>co", "<cmd>copen<cr>", { desc = "open quickfix" })
vim.keymap.set("n", "<leader>q", "<cmd>qa<cr>", { desc = "Quit all" })
