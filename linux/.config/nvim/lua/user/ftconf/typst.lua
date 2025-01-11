return function()
    vim.bo.textwidth = 72
    vim.wo.colorcolumn = "+1"
    vim.bo.expandtab = true
    vim.wo.spell = true
    vim.bo.makeprg = "typst compile %"
end
