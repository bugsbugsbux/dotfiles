local M = {}

function M.bootstrap()
    local path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if not vim.loop.fs_stat(path) then
        vim.notify(
            'Installing packer.nvim ...',
            vim.log.levels.INFO,
            { title = "USER: user.utils.packer.bootstrap()" }
        )
        vim.fn.system({
            'git',
            'clone',
            '--depth=1',
            'https://github.com/wbthomason/packer.nvim.git',
            path,
        })
        vim.cmd('packadd packer.nvim')
    end
end

return M
