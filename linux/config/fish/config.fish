set -qU fish_features
    or set -U fish_features stderr-nocaret qmark-noglob regex-easyesc && exec fish

# ===== vars =====
##XDG_RUNTIME_DIR # defined by pam_systemd /run/user/(id --user)
set -q XDG_CACHE_HOME || set -gx XDG_CACHE_HOME "$HOME/.cache"
set -q XDG_STATE_HOME || set -gx XDG_STATE_HOME "$HOME/.local/state"
set -q XDG_DATA_HOME  || set -gx XDG_DATA_HOME "$HOME/.local/share"
set -q XDG_DATA_DIRS   || set -gx --path XDG_DATA_DIRS /usr/local/share /usr/share
set -q XDG_CONFIG_DIRS || set -gx --path XDG_CONFIG_DIRS /etc/xdg
set -q XDG_CONFIG_HOME || set -gx XDG_CONFIG_HOME "$HOME/.config"
# language:  # uncomment if not defined in /etc/locale.conf
set -q LANG        || set -gx LANG        en_US.UTF-8 # equals LC_ALL if thats set
set -q LC_MESSAGES || set -gx LC_MESSAGES en_US.UTF-8
set -q LC_CTYPE    || set -gx LC_CTYPE    de_DE.UTF-8
set -q LC_NUMERIC  || set -gx LC_NUMERIC  de_DE.UTF-8
set -q LC_TIME     || set -gx LC_TIME     de_DE.UTF-8
set -q LC_COLLATE  || set -gx LC_COLLATE  de_DE.UTF-8
set -q LC_MONETARY || set -gx LC_MONETARY de_DE.UTF-8
set -q LC_PAPER    || set -gx LC_PAPER    de_DE.UTF-8
set -q LC_NAME     || set -gx LC_NAME     de_DE.UTF-8
set -q LC_ADDRESS  || set -gx LC_ADDRESS  de_DE.UTF-8
set -q LC_TELEPHONE      || set -gx LC_TELEPHONE      de_DE.UTF-8
set -q LC_MEASUREMENT    || set -gx LC_MEASUREMENT    de_DE.UTF-8
set -q LC_IDENTIFICATION || set -gx LC_IDENTIFICATION de_DE.UTF-8
#
if test '/home/' = (string sub --length 6 "$HOME")
    # some programm wanted an absolute path
    set -gx SHELL /usr/bin/fish
else
    set -gx SHELL fish
end
set -gx EDITOR nvim
set -gx BROWSER chromium
set -gx DIFFPROG "nvim -d"
if string match --quiet --entire '/home/*' "$HOME"
    set -gx --path MANPATH (man --path)
end
#
if not set -q VIMTHEME; set -gx VIMTHEME dark
end; set -x VIMTHEME $VIMTHEME
#
set -pg fish_user_paths \
    "$HOME/.local/bin/" # dont put compiled files here
set -gx fish_term24bit 1 # force true-color
#
set -g -- nvim_safe_opts -n --noplugin --clean -i NONE -u NONE
set -gx -- CHROME_EXECUTABLE (which chromium 2>/dev/null)  # for flutter
    or set -e CHROME_EXECUTABLE
# for tree in flutter projects
set -g -- fluttree -I windows -I linux -I macos -I android -I ios -I web -I build

# ===== completions =====
type gh &>/dev/null
    and eval (gh completion -s fish)

# ===== cmd config =====
# fzf enable keybindings
if status --is-interactive && which fzf 2&>/dev/null
    fzf_key_bindings
end
# pyenv
if type pyenv &>/dev/null
    set -pgx fish_user_paths $PYENV_ROOT/bin
    status is-login && pyenv init --path | source
    if status --is-interactive
        pyenv init - | source
        # fixed in fish3.2? # broken: adds lots of /tmp/.psub.<randstr> files, see issues/379
        pyenv virtualenv-init - | source
    end
end
# npm
if type npm &>/dev/null
    set -pgx fish_user_paths $HOME/.global_node_modules/bin
end
# android-sdk (manually installed to ~/.android)
test -d "$HOME/.android/cmdline-tools/latest/bin" \
    && set -pg fish_user_paths "$HOME/.android/cmdline-tools/latest/bin"
# android-sdk (installed from AUR)
test -d "/opt/android-sdk/cmdline-tools/latest/bin" \
    && set -pg fish_user_paths "/opt/android-sdk/cmdline-tools/latest/bin"
# flutter, dart global packages
test -d "$HOME/.pub-cache/bin" \
    && set -pg fish_user_paths "$HOME/.pub-cache/bin"
test -d "$HOME/repos/gh/flutter/bin" \
    && set -pg fish_user_paths "$HOME/repos/gh/flutter/bin"
# chromium's depot tools
test -d "$HOME/repos/installed/depot_tools" \
    && set -pg fish_user_paths "$HOME/repos/installed/depot_tools/"
# java # dont put this before .local/bin (i have J's jconsole there)
test -d /usr/lib/jvm/default/bin \
    && set -ag fish_user_paths /usr/lib/jvm/default/bin
# rust  <++ should be in bashrc too!>
test -d "$HOME/.cargo/bin" \
    && set -pg fish_user_paths "$HOME/.cargo/bin"

# ===== functions =====
for f in $HOME/.config/fish/so/*
    source $f
end
