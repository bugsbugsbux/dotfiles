local core = require('user.updent.core')

local M = {}

local augroup = vim.api.nvim_create_augroup('Updent', {clear=true})

function M.activate()

    vim.api.nvim_create_autocmd({'BufEnter', 'BufWinEnter'}, {
        pattern = {'*'},
        group = augroup,
        callback = function()
            core.update_listchars()
        end,
    })

    vim.api.nvim_create_autocmd({'OptionSet'}, {
        pattern = {'shiftwidth', 'tabstop'},
        group = augroup,
        callback = function(event)
            -- NOTE: global changes to sw or ts do not effect existing buffers
            if vim.v.option_command == 'set' or vim.v.option_command == 'setlocal' then
                local buf = event.buf
                if buf == 0 then
                    buf = vim.api.nvim_get_current_buf()
                end
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    if vim.api.nvim_win_get_buf(win) == buf then
                        vim.api.nvim_win_call(win, core.update_listchars)
                    end
                end
            end
        end
    })
end

function M.deactivate()
    vim.api.nvim_clear_autocmds(augroup)
end

return M
