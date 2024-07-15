---LSPs ***not*** installed with mason:
return function(default_on_attach, capabilities)

    local lspconfig = require('lspconfig') ---@diagnostic disable-line:different-requires

    -- These setup()-functions have to run AFTER mason-lspconfig.setup():

    lspconfig['dartls'].setup{
        on_attach = default_on_attach,
        capabilities = vim.tbl_deep_extend('force', capabilities, {
            workspace = { workspaceEdit = { documentChanges = true }},
        }),
        init_options = { closingLabels = true },
        handlers = {
            ['dart/textDocument/publishClosingLabels'] = (
                require('user.utils.flutter').get_closing_labels_handler({
                    --enabled = false,
                })
            ),
            ['workspace/applyEdit'] = function(_, result, context)
                result.label = nil
                return vim.lsp.handlers['workspace/applyEdit'](_, result, context)
            end,
        },
    }

end
