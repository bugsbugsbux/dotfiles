return function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 2
    vim.wo.colorcolumn = "81"
    vim.bo.syntax = 'dart'

    -- No filename specified here as only the one containing main is valid
    -- and dart finds this one itself as long as you are in a dart project.
    -- Flutter is not handled, since you would not want to run flutter
    -- projects like this anyways.
    vim.bo.makeprg = "dart run"
end
