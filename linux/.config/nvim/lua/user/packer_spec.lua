-- install packer.nvim
require('user.utils.packer').bootstrap()

require('packer').startup(function() ---@diagnostic disable-line:different-requires
    --use 'wbthomason/packer.nvim' ---@diagnostic disable-line

    -- -- respect project local configs (such as .vscode/settings.json)
    -- local neoconf_nvim = {
    --     'folke/neoconf.nvim',
    --     requires = 'neovim/nvim-lspconfig',
    --     config = function() require('user.plugs.neoconf') end,
    -- }

    -- -- snippets
    -- local _cmp_luasnip = {'saadparwaiz1/cmp_luasnip'}
    -- local _luasnip = {'L3MON4D3/LuaSnip', run = {'make install_jsregexp'}, requires = _cmp_luasnip}
    -- -- snippet sources
    -- local vim_snippets = {'honza/vim-snippets', requires = _luasnip}
    -- -- completion
    -- local _cmp_buffer = {'hrsh7th/cmp-buffer'}
    -- local _cmp_path = {'hrsh7th/cmp-path'}
    -- local _cmp_cmdline = {'hrsh7th/cmp-cmdline'}
    -- local _cmp_nvim_lsp = {'hrsh7th/cmp-nvim-lsp'}
    -- local _cmp_nvim_lsp_signature_help = {'hrsh7th/cmp-nvim-lsp-signature-help'}
    -- local _cmp_nvim_lua = {'hrsh7th/cmp-nvim-lua'}
    -- local nvim_cmp = {
    --     'hrsh7th/nvim-cmp',
    --     requires = {
    --         _cmp_buffer, _cmp_path, _cmp_cmdline, _cmp_nvim_lsp, _cmp_nvim_lua,
    --         _cmp_nvim_lsp_signature_help,
    --         -- cmp requires a snippet engine:
    --         _luasnip
    --     },
    --     config = function() require('user.core.completion') end,
    -- }

    -- Treesitter
    -- local nvim_treesitter = {'nvim-treesitter/nvim-treesitter',
    --     run = ':TSUpdate', config = function() require('user.core.treesitter') end, }
    -- local playground = {'nvim-treesitter/playground', requires = nvim_treesitter}

    -- tool installer
    -- local _mason_nvim = {'williamboman/mason.nvim', config = function() require('user.plugs.mason') end, }
    -- some helpers, often requried
    -- local _plenary_nvim = {'nvim-lua/plenary.nvim'}


    -- -- LSP
    -- local _mason_lspconfig_nvim = {
    --     'williamboman/mason-lspconfig.nvim', requires = _mason_nvim}
    -- local nvim_lspconfig = {'neovim/nvim-lspconfig', requires = {_mason_lspconfig_nvim}}
    -- local _mason_null_ls_nvim = {'jayp0521/mason-null-ls.nvim', requires = _mason_nvim}
    -- local null_ls_nvim = {'jose-elias-alvarez/null-ls.nvim', requires = {_plenary_nvim,
    --     _mason_null_ls_nvim,
    -- }}
    -- local pkg_grp_lsp = {'../pkg_grp_lsp',
    --     requires = { nvim_lspconfig , null_ls_nvim, neoconf_nvim,
    --     --TODO: remove this dependency:
    --     _cmp_nvim_lsp,
    --     },
    --     config = function() require('user.core.lsp') end,
    -- }
    -- -- DAP
    -- local _mason_nvim_dap_nvim = {'jayp0521/mason-nvim-dap.nvim', requires = _mason_nvim}
    -- local nvim_dap = {'mfussenegger/nvim-dap', requires = {_mason_nvim_dap_nvim},
    --     config = function() require('user.core.dap') end,
    -- }
    -- local nvim_dap_ui = {'rcarriga/nvim-dap-ui', requires = nvim_dap}

    -- -- improve editing of
    -- -- diffs: replaces three-way with two-way diffs
    -- local diffconflicts = {'whiteinge/diffconflicts'}
    -- -- dart, flutter
    -- local dart_vim_plugin = {'dart-lang/dart-vim-plugin', config = function()
    --     require('user.plugs.dartvim') end,}
    -- -- text, markdown
    -- local vim_table_mode = {'dhruvasagar/vim-table-mode'}
    -- -- d2
    -- local d2_vim = {'terrastruct/d2-vim'}
    -- -- json (requires jsonls): complete, check items with projects json-schema
    -- local schemastore_nvim = {'b0o/SchemaStore.nvim'}
    -- -- hex files: requires `xxd` from aur/xxd-standalone or a vim installation
    --local hex_nvim = {'RaafatTurki/hex.nvim', config = function() require('user.plugs.hex') end}

    -- -- startscreen
    -- local vim_startify = {'mhinz/vim-startify', config = function() require('user.plugs.startify') end, }
    -- -- statusline
    -- local lualine_nvim = {'nvim-lualine/lualine.nvim', config = function() require('user.plugs.lualine') end,}
    -- -- unified :cc, :ll, diagnostics, etc window
    -- local trouble_nvim = {'folke/trouble.nvim', config = function() require('user.plugs.trouble') end,}
    -- -- file manager
    -- local oil_nvim = {'stevearc/oil.nvim', config = function() require('user.plugs.oil') end}
    -- -- improve undo history
    -- local undotree = {'mbbill/undotree', function() require('user.plugs.undotree') end,)
    -- -- picker
    -- local telescope_nvim = {'nvim-telescope/telescope.nvim', requires = _plenary_nvim,
    --    config = function() require('user.plugs.telescope' end,)
    -- -- version control integration
    -- local vim_signify = {'mhinz/vim-signify'}
    -- -- analyze startuptime
    -- local vim_startuptime = {'dstein64/vim-startuptime'}

    -- -- colorschemes
    -- local vscode_nvim = {'Mofiqul/vscode.nvim'}
    -- local material_nvim = {'marko-cerovac/material.nvim'}
    -- local tokyonight_nvim = {'folke/tokyonight.nvim'}

    use { ---@diagnostic disable-line
        'wbthomason/packer.nvim',
        --_plenary_nvim, -- I want to have it available even when no plugins require it
        --- -- local settings
        --neoconf_nvim,
        --- -- completion
        --- nvim_cmp,
        --- -- snippet sources
        --- vim_snippets,
        --- -- treesitter
        --- nvim_treesitter, playground,
        --- -- language servers
        ---nvim_lspconfig, null_ls_nvim,
        --pkg_grp_lsp,
        --- -- debuggers
        ---nvim_dap, nvim_dap_ui,
        --- -- language/ft editing improvements
        --- diffconflicts, dart_vim_plugin, vim_table_mode, d2_vim,
        --- schemastore_nvim, hex_nvim,
        --- -- editor features
        --- vim_startify, lualine_nvim, trouble_nvim, undotree, telescope_nvim, vim_signify,
        ---     vim_startuptime, oil_nvim,
        --- -- colorschemes
        --- vscode_nvim, material_nvim, tokyonight_nvim,
    }

end)

-- -- load configs
-- require('user.plugs.wiking')
