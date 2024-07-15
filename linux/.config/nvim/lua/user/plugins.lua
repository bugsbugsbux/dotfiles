require('user.utils.lazy').bootstrap()

local settings = require('user.plugs.lazy')

local _cmp_buffer = 'hrsh7th/cmp-buffer'
local _cmp_cmdline = 'hrsh7th/cmp-cmdline'
local _cmp_luasnip = 'saadparwaiz1/cmp_luasnip'
local _cmp_nvim_lsp = 'hrsh7th/cmp-nvim-lsp'
local _cmp_nvim_lsp_signature_help = 'hrsh7th/cmp-nvim-lsp-signature-help'
local _cmp_nvim_lua = 'hrsh7th/cmp-nvim-lua'
local _cmp_path = 'hrsh7th/cmp-path'
local _luasnip = 'L3MON4D3/LuaSnip'
local _mason_lspconfig_nvim = 'williamboman/mason-lspconfig.nvim'
local _mason_nvim = 'williamboman/mason.nvim'
local _mason_nvim_dap_nvim = 'jayp0521/mason-nvim-dap.nvim'
local _nvim_lspconfig = 'neovim/nvim-lspconfig'
local _plenary_nvim = 'nvim-lua/plenary.nvim'
local conform_nvim = 'stevearc/conform.nvim'
local d2_vim = 'terrastruct/d2-vim'
local dart_vim_plugin = 'dart-lang/dart-vim-plugin'
local diffconflicts = 'whiteinge/diffconflicts'
local dressing_nvim = 'stevearc/dressing.nvim'
local fidget_nvim = 'j-hui/fidget.nvim'
local flatten_nvim = 'willothy/flatten.nvim'
local hex_nvim = 'RaafatTurki/hex.nvim'
local lightswitch = 'herrvonvoid/lightswitch'
local lualine_nvim = 'nvim-lualine/lualine.nvim'
local material_nvim = 'marko-cerovac/material.nvim'
local neoconf_nvim = 'folke/neoconf.nvim'
local nvim_cmp = 'hrsh7th/nvim-cmp'
local nvim_dap = 'mfussenegger/nvim-dap'
local nvim_dap_ui = 'rcarriga/nvim-dap-ui'
local nvim_lint = 'mfussenegger/nvim-lint'
local nvim_treesitter = 'nvim-treesitter/nvim-treesitter'
local oil_nvim = 'stevearc/oil.nvim'
local schemastore_nvim = 'b0o/SchemaStore.nvim'
local sendline = 'herrvonvoid/sendline'
local spotter = 'herrvonvoid/spotter'
local telescope_nvim = 'nvim-telescope/telescope.nvim'
local tokyonight_nvim = 'folke/tokyonight.nvim'
local trouble_nvim = 'folke/trouble.nvim'
local undotree = 'mbbill/undotree'
local vim_signify = 'mhinz/vim-signify'
local vim_snippets = 'honza/vim-snippets'
local vim_startify = 'mhinz/vim-startify'
local vim_table_mode = 'dhruvasagar/vim-table-mode'
local vscode_nvim = 'Mofiqul/vscode.nvim'

-- OTHER THAN THIS LAZY.NVIM SETTINGS SHOULD BE SET IN PLUGS/LAZY.LUA
-- if nvim is opened from a neovim terminal: only load flatten.nvim
settings = vim.tbl_deep_extend('force', settings, {
    defaults = {
        cond = function(plugin)
            if os.getenv('NVIM') ~= nil then
                if (plugin[1] or '') ~= flatten_nvim then
                    return false
                end
                return true
            end
            return true
        end,
    }
})

