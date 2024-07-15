-- Tokyonight colorscheme: https://github.com/folke/tokyonight.nvim

-- Available styles from lightest to darkest (`:colorscheme tokyonight-<style>`):
-- 'day'
-- 'storm'
-- 'moon'
-- 'night'

require('tokyonight').setup({
    style = 'night',
    light_style = 'day',
    styles = {
        comments = { italic = true },
    },
    dim_inactive = true,
    --day_brightness = 0.3, -- default 0.3
})
