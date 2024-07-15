local M = {}

---Similar to vim.fn.shiftwidth . Lets user specify whether global or which window.
function M.vim_fn_shiftwidth(opts)
    opts = opts or {}
    opts = vim.tbl_extend('force', { global = false, window = 0 }, opts)

    local buf = vim.api.nvim_win_get_buf(opts.window)
    local vimsettings
    if opts.global then
        vimsettings = vim.go
    else
        vimsettings = vim.bo[buf]
    end

    local width = vimsettings.shiftwidth
    if width == 0 then
        return vimsettings.tabstop
    end
    return width
end

-- Return the ranges of the values of lead and leadmultispace in given listchars string.
function M.get_lcs_value_ranges(lcs_string)
    -- NOTE: ',' is not a valid listchar, it is used to separate listchars-items
    -- NOTE: the first ':' in an item is the key-value-separator
    assert(type(lcs_string) == 'string')
    commas = {}
    -- get items
    for i=1, #lcs_string do
        if lcs_string:sub(i,i) == ',' then
            table.insert(commas, i)
        end
    end

    local value_ranges = {}
    -- split keys from values
    for i=0, #commas do
        local firstpos = (commas[i] or 0) + 1
        local lastpos = (commas[i+1] or 0) - 1 -- -1 gives last position
        local item = lcs_string:sub(firstpos, lastpos)
        if item ~= '' then -- a listchars string might end with a comma
            if lastpos == -1 then
                lastpos = firstpos + #item
            end
            local splitpos = item:find(':',1,true)
            local key = item:sub(0, splitpos-1)
            if key == 'leadmultispace' or key == 'lead' then
                -- contains args for string.sub(str,a,b) to extract item value or
                -- everything else
                value_ranges[key] = {
                    inner = {firstpos + splitpos, lastpos},
                    outer = {
                        0,
                        firstpos + splitpos - 1,
                        lastpos + 1, -- if greater than #lcs_string results in ''
                    },
                }
            end
        end
    end
    return value_ranges
end

return M
