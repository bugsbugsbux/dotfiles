local utils = require('user.updent.utils')

local M = {}

---Update leadmultispace and optionally lead values from the listchars option according
---to shiftwidth or if it is 0 tabstop except when a specific width is given.
---
---Requires that current leadmultispace matches one of the patterns: (marker + fill) or
---(fill + marker) or (marker1 + fill + marker2) where fill consists of all the same
---symbols. As marker and fill cannot be differentiated for indents<3 you can set
---fallbacks with the fallback.fill and fallback.mark_end options.
---
---By default effects the current window if listchars has a local value, else sets only
---the global listchars. Setting global or localize to true ensures the respective scope
---is effected; setting both effects both; however setting either to false does *not*
---ensure the respective scope is *not* effected.
---
---An indent of only one space is styled with the lead listchars item. This sets it to
---the first character of the new leadmultispace string; to suppress that set
---keep_lcs_lead to true.
function M.update_listchars(opts)
    -- NOTE: an empty string as local listchars value means to use the global listchars.

    opts = opts or {}
    opts = vim.tbl_deep_extend('force', {
        window = 0,
        width = nil,
        keep_lcs_lead = false,
        localize = false,
        global = false,
        fallback = { -- for indents<3
            mark_end = nil, ---@type boolean? nil means marker1+fill(+marker2)
            fill = ' ',
        },
    }, opts)
    if (opts.fallback.mark_start
        or opts.fallback.mark_begin
        or opts.fallback.mark_beginning)
    then
        opts.fallback.mark_end = false
    end
    assert(opts.fallback.fill and vim.fn.strdisplaywidth(opts.fallback.fill) == 1)

    local winid = opts.window ~= 0 and opts.window or vim.api.nvim_get_current_win()
    local lcs = vim.api.nvim_win_get_option(winid, 'lcs')

    -- determine scope
    local is_lcs_local = lcs ~= ''
    if opts.global or not is_lcs_local then
        lcs = vim.api.nvim_get_option('lcs') -- always gets global value
    end

    -- gather info
    local ranges = utils.get_lcs_value_ranges(lcs)
    if not ranges.leadmultispace then
        return -- there is nothing to do
    end
    --local lmsp = lcs.leadmultispace or ''
    local lmsp = lcs:sub(ranges.leadmultispace.inner[1], ranges.leadmultispace.inner[2])
    -- using the vim-functions here fixes issues with non-ascii characters like ¦
    local length = vim.fn.strcharlen(lmsp)
    local first = vim.fn.strcharpart(lmsp, 0, 1)
    local last = vim.fn.strcharpart(lmsp, length-1, 1)
    local filler = length<3 and '' or vim.fn.strcharpart(lmsp, 1, length-2)
    for i=0, #filler do
        if not filler:sub(i+1,i+1) == filler:sub(1,1) then
            error("cannot generate new filler: given one contains different characters")
        end
    end

    -- determine filler-char and whether to mark start or end of indent? nil marks both
    local mark_end = nil
    if filler == '' then
        filler = opts.fallback.fill -- required to be length 1
        mark_end = opts.fallback.mark_end
        if length == 1 then
            if mark_end then
                first = filler
            else
                last = filler
            end
        end
    else
        if filler == first then
            mark_end = true
        elseif filler == last then
            mark_end = false
        end
    end
    filler = filler:sub(1,1)

    -- generate new leadmultispace, and lead
    local sw = opts.width or utils.vim_fn_shiftwidth({
        global = opts.global, window = winid
    })
    local lcs_leadmultispace, lcs_lead
    if mark_end == true then
        lcs_leadmultispace = vim.fn['repeat'](filler, sw-1) .. last
    elseif mark_end == false then
        lcs_leadmultispace = first .. vim.fn['repeat'](filler, sw-1)
    else
        lcs_leadmultispace = first .. vim.fn['repeat'](filler, sw-2) .. last
    end
    if not opts.keep_lcs_lead then
        if mark_end then
            lcs_lead = filler
        else
            lcs_lead = first
        end
    end

    -- generate new listchars string
    local new
    if not ranges.lead then
        new = table.concat{
            lcs:sub(ranges.leadmultispace.outer[1], ranges.leadmultispace.outer[2]),
            lcs_leadmultispace,
            lcs:sub(ranges.leadmultispace.outer[3]),
        }
    else
        if ranges.lead.inner[1] < ranges.leadmultispace.inner[1] then
            -- 'lead:!,tab:->,leadmultispace:!   ,' -- example
            new = table.concat{
                lcs:sub(ranges.lead.outer[1], ranges.lead.outer[2]),
                lcs_lead,
                lcs:sub(ranges.lead.outer[3], ranges.leadmultispace.outer[2]),
                lcs_leadmultispace,
                lcs:sub(ranges.leadmultispace.outer[3]),
            }
        else
            -- 'leadmultispace:!   ,tab:->,lead:!,' -- example
            new = table.concat{
                lcs:sub(ranges.leadmultispace.outer[1], ranges.leadmultispace.outer[2]),
                lcs_leadmultispace,
                lcs:sub(ranges.leadmultispace.outer[3], ranges.lead.outer[2]),
                lcs_lead,
                lcs:sub(ranges.lead.outer[3]),
            }
        end
    end

    -- update listchars
    if opts.localize then
        vim.api.nvim_win_set_option(winid, 'lcs', new)
        if opts.global then
            M.update_listchars(vim.tbl_extend('force', opts, {
                localize = false, global = true
            }))
        end
    else
        if opts.global or not is_lcs_local then
            vim.api.nvim_set_option('lcs', new) -- always only sets global value
        else
            vim.api.nvim_win_set_option(winid, 'lcs', new)
        end
    end
end

return M
