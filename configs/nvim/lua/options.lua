-- 读代码友好的默认选项
local o = vim.opt

o.number = true            -- 行号
o.relativenumber = true    -- 相对行号（行间跳转方便）
o.signcolumn = "yes"       -- 始终显示 sign 列（诊断稳定，不抖动）
o.expandtab = true
o.tabstop = 2
o.shiftwidth = 2
o.smartindent = true
o.smartcase = true         -- 搜索：含大写则敏感，否则忽略大小写
o.ignorecase = true
o.wrap = false             -- 长行不换行（读代码友好）
o.scrolloff = 8            -- 光标距屏幕边缘留白
o.sidescrolloff = 12
o.updatetime = 250         -- LSP 诊断 / CursorHold 更新
o.splitright = true        -- 新窗口开在右 / 下
o.splitbelow = true
o.termguicolors = true
o.cursorline = true
o.foldmethod = "expr"      -- treesitter 折叠
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldlevel = 99           -- 默认全展开
o.mouse = "a"
