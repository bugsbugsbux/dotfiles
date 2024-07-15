-- Material colorscheme: https://github.com/marko-cerovac/material.nvim

-- Available styles from lightest to darkest
-- 'lighter'            (white)
-- 'oceanic'            (green-blue)
-- 'palenight'          (dark purple)
-- 'darker'             (dark gray)
-- 'deep ocean' (sic)   (black-blue)
vim.g.material_style = 'deep ocean'

require('material').setup{
    styles = {
        comments = { italic = true },
    },
    high_visibility = {
        lighter = true,
    },
    disable = {
        colored_cursor = true,
    },
}

local material_group = {
    selected = { light = 'material-lighter', dark = 'material-palenight' },
    variants = {
        light = { 'material', 'material-lighter'},
        dark = {
            'material',
            'material-oceanic',
            'material-palenight',
            'material-darker',
            'material-deep-ocean'
        },
    },
    custom_switches = {
        material = function(light_or_dark)
            local shared = require('user.lightswitch.shared')
            if light_or_dark == 'light' then
                vim.cmd('colorscheme ' .. shared.themes.material.selected.light)
            else
                vim.cmd('colorscheme ' .. shared.themes.material.selected.dark)
            end
        end,
    },
}

local themes = require('user.colorschemes')
themes['material-lighter'] = material_group
themes['material'] = material_group
themes['material-oceanic'] = material_group
themes['material-palenight'] = material_group
themes['material-darker'] = material_group
themes['material-deep-ocean'] = material_group
