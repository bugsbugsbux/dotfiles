-- Load helper functions, some of which are globally defined too!
local helpers = require('user.utils.helpers')

-- platform specific stuff
if not helpers.has_feature('linux') then
    if helpers.is_platform_windows() and #vim.fn.argv() == 0 then
        vim.api.nvim_set_current_dir("~")
    end
    vim.o.guifont = "*"  -- Win and OSX font chooser
    --vim.o.guifont = "Cascadia Mono:h12"  -- nice font available on Win11
end

-- de/activate important capabilities
vim.o.errorbells = false -- audible sounds
vim.o.termguicolors = true -- truecolor support
vim.o.mouse = '' -- disable mouse; also disables copy to clipboard, thus:
vim.o.clipboard = 'unnamedplus' -- auto yank to system clipbard "+
-- vim.o.clipboard = 'unnamed' -- auto yank to primary selection "* (middle click)

vim.o.updatetime = 50  -- ms, default=4000 -- CursorHold event and write swap file

-- no swap or backup file
vim.o.swapfile = false
vim.o.backup = false
-- instead undo-files
vim.o.undodir = vim.env.HOME .. "/.local/share/nvim/undo"
vim.o.undofile = true

-- splitting
vim.o.splitright = true
vim.o.equalalways = false -- just split current window in half, don't resize others

-- folding
vim.o.foldenable = false  -- await explicit folding request
vim.o.foldnestmax = 10
--vim.o.foldminlines = 1

-- indents
vim.o.tabstop = 4 -- I like 4-space-indents best.
vim.o.expandtab = true ---Insert \t as spaces instead.
-- The following settings make it possible to simply control the indent behaviour with
-- the above two settings ('tabstop' and 'expandtab')...
vim.o.shiftwidth = 0 ---Copies value of 'tabstop'
vim.o.smarttab = true ---If true \t only indents up to next multiple of 'shiftwidth'
vim.o.shiftround = true ---< and > un/indent not by a but to a 'shiftwidth' multiple
-- Open new line with same indent as previous.
vim.o.autoindent = true
---Try to correctly overindent new lines. Ignored when 'indentexpr' is set.
vim.o.smartindent = false
-- Disable the settings I dont use:
vim.o.softtabstop = 0 -- Disabled. Enabled they often lead to mixed indents.
vim.o.vartabstop = '' -- Disabled. I prefer the same indentwidth for every level.
vim.o.varsofttabstop = '' -- Disabled.

-- scrolling
vim.o.wrap = false
vim.o.scrolloff = vim.fn.shiftwidth()
vim.o.sidescroll = vim.fn.shiftwidth()
vim.o.sidescrolloff = vim.fn.shiftwidth()

-- textwidth
vim.o.textwidth = 72 -- shall be NoFileType setting -> an `au FileType *` negates it
vim.opt.formatoptions:append('t') -- auto-wrap using 'textwidth' setting
vim.o.colorcolumn = '+1'

-- search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch  = true -- search while typing query
vim.o.hlsearch = true

-- line numbers
vim.o.number = true
vim.o.relativenumber = false

-- global statusline: 3, normal: 2
vim.o.laststatus = 2

-- embedded script higlighting for lua, python, ruby
vim.g.vimsyn_embed = "lPr"

-- show whitespace
vim.o.list = true
vim.opt.listchars = {
    -- nice symbols: ¦╌␣·░▒▓█«»◄►◅▻◀▶◁▷❮❯
    nbsp            = "␣",
    --space         = "·",
    multispace      = "·",
    trail           = "·",
    lead            = "¦",
    leadmultispace  = "¦   ",
    conceal         = "░",
    precedes        = "❮",
    extends         = "❯",
    tab             = "╌╌▷",
}

-- spell-checking
vim.o.spell = true  -- shall be NoFileType setting -> an `au FileType *` negates it
vim.o.spelllang = "en"

-- builtin-file-explorer netrw:
vim.g.netrw_banner = 0    -- no banner
vim.g.netrw_liststyle = 3 -- tree view (cycle views with `i`)
vim.g.netrw_altv = true   -- split right
vim.g.netrw_alto = true   -- split below

-- keymaps:
vim.g.mapleader = helpers.esc'<Space>' -- Strangely doesn't work if imported from user.maps
require('user.utils.maps').activate_maps(require('user.maps').global)

-- global diagnostic settings (need to come AFTER setting leader key!)
require('user.core.diagnostic')

-- plugins:
require('user.plugins') -- AFTER settings vim.g.mapleader

-- colorscheme

-- autocmds:
require('user.auto')
