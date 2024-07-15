local M = {}

---@param bool boolean Whether or not to use foldmethod treesitter.
---This only sets the correct fold*method*! To (de)activate folds use
---`:set foldenable` or `:set nofoldenable`
function set_foldmethod_treesitter(bool)
    vim.validate { bool = { bool, "boolean" } }
    if bool then
        vim.o.foldminlines = 5
        vim.o.foldmethod = "expr"
        vim.o.foldexpr = "nvim_treesitter#foldexpr()"
    else
        vim.o.foldminlines = 1
        vim.o.foldmethod = "manual"
    end
end
M.set_foldmethod_treesitter = set_foldmethod_treesitter

return M
