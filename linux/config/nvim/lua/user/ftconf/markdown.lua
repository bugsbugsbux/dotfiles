return function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 2
    vim.bo.syntax = "markdown"
    vim.wo.spell = true
    vim.bo.textwidth = 72
    vim.wo.colorcolumn = "73"
    -- While concealing: conceal current line only in normal-mode
    vim.wo.concealcursor = 'nc'
    -- But by default disable all concealing:
    vim.wo.conceallevel = 0
end
