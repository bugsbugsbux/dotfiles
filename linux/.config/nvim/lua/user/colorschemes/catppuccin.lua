require('catppuccin').setup{}

local catppuccin_group = {
    selected = { light = 'catppuccin-latte', dark = 'catppuccin-mocha' },
    variants = {
        light = {
            'catppuccin',
            'catppuccin-latte',
        },
        dark = {
            'catppuccin',
            'catppuccin-frappe',
            'catppuccin-macchiato',
            'catppuccin-mocha',
        },
    },
}

local themes = require('user.colorschemes')
themes['catppuccin-latte'] = catppuccin_group
themes['catppuccin'] = catppuccin_group
themes['catppuccin-frappe'] = catppuccin_group
themes['catppuccin-macchiato'] = catppuccin_group
themes['catppuccin-mocha'] = catppuccin_group
