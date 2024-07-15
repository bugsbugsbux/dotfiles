local M = {}

---@param bufnr number
---Shall be activated by my global <leader>dc mapping.
function M.activate_debugging(bufnr)
    -- customize UI
    vim.fn.sign_define('DapLogPoint',
        {text='👁', texthl='', linehl='', numhl=''})
    vim.fn.sign_define('DapBreakpoint',
        {text='⚐', texthl='', linehl='', numhl=''})
    vim.fn.sign_define('DapStopped',
        {text='⚑', texthl='', linehl='', numhl=''})

    -- enable maps
    require('user.maps').dap.setup_dap_maps(bufnr)
end

return M
