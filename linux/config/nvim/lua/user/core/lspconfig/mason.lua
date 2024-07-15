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
    }
end
