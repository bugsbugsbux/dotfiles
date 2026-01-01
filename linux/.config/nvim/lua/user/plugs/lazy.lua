local desc = {
    loaded = '[ON]',
    not_loaded = '[OFF]',
    lazy = '[WAIT]',
    cmd = '[onCommand]',
    event = '[onEvent]',
    ft = '[onFt]',
    keys = '[onKey]',

    config = '[Conf]',
    init = '[Init]',
    import = '[Import]',
    plugin = '[Plugin]',
    runtime = '[Runtime]',
    source = '[Source]',
    start = '[Start]',
    task = '[Task]',

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
        icons = desc,
    },
    performance = {
        rtp = {
            paths = {
                vim.fn.stdpath('data') .. '/site', -- otherwise doesnt find spellfiles
            }
        },
    },
    dev = {
        path = "~/nvimdev",
        patterns = {'bugsbugsbux'},
        fallback = true,
    },
}
