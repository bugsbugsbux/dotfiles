function venv
    argparse --stop-nonopt f/force -- $argv
    if not set -ql _flag_force
        if type pyenv 2&>/dev/null
            echo "use pyenv virtualenv or set "
            return 4
        end
    end
    if test (count $argv) -gt 1
        return 3
    end

    if not set -q argv[1]
        set venvs (find . -maxdepth 3 -wholename '*/bin/activate.fish')
        if test (count $venvs) -eq 1
            source "$venvs[1]"
            and return 0
            or return 2
        else
            for v in $venvs
                echo $v
            end
            return 1
        end
    else
        if test -e "$argv"/bin/activate.fish
            source "$argv"/bin/activate.fish
            and return 0
            or return 2
        else
            if test -e ~/venvs/"$argv[1]"/bin/activate.fish
                source ~/venvs/"$argv[1]"/bin/activate.fish
                and return 0
                or return 2
            else
                return 1
            end
        end
    end
end
