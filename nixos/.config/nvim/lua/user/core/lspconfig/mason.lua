---LSPs installed **with mason**:
return function(default_on_attach, capabilities)
    local lspconfig = require('lspconfig')

    local function default_mason_lspconfig_handler(server_name)
        lspconfig[server_name].setup {
            on_attach = default_on_attach,
            capabilities = capabilities,
        }
    end

    require('mason-lspconfig').setup_handlers{
        default_mason_lspconfig_handler,
        -- Custom handlers (override default): ---------------------------------<++>
        ['lua_ls'] = function(server_name) ---@diagnostic disable-line:unused-local
            lspconfig['lua_ls'].setup{
                on_attach = default_on_attach,
                capabilities = capabilities,
                settings = {
                    Lua = {
                        telemetry = {
                            enable = true,
                        },
                    },
                },
            }
        end,
        ['jsonls'] = function(server_name) ---@diagnostic disable-line:unused-local
            local ok, schemastore = pcall(require, 'user.core.schemastore')
            if ok then
                schemastore.setup_handler(default_on_attach, capabilities)
            else
                default_mason_lspconfig_handler('jsonls')
            end
        end,
        ['tinymist'] = function(server_name) ---@diagnostic disable-line:unused-local
            lspconfig['tinymist'].setup{
                on_attach = default_on_attach,
                capabilities = capabilities,
                single_file_support = true,
                root_dir = function()
                    return vim.fn.getcwd()
                end,

                -- fix https://github.com/neovim/neovim/issues/30675
                -- the problem is that utf16-encoded positions are expected, but
                -- utf8-encoded ones are sent by this lsp, so we need to specify that
                offset_encoding = "utf-8",

                settings = {
                    exportPdf = "onSave",
                    outputPath = "$root/tmp/$dir/$name",
                },
            }
        end,
    }
end