require('lazy').setup({

    -- prevent nested neovim instances
    {
        flatten_nvim,
        priority = 2000,
        lazy = false,
        opts = require('user.plugs.flatten'),
    },

    -- respect project local configs (such as .vscode/settings.json)
    {
        neoconf_nvim,
        priority = 1000, -- should run as soon as possible
        lazy = false,
        dependencies = { _nvim_lspconfig },
        config = function()
            require('user.plugs.neoconf')
        end,
    },

    -- snippet support
    {
        _luasnip,
        lazy = true,
        build = 'make install_jsregexp',
        dependencies = {
            _cmp_luasnip,
            -- snippet sources
            vim_snippets,
        }
    },
    -- completion
    {
        nvim_cmp,
        event = {'InsertEnter', 'CmdlineEnter'},
        dependencies = {
            _cmp_buffer,
            _cmp_path,
            _cmp_cmdline,
            _cmp_nvim_lsp,
            _cmp_nvim_lua,
            _cmp_nvim_lsp_signature_help,
            -- cmp requires a snippet engine:
            _luasnip,
        },
        config = function()
            require('user.core.completion')
        end,
    },

    -- treesitter
    {
        nvim_treesitter,
        build = ':TSUpdate',
        config = function()
            require('user.core.treesitter')
        end,
    },

    -- installer
    {
        _mason_nvim,
        dependencies = {
            neoconf_nvim, -- not a dependency, just needs to run before mason
        },
        config = function()
            require('user.plugs.mason')
        end,
    },

    -- lsp
    { _mason_lspconfig_nvim, dependencies = { _mason_nvim } },
    { _nvim_lspconfig, dependencies = { _mason_lspconfig_nvim } },
    {
        name = 'meta_package_lsp',
        dir = vim.fn.stdpath('config') .. '/lua/fake_plugins/1',
        dependencies = {
            _nvim_lspconfig,
            --TODO: remove this dependency:
            _cmp_nvim_lsp,
        },
        config = function()
            require('user.core.lsp')
        end,
    },
    -- linting
    {
        nvim_lint,
        config = function()
            require('user.core.linters')
        end,
    },
    -- formatting
    {
        conform_nvim,
        config = function()
            require('user.core.formatting')
        end,
    },

    -- dap
    { _mason_nvim_dap_nvim, dependencies = { _mason_nvim } },
    {
        nvim_dap,
        dependencies = { _mason_nvim_dap_nvim },
        config = function()
            require('user.core.dap')
        end,
    },
    {
        nvim_dap_ui,
        lazy = true,
        dependencies = { nvim_dap },
        config = function()
            require('user.plugs.dapui')
        end,
    },

    -- Improve editing of:
    -- diffs: replaces three-way with two-way diffs
    { diffconflicts },
    -- dart, flutter
    {
        dart_vim_plugin,
        ft = 'dart',
        config = function()
            require('user.plugs.dartvim')
        end,
    },
    -- ascii tables
    {
        vim_table_mode,
        cmd = {'TableModeEnable', 'TableModeToggle'},
        ft = {'text', 'rst', 'markdown', 'pandoc.markdown', 'rmd'},
    },
    -- d2
    { d2_vim, ft = 'd2' },
    -- json (requires jsonls): complete, check items with project's json-schema
    { schemastore_nvim },
    -- hex files: requires `xxd` from aur/xxd-standalone or a vim installation
    {
        hex_nvim,
        config = function()
            require('user.plugs.hex')
        end,
    },

    -- UI/UX
    -- startscreen
    {
        vim_startify,
        config = function()
            require('user.plugs.startify')
        end,
    },
    -- statusline
    {
        lualine_nvim,
        config = function()
            require('user.plugs.lualine')
        end,
    },
    -- lsp status/progress indicator
    {
        fidget_nvim,
        config = function()
            require('user.plugs.fidget')
        end,
    },
    -- easily spot the targets for f/t/F/T motions
    {
        spotter,
        dev = false,
        config = function()
            require('user.plugs.spotter')
        end
    },
    -- input and selection provider
    {
        dressing_nvim,
        config = function()
            require('user.plugs.dressing')
        end,
    },
    -- unified :cc, :ll, diagnostics, etc window
    {
        trouble_nvim,
        cmd = {'Trouble', 'TroubleToggle'},
        config = function()
            require('user.plugs.trouble')
        end,
    },
    -- file manager
    {
        oil_nvim,
        config = function()
            require('user.plugs.oil')
        end,
    },
    -- improve undo history
    {
        undotree,
        cmd = {'UndotreeToggle', 'UndotreeShow'},
        keys = require('user.maps').lazy_activators.undotree,
        config = function()
            require('user.plugs.undotree')
        end,
    },
    -- picker
    {
        telescope_nvim,
        dependencies = { _plenary_nvim },
        config = function()
            require('user.plugs.telescope')
        end,
    },
    -- send code lines to (nvim) terminal
    {
        sendline,
        dev = false,
        cmd = {'Sendline', 'SendlineConnect'},
        event = 'TermOpen',
        config = function()
            require('sendline')
            require('user.plugs.sendline') ---@diagnostic disable-line:different-requires
        end
    },
    -- switch colorscheme brightness
    {
        lightswitch,
        dev = false,
        event = 'User LazyDone',
        config = function()
            ---@diagnostic disable-next-line:different-requires
            require('user.plugs.lightswitch')
        end
    },

    -- ETC
    -- version control integration
    { vim_signify },

    -- colorschemes
    {
        'EdenEast/nightfox.nvim',
        lazy = false,
        config = function() require('user.colorschemes.nightfox') end,
    },
    {
        'marko-cerovac/material.nvim',
        lazy = false,
        config = function() require('user.colorschemes.material') end,
    },
    {
        'Mofiqul/vscode.nvim',
        lazy = false,
        config = function() require('user.colorschemes.vscode') end,
    },
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        lazy = false,
        config = function() require('user.colorschemes.catppuccin') end,
    },

}, settings)
