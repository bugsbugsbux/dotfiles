local M = {}

function M.bootstrap()
    local path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
    if not vim.loop.fs_stat(path) then
        vim.notify(
            'Installing lazy.nvim ...',
            vim.log.levels.INFO,
            { title = 'USER: user.utils.lazy.bootstrap()' }
        )
        vim.fn.system({
            'git',
            'clone',
            '--filter=blob:none',
            'https://github.com/folke/lazy.nvim.git',
            '--branch=stable', -- latest stable release
            path,
        })
    end
    vim.opt.rtp:prepend(path)
end

return M
