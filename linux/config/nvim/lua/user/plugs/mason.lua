-- Installer for LSPs, DAPs, Linters, Formatters: https://github.com/williamboman/mason.nvim

-- neoconf.setup() has to run BEFORE mason.setup()
--require('user.plugs.neoconf')

-- AFTER neoconf.setup(), BEFORE {mason-lspconfig,mason-null-ls,mason-nvim-dap}.setup()
require('mason').setup{
    ui = {
        border = 'rounded',
    },
}
