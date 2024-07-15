# Folder structure:
```
colorschemes/       -- here live the colorschemes
    init.lua        -- logic to load light/dark version
    <theme>.lua     -- theme config, mods to switch light/dark version
core/               -- here you configure core functionality like LSP
    dap/            -- configure DAP sources here
    lspconfig/      -- configure LSP servers with lspconfig here
    nullls/         -- configure NullLs servers here
    treesitter/     -- configure TS sources here
    completion.lua  -- configure completion sources here
    diagnostic.lua  -- configure global diagnostic settings
    lsp.lua         -- setup LSP and configure general settings here
    schemastore.lua -- configure Schemastore sources here
ftconf/             -- filetype specific overrides
plugs/              -- plugin settings
    <undotree>.lua  -- setup <undotree> plugin
utils/              -- helpers
    init.lua        -- general helpers like usability wrappers, etc
    <netrw>.lua     -- helpers related to <netrw>
README.md
auto.lua            -- most custom autocommands
init.lua            -- entrypoint + most `:set ...` settigns
maps.lua            -- all keymaps in a single file, grouped as needed
plugins.lua         -- install plugins
```
