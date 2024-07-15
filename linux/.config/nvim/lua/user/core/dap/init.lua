-- Debug Adapter Protocol: https://github.com/mfussenegger/nvim-dap

-- NOTE: dap setup must run after mason.setup() If your plugin manager can't handle
-- this uncomment the next line:
--require('user.plugs.mason')
require('mason-nvim-dap').setup({
    -- mason-installed DAPs:
    handlers = require('user.core.dap.mason'),
})

-- non-mason-installed DAPs:
require('user.core.dap.non_mason')
