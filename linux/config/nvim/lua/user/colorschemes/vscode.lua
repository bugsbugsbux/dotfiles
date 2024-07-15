-- VSCode-like colorscheme: https://github.com/Mofiqul/vscode.nvim

require('vscode').setup({
    italic_comments = true,
})

local group = {
    variants = { dark = {'vscode'}, light = {'vscode'} },
    selected = { dark = 'vscode', light = 'vscode' },
    -- here's a demo for a custom switch function:
    --custom_switch = {
    --    vscode = function(light_or_dark)
    --        vim.notify('hi from custom switch')
    --        vim.cmd('colorscheme vscode')
    --        require('vscode').load(light_or_dark)
    --        require('user.lightswitch').setstate(light_or_dark)
    --    end,
    --},
}

-- register
local themes = require('user.colorschemes')
themes['vscode'] = group
