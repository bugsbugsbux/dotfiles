function ipython \
--wraps='ipython --TerminalInteractiveShell.editing_mode=vi' \
--description 'alias ipython ipython --TerminalInteractiveShell.editing_mode=vi'
    command ipython --TerminalInteractiveShell.editing_mode=vi $argv;
end
