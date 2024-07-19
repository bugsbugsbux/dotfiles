#!/usr/bin/env bash

if [[ "$(basename "$PWD")" != "nixos" ]]; then
    echo You seem to be in the wrong directory! >&2
    exit 1
fi

# setup

BUILDDIR=$(mktemp -d)
NAME="${NAME:-$(hostname)}"

echo "build directory is: $BUILDDIR" >&2

# patch

cp ./configuration.nix "$BUILDDIR"
patch "${BUILDDIR}/configuration.nix" "${NAME}.patch" || {
    rm -rf "$BUILDDIR"
    exit 1
}

# copy other files to BUILDDIR

cp --recursive --target-directory "$BUILDDIR" $(
    ls -1 | grep --invert-match --line-regexp "\
configuration\.nix
install\.sh
.*\.patch"
)

# install

sudo cp --recursive --dereference "$BUILDDIR"/* /etc/nixos

# cleanup

rm -rf "$BUILDDIR"
