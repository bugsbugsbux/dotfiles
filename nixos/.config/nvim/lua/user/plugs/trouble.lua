-- Unified :cc, :ll, diagnostics, etc https://github.com/folke/trouble.nvim

require('trouble').setup{
    position = "bottom",
    height = 5,
    icons = {
        indent = {
            fold_open = '▲',
            fold_closed = '▼',
        },
    },
    open_no_results = true,
    modes = {
        diagnostics_buffer = {
            mode = "diagnostics", -- inherit from diagnostics mode
            filter = { buf = 0 },
        },
    },
}
