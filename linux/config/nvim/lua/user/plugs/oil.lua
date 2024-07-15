-- File manager: https://github.com/stevearc/oil.nvim

local oil = require('oil')
local actions = require('oil.actions')

oil.setup{
    columns = {},
    use_default_keymaps = false,
    keymaps = require('user.maps').get_oil_maps(oil, actions),
}

require('user.utils.netrw').disable()
