local M = {}

---Escape vim-escape-sequences such as <CR>, <ESC>, etc
---@param str string
---@return string
function esc(str)
    vim.validate { str = { str, "s" } }
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end
M.esc = esc

function M.has_feature(feature)
    --- lua counts everything other than false and null as truthy
    --- vim.fn.has returns an int; I tend to forget this
    if vim.fn.has(feature) == 1 then
        return true
    else
        return false
    end
end

function M.is_platform_windows()
    if M.has_feature("win32") then  -- is true on win64 too
        return true
    else
        return false
    end
end

---@param winid? number Integer window-id. Throws if window does not exist! 0 is current
---@return boolean
function M.is_floating_window(winid)
    return '' ~= vim.api.nvim_win_get_config(winid or 0).relative
end

return M
