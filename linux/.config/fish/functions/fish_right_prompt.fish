function fish_right_prompt

    ## current pyenv version
    set -l venv (_get_venv_name)
    if test "$venv" = "G"
        echo -n (set_color --dim)
    end
    echo -n "❮py: "(echo -n -- $venv)(set_color normal)
end
