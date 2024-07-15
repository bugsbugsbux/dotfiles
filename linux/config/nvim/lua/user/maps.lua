local M = {}

local activate_maps = require('user.utils.maps').activate_maps

---What I always want to be mapped: ----------------------------------------<++>
local nore = {noremap = true}
---@type MappingsTable
M.global = {
    n = {
        -- redo
        ['U'] = {"<c-r>", nore},

        -- I like to use <++marks: something to come back to with description>
        -- go to next '<++'-mark
        ['<Leader>ü'] = {"/<++<CR>", nore},
        -- replace current mark (everything in angle brackets incl themselves)
        ['<Leader>c'] = {"ca<", nore},

        -- file manager
        ['ö'] = {"<cmd>Oil<CR>", nore},
        -- vsplit + file manager
        ['Ö'] = {"<cmd>vsplit | Oil<CR>", nore},
        -- split + file manager
        ['<Leader>ö'] = {"<cmd>split | Oil<CR>", nore},

        -- start debugging
        ['<Leader>dc'] = {
            "<cmd>lua require('user.utils.dap').activate_debugging(0); require('dap').continue()<CR>", nore},
    },
    v = {
        -- search for selection
        ['\\\\'] = {[[y/\c\V<C-R>=escape(@", '\/')<CR><CR>]], nore}, -- case-INsensitive
        ['//'] = {[[y/\C\V<C-R>=escape(@", '\/')<CR><CR>]], nore}, -- case-sensitive
    },
    t = {
        -- go to normal-mode from terminal-mode with alt+esc
        ['<Esc><Esc>'] = {[[<C-\><C-n>]], nore},
    },

}

---@param cmp table Plugin 'cmp'
---@param luasnip table Plugin 'luasnip'
---@return table<string, any>
function M.get_completion_maps(cmp, luasnip)
    local function has_words_before()
        -- credits:
        -- <https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#no-snippet-plugin>
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(
            0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    return {
        -- additional to default config (C-n, C-p):
        ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
        ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
        ['<C-y>'] = cmp.config.disable,  -- disables this mapping
        ['<C-q>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        }),
        ['<C-CR>'] = cmp.mapping.confirm({ select = true }),
        -- snippets
        ['<Tab>'] = cmp.mapping(
            function(fallback)
                if cmp.visible() and cmp.get_selected_entry() then
                    cmp.confirm()
                else
                    if luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    elseif has_words_before() then
                        cmp.complete()
                    else
                        fallback()
                    end
                end
            end,
            {'i', 's'}
        ),
        ['<S-Tab>'] = cmp.mapping(
            function(fallback)
                if cmp.visible() and cmp.get_selected_entry() then
                    return
                end
                if luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end,
            {'i', 's'}
        ),
    }
end

function M.setup_telescope_maps()
    local o = {noremap = true, silent = true}
    ---@type MappingsTable
    local mappings = {
        n = {
        ['<leader>ff'] = {"<cmd>lua require('telescope.builtin').find_files()<cr>", o},
        ['<leader>fg'] = {"<cmd>lua require('telescope.builtin').live_grep()<cr>", o},
        ['<leader>fb'] = {"<cmd>lua require('telescope.builtin').buffers()<cr>", o},
        ['<leader>fh'] = {"<cmd>lua require('telescope.builtin').help_tags()<cr>", o},
        },
    }
    activate_maps(mappings)
end

function M.setup_sendline_maps()
    local o = {noremap = true}
    ---@type MappingsTable
    local maps = {
        n = {
            ['<cr>'] = {'<cmd>Sendline<cr>+', o}, -- advances one line
        },
        v = {
            ['<cr>'] = {':Sendline<cr>', o},
            ['<tab>'] = { '100<gv:Sendline<cr>u', o}, -- sends unindented lines
        },
    }
    activate_maps(maps)
end

function M.setup_spotter_maps()
    local function make_generic_action(motion)
        return function()
            require('spotter').show{
                expire_ms = 1,
                hide_on_move = true,
                where = (motion == 'f' or motion == 't') and 'after' or 'before',
            }
            return motion
        end
    end
    local o = {expr=true, noremap=true}
    local maps = {
        n = {
            ['f'] = { make_generic_action('f'), o },
            ['t'] = { make_generic_action('t'), o },
            ['F'] = { make_generic_action('F'), o },
            ['T'] = { make_generic_action('T'), o },
            ['<leader>g'] = {"<cmd>lua require'spotter'.show{expire_ms=5000, hide_on_move=true, toggle=true}<cr>", {noremap=true}},
        },
        v = {
            ['f'] = { make_generic_action('f'), o },
            ['t'] = { make_generic_action('t'), o },
            ['F'] = { make_generic_action('F'), o },
            ['T'] = { make_generic_action('T'), o },
            ['<leader>g'] = {"<cmd>lua require'spotter'.show{expire_ms=5000, hide_on_move=true, toggle=true}<cr>", {noremap=true}},
        },
        o = {
            ['f'] = { make_generic_action('f'), o },
            ['t'] = { make_generic_action('t'), o },
            ['F'] = { make_generic_action('F'), o },
            ['T'] = { make_generic_action('T'), o },
        },
    }

    for mode, _ in pairs(maps) do
        for seq, remaining_args in pairs(maps[mode]) do
            vim.keymap.set(mode, seq, unpack(remaining_args))
        end
    end

end

function M.setup_formatting_maps()
    local o = { noremap = true, silent = true }
    local maps = {
        n = {
            ['gq'] = {
                "<cmd>lua require'conform'.format{lsp_fallback=true,async=true}<CR>", o}
        },
        v = {
            ['gq'] = {
                "<cmd>lua require'conform'.format{lsp_fallback=true,async=true}<CR>", o}
        },
    }
    activate_maps(maps)
end

function M.setup_diagnostic_maps()
    local o = { noremap = true, silent = true }
    ---@type MappingsTable
    local maps = {
        n = {
            ['<leader>e'] =   {'<cmd>lua vim.diagnostic.open_float()<CR>', o},
            ['<leader>q'] =   {'<cmd>lua vim.diagnostic.set_loclist()<CR>', o},
            ['[d'] =          {'<cmd>lua vim.diagnostic.goto_prev()<CR>', o},
            [']d'] =          {'<cmd>lua vim.diagnostic.goto_next()<CR>', o},
        },
    }
    activate_maps(maps)
end

---@diagnostic disable-next-line
---@param client vim.lsp.client
---@param bufnr? number Integer
function M.setup_lsp_maps(client, bufnr) ---@diagnostic disable-line:unused-local
    -- my default mappings
    local o = { noremap = true, silent = true }
    local mappings = {
        n = {
            ['K'] =           {'<cmd>lua vim.lsp.buf.hover()<CR>', o},
            ['<C-k>'] =       {'<cmd>lua vim.lsp.buf.signature_help()<CR>', o},
            ['gd'] =          {'<cmd>lua vim.lsp.buf.definition()<CR>', o},
            ['gD'] =          {'<cmd>lua vim.lsp.buf.declaration()<CR>', o},
            ['gi'] =          {'<cmd>lua vim.lsp.buf.implementation()<CR>', o},
            ['gr'] =          {'<cmd>lua vim.lsp.buf.references()<CR>', o},
            ['<leader>D'] =   {'<cmd>lua vim.lsp.buf.type_definition()<CR>', o},
            ['<leader>wa'] =  {'<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', o},
            ['<leader>wr'] =  {'<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', o},
            ['<leader>wl'] =  {'<cmd>lua vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', o},
            ['<leader>ca'] =  {'<cmd>lua vim.lsp.buf.code_action()<CR>', o},
            ['<leader>r'] =   {'<cmd>lua vim.lsp.buf.rename()<CR>', o},
        },
        v = {
            ['<leader>ca'] =  {'<cmd>lua vim.lsp.buf.range_code_action()<CR>', o},
        },
    }

    -- Customize these here: -----------------------------------------------<++>
    --* shell files shouldn't override 'K' (opens man-page):
    local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')
    if ft == 'fish' or ft == 'bash' or ft == 'sh' or ft == 'zsh' then
        mappings.n['K'] = nil
    end

    -----
    activate_maps(mappings, bufnr)
end

---@param oil table Plugin 'oil'
---@return table<string, any>
function M.get_oil_maps(oil, actions) ---@diagnostic disable-line:unused-local
    return {
        ['g?'] = 'actions.show_help',
        ['<CR>'] = 'actions.select',
        ['<bs>'] = 'actions.parent',
        ['ö'] = {desc = 'Open in horizontal split and return to oil',
            callback = function()
                local id = vim.api.nvim_get_current_win()
                local is_floating = require('user.utils.helpers').is_floating_window(id)
                oil.select({horizontal = true})
                if is_floating then
                    oil.open_float()
                else
                    vim.api.nvim_set_current_win(id)
                end
            end,
        },
        ['Ö'] = {desc = 'Open in vertical split and return to oil',
            callback = function()
                local id = vim.api.nvim_get_current_win()
                local is_floating = require('user.utils.helpers').is_floating_window(id)
                oil.select({vertical = true})
                if is_floating then
                    oil.open_float()
                else
                    vim.api.nvim_set_current_win(id)
                end
            end,
        },
        ['K'] = 'actions.preview',
        ['q'] = 'actions.close',
        ['<Esc><Esc>'] = 'actions.close',
        ['<C-l>'] = 'actions.refresh',
        ['zh'] = 'actions.toggle_hidden',
        ['gh'] = {desc = 'Go to ~/',
            callback = function() oil.open(vim.fn.expand('~')) end,}
    }
end

---@return table<string, string>
function M.get_treesitter_maps()
    return {
        init_selection = "gsn",    -- vulgo: go-select-node
        node_incremental = "gnn",  -- vlugo: go-next-node
        scope_incremental = "gns", -- vlugo: go-next-scope
        node_decremental = "gmn",  -- vulgo: go-minus-node
    }
end

function M.setup_ft_help_maps()
    local o = {noremap = true, silent = true}
    local mappings = {
        n = {
            q = {':q!<CR>', o},
        }
    }
    activate_maps(mappings, 0)
end

function M.setup_ft_qf_maps()
    local o = {noremap = true, silent = true}
    local mappings = {
        n = {
            q = {':q!<CR>', o},
        }
    }
    activate_maps(mappings, 0)
end

function M.setup_undotree_maps()
    local o = {noremap = true, silent = true}
    local mappings = {
        n = {
            ['ü'] = {"<cmd>UndotreeToggle<CR>", o},
        }
    }
    activate_maps(mappings)
end

---@param wiking table Plugin 'wiking'
function M.get_wiking_maps(wiking)
    return {
        { 'n', '<tab>',   wiking.goto_next_link },
        { 'n', '<S-Tab>',  wiking.goto_prev_link },
        { 'n', '<enter>', wiking.open_or_linkify, "here" },
        { 'v', '<enter>', wiking.linkify },
        { 'n', 'K',       wiking.open, "preview", false },
        { 'n', 'ä',       wiking.open, "external", false },
    }
end

M.lazy_activators = {
    undotree = {
        { 'ü', function()
            require('user.maps').setup_undotree_maps()
            vim.cmd[[UndotreeToggle]]
        end, mode = 'n'},
    },
}

M.dap = { -- also contains maps in GLOBAL!
    ---@return table<string, string>
    dapui_maps = {
        expand = "<CR>",
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
    },
    ---@param bufnr number Integer
    setup_dap_maps = function(bufnr)
        local o = { noremap = true }
        ---@type MappingsTable
        local mappings = {
            n = {
                ['<Leader>dc'] = {"<cmd>lua require('dap').continue()<CR>", o},
                ['<Leader>dR'] = {"<cmd>lua require('dap').run_last()<CR>", o},

                ----- interface
                -- toggle debug interface
                ['<leader>d'] = {"<cmd>lua require('dapui').toggle()<CR>", o},
                -- toggle repl
                ['<Leader>dr'] = {"<cmd>lua require('dap').repl.toggle()<CR>", o},
                -- ask for and open an interface element
                ['<Leader>dh'] = {"<cmd>lua require('dapui').float_element()<CR>", o},

                ----- setting break-/logpoints
                -- toggle
                ['<leader>db'] = {"<cmd>lua require('dap').toggle_breakpoint()<CR>", o},
                -- logpoint
                ['<Leader>dL'] = {"<cmd>lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>", o},
                -- conditional
                ['<leader>dC'] = {"<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", o},
                -- exceptions act like breakpionts
                ['<Leader>dE'] = {"<cmd>lua require('dap').set_exception_breakpoints()<CR>", o},

                ----- stepping through code
                -- over (vulgo next)
                ['<leader>dn'] = {"<cmd>lua require('dap').step_over()<CR>", o},
                -- out
                ['<leader>do'] = {"<cmd>lua require('dap').step_out()<CR>", o},
                -- into
                ['<leader>di'] = {"<cmd>lua require('dap').step_into()<CR>", o},
                -- until cursor (wont stop at breakpoints)
                ['<leader>dk'] = {"<cmd>lua require('dap').run_to_cursor()<CR>", o},

                ----- going through stackframes
                ['<leader>du'] = {"<cmd>lua require('dap').up()<CR>", o},
                ['<leader>dd'] = {"<cmd>lua require('dap').down()<CR>", o},

            },
        }

        -- Customize these here: -----------------------------------------------<++>
        -----
        activate_maps(mappings, bufnr)
    end,
}

M.dressing = {
    input = {
      n = {
        ["<Esc>"] = "Close",
        ["<CR>"] = "Confirm",
      },
      i = {
        ["<C-c>"] = "Close",
        ["<CR>"] = "Confirm",
        ["<Up>"] = "HistoryPrev",
        ["<Down>"] = "HistoryNext",
      },
    },
    select = {
        builtin = {
            ["<Esc>"] = "Close",
            ["<C-c>"] = "Close",
            ["<CR>"] = "Confirm",
        },
    },
}

return M
