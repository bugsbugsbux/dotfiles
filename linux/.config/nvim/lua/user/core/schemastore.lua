-- Autocomplete items in json files: https://github.com/b0o/SchemaStore.nvim

local schemastore = require('schemastore')

local M = {}

-- This is the mason-lspconfig setup_handler for the 'jsonls'-LSPserver
function M.setup_handler(default_on_attach, capabilities)
    require('lspconfig')['jsonls'].setup{
        on_attach = default_on_attach,
        capabilities = capabilities,
        settings = {
            json = {
                validate = { enable = true },
                schemas = vim.list_extend({
                    -- your ADDITIONAL schemas (unknown to schemastore!) -------<++>
                    -- {name='', description='', fileMatch={''}, url=''}
                }, schemastore.json.schemas{
                    --replace = { -- known schemas with your own ones: ---------<++>
                        -- ['NAME'] = YOUR_SCHEMA_TABLE, -- no partial schemas!
                    --},
                    --The following two are mutually exclusive: ----------------<++>
                    --select = {'NAME',}, -- only use these schemas
                    --ignore = {'NAME',}, -- dont use these schemas
                }),
            }
        }
    }
end

return M
