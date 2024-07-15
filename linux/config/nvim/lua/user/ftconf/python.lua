return function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 4
    vim.wo.colorcolumn = "80,89"  -- pep8 (79), black (88)
end
