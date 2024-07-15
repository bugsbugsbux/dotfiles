function ipy \
--wraps='ipython --TerminalInteractiveShell.editing_mode=vi' \
--description 'alias ipy ipython --TerminalInteractiveShell.editing_mode=vi'
    command ipython --TerminalInteractiveShell.editing_mode=vi $argv;
end
