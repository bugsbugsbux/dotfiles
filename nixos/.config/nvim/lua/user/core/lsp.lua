-- DON'T FORGET THE OTHER CONFIG FILES CONTAINING SERVER SPECIFIC SETTINGS
-- SUCH AS <.neoconf.json> OR <.vscode/settings.json>

-- How does this LSP setup work?
-- * mason as a tool installer
-- * Settings come from:
--   * (mason-)lspconfig: presets, or
--   * (mason-)lspconfig: global customized settings, or
--   * neoconf: project local configurations

-- NOTE: neoconf.setup() has to run BEFORE all other lsp settings:
--require('user.plugs.neoconf')
-- NOTE: make sure mason is set up, before we configure tools we installed with it:
--require('user.plugs.mason')

-- Customize UI ------------------------------------------------------------<++>
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover, {
        border = 'rounded',
    }
)
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help, {
        border = 'rounded',
    }
)

---Defines what happens when a server attaches to a buffer. ----------------<++>
---@diagnostic disable-next-line
---@param client vim.lsp.client
---@param bufnr number
local function default_on_attach(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    require('user.maps').setup_lsp_maps(client, bufnr)
end

---Capabilities tell lsp-servers what features the client understands:
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend(
    'force',
    capabilities,
    require('cmp_nvim_lsp').default_capabilities()
)
capabilities.textDocument.completion.completionItem.snippetSupport = true


-- lspconfig servers:
---@diagnostic disable-next-line:different-requires
require('user.core.lspconfig')(default_on_attach, capabilities)
