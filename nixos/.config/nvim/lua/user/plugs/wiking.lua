-- This plugin only works with nvim 0.8.*
local ver = vim.version()
if not((ver.major == 0 and ver.minor >= 8) or ver.major > 0) then
    return
end

local w = require('wiking')
w.setup {
    ft_alias = {
        rmd = "markdown",
        ["pandoc.markdown"] = "markdown",
    },
    filetypes = { "markdown", },
    maps = require('user.maps').get_wiking_maps(w)
}
