function ipython3 \
--wraps='ipython3 --TerminalInteractiveShell.editing_mode=vi' \
--description 'alias ipython3 ipython3 --TerminalInteractiveShell.editing_mode=vi'
    command ipython3 --TerminalInteractiveShell.editing_mode=vi $argv;
end
