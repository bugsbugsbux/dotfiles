-- Grammars unknown to TSInstall can be added here

local parser_config = require('nvim-treesitter.parsers').get_parser_configs()

-- d2-lang --UNMAINTAINED!
parser_config.d2 = {
    install_info = {
        url = 'https://github.com/pleshevskiy/tree-sitter-d2',
        revision = 'main',
        files = {'src/parser.c', 'src/scanner.cc'}
    },
    filetype = 'd2',
}
