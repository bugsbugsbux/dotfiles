-- Documentation: https://wezfurlong.org/wezterm/config/lua/config/index.html

local wezterm = require('wezterm')

local config = {}

config.font = wezterm.font('Monego')
-- for different fallbacks use instead:
--config.font = wezterm.font_with_fallback({})
config.strikethrough_position = '150%' -- adjusted for Monego font
config.font_size = 14
--config.cell_width = 1.1 -- does not center glyph, breaks ligatures
--config.line_height = 1.2

config.audible_bell = 'Disabled'
config.visual_bell = {
    fade_in_duration_ms = 0,
    fade_out_duration_ms = 100,
    fade_out_function = 'Linear',
}
config.colors = {visual_bell = '#fff'}

--config.window_background_opacity = 0.75
-- See available Colorschemes at: https://wezfurlong.org/wezterm/colorschemes/index.html
---- Dark themes ----
config.color_scheme = 'Catppuccin Mocha'
---- Light Themes ----
--config.color_scheme = 'Catppuccin Latte'
--config.color_scheme = 'Alabaster'

config.window_padding = { left=0, right=0, top=0, bottom=0 }

config.scrollback_lines = 0
--config.enable_scroll_bar = true
--config.min_scroll_bar_height = '2cell'

config.hide_tab_bar_if_only_one_tab = true

config.key_map_preference = 'Mapped' -- specify key according to layout not us-keyboard
config.disable_default_key_bindings = true
config.keys = {
    --{ mods='ALT', key='l', action=wezterm.action.ShowDebugOverlay},
    { mods='CTRL|SHIFT', key='c', action=wezterm.action.CopyTo('Clipboard') },
    { mods='CTRL|SHIFT', key='v', action=wezterm.action.PasteFrom('Clipboard') },
    { mods='CTRL', key='+', action=wezterm.action.IncreaseFontSize },
    { mods='CTRL', key='-', action=wezterm.action.DecreaseFontSize },
    { mods='CTRL|SHIFT', key='=', action=wezterm.action.ResetFontSize },
}

return config
