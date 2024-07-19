ERR_GENERIC=50
ERR_USAGE=51
ERR_ARGS=52
ERR_EXISTING_FILES=53

BARE_SRC="$PWD"
BARE="$HOME/repos/dotfiles.git"

# create relative link $2 pointing to $1
linkstall () {
    local src="${1/#'~'/$HOME}" dst="${2/#'~'/$HOME}"
    if [[ ! -e "$src" ]]; then
        echo ERROR: "$src" does not exist! >&2
        return $ERR_ARGS
    fi
    if [[ -e "$dst" ]]; then
        echo ERROR: "$dst" exists! >&2
        return $ERR_ARGS
    fi
    ln --symbolic --relative --no-target-directory "$src" "$dst"
}

pushd () { command pushd "$@"; } >/dev/null
popd ()  { command popd  "$@"; } >/dev/null

# throw if prerequisites aren't met
if (( "$UID" == 0 )); then
    echo ERROR: must not run as root! >&2
    exit $ERR_EXISTING_FILES
fi
if [[ -e ~/.config || -e ~/.dot || -e ~/repos ]]; then
    echo ERROR: some locations already exist! >&2
    exit $ERR_EXISTING_FILES
fi
case "$PLATFORM" in
    linux|nixos|termux|windows) ;;
    *)
        echo ERROR: PLATFORM not set or invliad value: "'$PLATFORM'"
        exit $ERR_ARGS
    ;;
esac

# create required folders
mkdir -p ~/.config ~/.dot ~/repos

# create bare clone
pushd ~/repos
    git clone --quiet --bare --no-local "$BARE_SRC" "$BARE" || exit $ERR_GENERIC
popd

# create sparse clones (and link to them)
pushd ~/.dot
    git clone --quiet "$BARE" etc && {
    pushd etc
        git sparse-checkout set --no-cone {linux,nixos,termux,windows}/etc
        git checkout --quiet -b dev
        echo "PLEASE manually install files from '$PWD/$PLATFORM/etc/…' to '/etc/…'"
        # on nixos put a link to the local nixos configuration folder into HOME:
        if [[ "$PLATFORM" == "nixos" ]]; then
            linkstall "${PLATFORM}/etc/nixos" ~/nixos
        fi
    popd; }
    git clone --quiet "$BARE" shell && {
    pushd shell
        git sparse-checkout set --no-cone /{linux,nixos,termux,windows}/{.{bash,input}rc,.{,bash_}profile,.bash_{login,logout,aliases}}
        git checkout --quiet -b dev
        linkstall {$PLATFORM,~}/.bashrc
        linkstall {$PLATFORM,~}/.inputrc
        # linkstall {$PLATFORM,~}/.profile
        linkstall {$PLATFORM,~}/.bash_profile
        # linkstall {$PLATFORM,~}/.bash_login
        # linkstall {$PLATFORM,~}/.bash_logout
        linkstall {$PLATFORM,~}/.bash_aliases
    popd; }
    git clone --quiet "$BARE" fish && {
    pushd fish
        git sparse-checkout set --no-cone {linux,nixos,termux,windows}/.config/fish
        git checkout --quiet -b dev
        linkstall {$PLATFORM,~}/.config/fish
    popd; }
    git clone --quiet "$BARE" sway && {
    pushd sway
        git sparse-checkout set --no-cone {linux,nixos,termux,windows}/.config/{mako,sway,tofi}
        git checkout --quiet -b dev
        linkstall {$PLATFORM,~}/.config/mako
        linkstall {$PLATFORM,~}/.config/sway
        linkstall {$PLATFORM,~}/.config/tofi
    popd; }
    git clone --quiet "$BARE" term && {
    pushd term
        git sparse-checkout set --no-cone {linux,nixos,termux,windows}/.config/{alacritty,foot,wezterm}
        git checkout --quiet -b dev
        linkstall {$PLATFORM,~}/.config/alacritty
        linkstall {$PLATFORM,~}/.config/foot
        linkstall {$PLATFORM,~}/.config/wezterm
    popd; }
    git clone --quiet "$BARE" nvim && {
    pushd nvim
        git sparse-checkout set --no-cone {linux,nixos,termux,windows}/.config/nvim
        git checkout --quiet -b dev
        linkstall {$PLATFORM,~}/.config/nvim
    popd; }
    git clone --quiet "$BARE" other && {
    pushd other
        git sparse-checkout set --no-cone {linux,nixos,termux,windows}/.config/{git,tmux,wireplumber}
        git sparse-checkout add /{linux,nixos,termux,windows}/{.npmrc,.config/chromium-flags.conf}
        git checkout --quiet -b dev
        linkstall {$PLATFORM,~}/.npmrc
        linkstall {$PLATFORM,~}/.config/git
        linkstall {$PLATFORM,~}/.config/tmux
        linkstall {$PLATFORM,~}/.config/wireplumber
        linkstall {$PLATFORM,~}/.config/chromium-flags.conf
    popd; }
popd
