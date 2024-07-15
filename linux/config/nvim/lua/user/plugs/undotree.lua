-- Undotree: https://github.com/mbbill/undotree

vim.g.undotree_WindowLayout = 4
vim.g.undotree_ShortIndicators = true
vim.g.undotree_SetFocusWhenToggle = 1

require('user.maps').setup_undotree_maps()
