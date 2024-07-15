local desc = {
    cmd = 'Cmd:',
    config = 'Conf:',
    event = 'Event:',
    ft = 'Ft:',
    init = 'Init:',
    import = 'Imp:',
    keys = 'Keys:',
    lazy = 'Lazy:',
    loaded = 'Activ:',
    not_loaded = 'Deact:',
    plugin = 'Plug',
    runtime = 'Runtime:',
    source = 'Src:',
    start = 'Start:',
    task = 'Task:',
    list = { '-', '|' },
}
local simple = {
    cmd = '>_',
    config = '§',
    event = '(!)',
    ft = '*/',
    import = '<-',
    init = '|->',
    keys = '#',
    lazy = '[~]',
    loaded = '[+]',
    not_loaded = '[-]',
    plugin = '@',
    runtime = '://',
    source = '</>',
    start = '->',
    task = '[_]',
    list = { ' ' },
}

return {
    -- defaults.cond WILL BE OVERRIDDEN IN user.plugins
    ui = {
        border = 'rounded',
        icons = simple,
    },
    performance = {
        rtp = {
            paths = {
                vim.fn.stdpath('data') .. '/site', -- otherwise doesnt find spellfiles
            }
        },
    },
}
