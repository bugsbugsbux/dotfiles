-- Startscreen: https://github.com/mhinz/vim-startify

vim.g.startify_relative_path = 1
vim.g.startify_custom_header = ''
vim.g.startify_lists = {
    {type = 'dir', header = {'   MRU in ' .. vim.fn.getcwd()}},
    {type = 'files', header = {'   MRU'}},
    {type = 'bookmarks', header = {'   Bookmarks'}},
}
vim.g.startify_bookmarks = (function()
    -- `{mapping = "path"},`
    -- or just: `"path",`
    if require('user.utils.helpers').is_platform_windows() then
        return {
            {['ß'] = vim.fn.expand("~/AppData/Local/Temp")},
            {F = vim.fn.expand("~/repos/bb/conf/config/fish/")},
            {N = vim.fn.expand("~/repos/bb/conf/config/nvim/lua/user/")},
            {S = vim.fn.expand("~/repos/bb/conf/config/sway/config")},
            {T = vim.fn.expand("~/repos/bb/conf/config/tmux/tmux.conf")},
            {W = vim.fn.expand("~/wiki/")},
        }
    else
        return {
            {['ß'] = "/tmp/"},
            {F = vim.fn.expand("~/.config/fish/")},
            {N = vim.fn.expand("~/.config/nvim/lua/user/")},
            {S = vim.fn.expand("~/.config/sway/config")},
            {T = vim.fn.expand("~/.config/tmux/tmux.conf")},
            {W = vim.fn.expand("~/wiki/")},
        }
    end
end)()
