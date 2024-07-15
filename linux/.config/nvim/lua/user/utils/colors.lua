local M = {}

---Is a light/bright theme wanted? Determined via the environment variable VIMTHEME.
---@return boolean
function M.wants_bright_theme()
    return vim.env.VIMTHEME == 'light' or vim.env.VIMTHEME == 'bright'
end

---@return nil
function M.set_bg_from_env()
    if M.wants_bright_theme() then
        vim.go.background = 'light'
    else
        vim.go.background = 'dark'
    end
end

return M
