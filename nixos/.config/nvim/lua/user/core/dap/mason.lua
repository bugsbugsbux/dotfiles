---DAPs installed **with mason**:

local dap = require('dap')

local function default_mason_dap_handler(config)
    -- customize
    require('mason-nvim-dap').default_setup(config)
end

return {
    default_mason_dap_handler,
    -- Custom handlers (override default, NOTE: must call mndap.default_setup(config)):
    ['python'] = function(config) -- for debugpy
        ---@type table
        config.adapters = {
            type = 'executable',
            command = (function()
                -- This makes sure pyenv is taken into account:
                if vim.fn.has_key(vim.fn.environ(), "PYENV_VIRTUAL_ENV") == 1 then
                    return vim.env.PYENV_VIRTUAL_ENV .. "/bin/python"
                end
                return "python"
            end)(),
            args = {"-m", "debugpy.adapter"},
            options = { cwd = vim.fn.getcwd() },
        }
        ---@type table[]
        config.configurations = {
            {
                type = 'python', -- link to adapters.python
                request = 'launch',
                name = "Launch file",

                -- the follwing setting options can be found at:
                -- https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
                program = "${file}",
                stopOnEntry = true,
                justMyCode = false,
            },
        }
        require('mason-nvim-dap').default_setup(config)
    end,
}
