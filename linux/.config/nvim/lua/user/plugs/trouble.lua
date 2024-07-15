-- Unified :cc, :ll, diagnostics, etc https://github.com/folke/trouble.nvim

require('trouble').setup{
    mode = "document_diagnostics",
    position = "bottom",
    height = 5,
    icons = false,
    fold_open = '▲',
    fold_closed = '▼',
    signs = {
        error = 'Ⓔ',
        warning = 'Ⓦ',
        hint = 'Ⓗ',
        information = 'ⓘ',
        other = '?'
    },
}
