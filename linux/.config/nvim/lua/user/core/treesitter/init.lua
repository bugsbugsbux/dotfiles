-- Treesitter: https://github.com/nvim-treesitter/nvim-treesitter

require('user.core.treesitter.additional_grammars')

require("nvim-treesitter.configs").setup {
    ensure_installed = {'lua', 'vim', 'vimdoc', 'query'},
    indent = {enable = false}, -- experimental
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
        enable = true,
        keymaps = require('user.maps').get_treesitter_maps(),
    },
    query_linter = {  -- lint queries in playground
        enable = true,
        use_virtual_text = true,
        lint_events = {"BufWrite", "CursorHold"},
    },
}

require('user.utils.treesitter').set_foldmethod_treesitter(true)
