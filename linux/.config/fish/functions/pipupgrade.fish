function pipupgrade \
    -d "upgrade outdated pip packages"

    set -l -- packages (
        pip list --outdated --format=columns |
        tail --lines=+3 |
        string split --max 1 --field 1 --no-empty ' '
    )
    if count $packages &>/dev/null
        pip install --upgrade --require-virtualenv $argv $packages
    end
end
