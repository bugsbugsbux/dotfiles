require('user.maps').setup_formatting_maps()

require('conform').setup{
    -- add/change formatters:
    --formatters = {
    --    name = {
    --        inherit = false, -- only use the overrides, without merging
    --        overrides
    --    },
    --},
    notify_on_error = true,
    formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'black' },
        fish = { 'fish_indent' },
    },
}
