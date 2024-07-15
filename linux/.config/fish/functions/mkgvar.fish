# dependencies: randstr.fish
function mkgvar \
-d "set a randomly named global var and echo it's name"
    argparse -x p,P p/private P/very-private x/export -- $argv
    set -l name (randstr -v $_flag_private $_flag_very_private)
    set -g $_flag_export "$name"
    and echo "$name"
end
