require('spotter').setup{
    use_default_maps = false,
    inject_on_show = function(opts)
        vim.wo.cursorline = false
        vim.o.cursorcolumn = true
    end,
    inject_on_hide = function(opts)
        vim.wo.cursorline = true
        vim.o.cursorcolumn = false
    end,
}

require('user.maps').setup_spotter_maps()
