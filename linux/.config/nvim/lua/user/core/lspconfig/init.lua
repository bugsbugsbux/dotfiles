return function(default_on_attach, capabilities)

-- AFTER mason.setup(), BEFORE lspconfig[<server>].setup()
require('mason-lspconfig').setup{
    -- use LSPCONFIG-SERVER-NAMES here!
    ensure_installed = {
        -- for vim config files:
        'vimls',
        'lua_ls',
        --
        'jsonls', -- for schemastore.nvim
    },
}

-- non-mason-installed LSPs: AFTER mason-lspconfig.setup()
require('user.core.lspconfig.non_mason')(default_on_attach, capabilities)

-- mason-installed LSPs:
require('user.core.lspconfig.mason')(default_on_attach, capabilities)

end
