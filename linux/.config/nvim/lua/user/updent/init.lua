local auto = require('user.updent.auto')
local core = require('user.updent.core')

local M = {
    update_listchars = core.update_listchars,
}

function M.activate()
    auto.activate()
end

function M.deactivate()
    auto.deactivate()
end

function M.setup(overrides)
    -- M.deactivate() -- only needed once activate() does more than setting up autocmds
    M.activate()
end

return M
