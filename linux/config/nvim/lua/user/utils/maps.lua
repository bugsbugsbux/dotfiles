local M = {}

---@alias MappingsTable table<string, table<string, any[]>>
---Takes a mappings table and optionally a buffer number and activates them globally or
---in the specified buffer. The mappings table's keys represent vim-modes and the values
---are tables of mapping-lhs to list of mapping-rhs and option-table.
---@param mappings MappingsTable
---@param bufnr? number Integer Buffer number or nil == global
---@return nil
function M.activate_maps(mappings, bufnr)
    for mode,_ in pairs(mappings) do
        for seq,remaining_args in pairs(mappings[mode]) do
            if bufnr then
                vim.api.nvim_buf_set_keymap(bufnr, mode, seq, unpack(remaining_args))
            else
                vim.api.nvim_set_keymap(mode, seq, unpack(remaining_args))
            end
        end
    end
end

return M
