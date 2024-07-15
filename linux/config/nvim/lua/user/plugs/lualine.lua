-- A status line: https://github.com/nvim-lualine/lualine.nvim

-- Make sure colorschemes are setup already

require('lualine').setup({
    options = {
        icons_enabled = false,
        component_separators = "",
        section_separators = "",
    },
    sections = {
        lualine_x = {
            'encoding',
            'filetype',
            function()  -- only show fileformat when it's not 'unix'
                if vim.bo.fileformat ~= 'unix'
                    then return vim.bo.fileformat
                    else return ''
                end
            end,
        },
    },
})

-- Don't show current editing mode in cmdline while I already have
-- a statusline showing it. Keep this after calling the plugin so
-- it won't run if the plugin `require` fails...
vim.o.showmode = false
