-- Completion: https://github.com/hrsh7th/nvim-cmp
-- Snippets: https://github.com/L3MON4D3/LuaSnip

vim.o.completeopt = "menu,menuone,noselect"

-- load completion/snippet plugins
local cmp = require('cmp')
local luasnip = require('luasnip')

-- load snippets
require('luasnip.loaders.from_vscode').lazy_load()
require('luasnip.loaders.from_snipmate').lazy_load()

-- Define sources in *one* place (except customizations( remember to deepcopy!))
-- NOTE: make sure vim.o.iskeyword (here represented as \k) includes all the characters
-- you want (such as umlauts)
local src_cmdline = { name = 'cmdline' }
local src_buffer = { name = 'buffer', option = { keyword_pattern = [[\k\+]] }}
local src_path = { name = 'path', option = { keyword_pattern = [[\k\+]] }}
local src_nvim_lua = { name = 'nvim_lua' }
local src_nvim_lsp = { name = 'nvim_lsp' }
local src_nvim_lsp_signature_help = { name = 'nvim_lsp_signature_help' }
local src_luasnip = { name = 'luasnip' }

cmp.setup({
    snippet = {  -- required to specify one!
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    sources = {
        src_nvim_lua,
        src_nvim_lsp,
        src_nvim_lsp_signature_help,
        src_luasnip,
        src_path,
        src_buffer,
    },
    formatting = {
        format = function(entry, vim_item)
            -- name source
            vim_item.menu = ({
                buffer      = "[Buf]",
                cmdline     = "[vim]",
                luasnip     = "[LuaSnip]",
                nvim_lsp    = "[LSP]",
                nvim_lsp_signature_help    = "[Sig]",
                nvim_lua    = "[Lua]",
                path        = "[Path]",
            })[entry.source.name]
            return vim_item
        end,
    },
    mapping = cmp.mapping.preset.insert(
        require('user.maps').get_completion_maps(cmp, luasnip)
    ),
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
})

-- `/` cmdline setup; doesn't work with this plugin's native_menu enabled.
cmp.setup.cmdline({'/', '?'}, { -- search: '/' ... forward, '?' ... backwards
    mapping = cmp.mapping.preset.cmdline({}),
    sources = {src_buffer,},
})

-- `:` cmdline setup: doesn't work with this plugin's native_menu enabled
cmp.setup.cmdline({':', '='}, { -- ':' ... cmd-mode, '=' ... expression-register
    mapping = cmp.mapping.preset.cmdline({}),
    sources = {
        src_cmdline,
        src_nvim_lua,
        src_nvim_lsp_signature_help,
        src_path,
    },
})
