#!/usr/bin/env bash

# Usage: ./install.sh

if [[ "$(basename "$PWD")" != "nixos" ]]; then
    echo You seem to be in the wrong directory! >&2
    exit 1
fi

# setup

BUILDDIR="$(mktemp -d)"

# cp config to BUILDDIR

cp ./configuration.nix "$BUILDDIR"

# copy other files to BUILDDIR

cp --recursive --target-directory="$BUILDDIR" $(
    ls -1 | grep --invert-match --line-regexp "\
configuration\.nix
install\.sh
.*\.patch
")

# ensure no links ended up in BUILDDIR
find -P "$BUILDDIR" -type l -delete

# install

sudo cp --recursive --dereference "$BUILDDIR"/* /etc/nixos

# cleanup

rm -rf "$BUILDDIR"
