require('lint').linters_by_ft = {
    fish = {'fish'},
    python = {'mypy'},
    rst = {'rstcheck'},
}

local augroup = vim.api.nvim_create_augroup('Linting', {clear=true})
-- always lint on this events:
vim.api.nvim_create_autocmd({'BufWritePost', 'BufWinEnter'}, {
    group = augroup,
    callback = function()
        require('lint').try_lint()
    end,
})

--NOTE: register used stdin linters here
-- check: <https://github.com/mfussenegger/nvim-lint/tree/master/lua/lint/linters>
-- Trigger lint on this events only for linters with stdin support:
vim.api.nvim_create_autocmd({'InsertLeave'}, {
    group = augroup,
    callback = function()
        local ft = vim.bo.filetype
        if vim.tbl_contains({
            --'lintername',
        }, ft) then
            require('lint').try_lint()
        end
    end,
})
