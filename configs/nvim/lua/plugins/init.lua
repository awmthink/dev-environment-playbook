-- lazy.nvim bootstrap + 插件 spec
-- 定位：读代码 + LSP；故意不装补全

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- ===== LSP =====
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "clangd", "vtsls", "gopls", "rust_analyzer" },
      })

      -- 读代码核心键位（LSP attach 后 buffer-local）
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

      -- 诊断显示样式
      vim.diagnostic.config({
        virtual_text = { prefix = "●", spacing = 4 },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
      })

      -- nvim 0.11+ 原生 API：启用 LSP servers（默认配置由 lspconfig 提供，不再用 require('lspconfig').setup）
      vim.lsp.enable({ "pyright", "clangd", "gopls", "rust_analyzer", "vtsls" })
    end,
  },

  -- ===== Telescope（fuzzy finder，读代码利器）=====
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>",  desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",   desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",   desc = "Help" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>",  desc = "Document symbols" },
      { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- ===== Treesitter（parser 管理；高亮靠 nvim 0.11+ 内置 vim.treesitter）=====
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      -- nvim 0.11+ 内置 treesitter 高亮 / 缩进（parser 装了即生效）。
      -- nvim-treesitter 插件仅负责 parser 安装管理（:TSInstall / :TSUpdate）。
    end,
  },
}, {
  install = { missing = true },
  checker = { enabled = false },
})
