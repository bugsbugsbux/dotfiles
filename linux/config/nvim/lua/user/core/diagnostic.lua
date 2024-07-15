-- This sets the *global* diagnostic config which can be
-- overridden by a namespace-wide config which can be
-- overridden by ephemeral (per call) config.

vim.diagnostic.config({
    virtual_text = false,
    severity_sort = true,
    float = {
        focusable = false,
        border = 'rounded',
        header = '',
        source = false,
    },
})

require('user.maps').setup_diagnostic_maps()
