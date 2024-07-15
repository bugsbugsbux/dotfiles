---DAPs ***not*** installed with mason:

-- local dap = require('dap')

-- Just override dap.{adapters,configurations,filetypes,source}.<lang> here:
-- Example:
-- dap.adapters.<name> = {
--     type = 'executable', command = ..., args = ..., ...
-- }
-- dap.configurations.<name> = {
--     -- these 3 are required:
--     type = '<name>', request = 'launch', name = 'Launch file',
--     -- ...
-- }
