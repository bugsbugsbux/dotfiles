require('dressing').setup({
    input = {
        border = 'rounded',
        mappings = require('user.maps').dressing.input,
    },
    select = {
        builtin = {
            mappings = require('user.maps').dressing.select.builtin,
        },
    },
})
