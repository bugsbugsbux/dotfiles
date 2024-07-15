-- https://github.com/rcarriga/nvim-dap-ui

require('dapui').setup{
    icons = {
        collapsed = '▼',
        expanded = '▲',
    },
    mappings = require('user.maps').dap.dapui_maps,
}
