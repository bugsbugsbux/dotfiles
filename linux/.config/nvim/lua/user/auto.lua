-- goto last editing position; opens necessary folds (if they
-- already exist! (eg. treesitter folds don't))
vim.cmd([[
augroup gotoLastPos
    autocmd! gotoLastPos
    autocmd BufReadPost * silent! normal! g'"zv
augroup END
]])

-- update sidescroll to move by current buffer's indentwidth
vim.cmd([[
augroup updateSideScroll
    autocmd! updateSideScroll
    autocmd OptionSet tabstop,shiftwidth let &sidescroll = shiftwidth()
    autocmd OptionSet tabstop,shiftwidth let &sidescrolloff = shiftwidth()
augroup END
]])

-- cursorline in active window
vim.cmd([[
augroup indicateActiveWin
    autocmd!
    autocmd VimEnter * set cursorline
    autocmd WinEnter * set cursorline
    autocmd WinLeave * set nocursorline
augroup END
]])

-- terminal maps
vim.cmd([[
augroup terminalMaps
    autocmd!
    autocmd TermOpen * setlocal nospell nonumber norelativenumber
augroup END
]])

-- NoFileType events
-- work by setting default options
-- and negating them on any FileType event:
vim.cmd([[
augroup NoFileType
    autocmd! NoFileType
    autocmd FileType * setlocal nospell
    autocmd FileType * setlocal textwidth=0
augroup END
]])

-- filetype-specific settings
-- must run AFTER NoFileType settings (see above)!
vim.cmd([[
augroup myFiletypeAutoCmds
    autocmd! myFiletypeAutoCmds
    autocmd FileType css  lua require('user.ftconf.css')()
    autocmd FileType dart lua require('user.ftconf.dart')()
    autocmd FileType fish lua require('user.ftconf.fish')()
    autocmd FileType gitcommit lua require('user.ftconf.gitcommit')()
    autocmd FileType help lua require('user.ftconf.help')()
    autocmd FileType html lua require('user.ftconf.html')()
    autocmd FileType lua  lua require('user.ftconf.lua')()
    autocmd FileType markdown,pandoc.markdown,rmd lua require('user.ftconf.markdown')()
    autocmd FileType python lua require('user.ftconf.python')()
    autocmd FileType qf   lua require('user.ftconf.qf')()
    autocmd FileType rst  lua require('user.ftconf.rst')()
    autocmd FileType text lua require('user.ftconf.text')()
    autocmd FileType typst lua require('user.ftconf.typst')()
    autocmd FileType vim  lua require('user.ftconf.vim')()
augroup END
]])
