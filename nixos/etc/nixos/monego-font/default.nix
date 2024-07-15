# test package by replacing function parameter definition with
# the following with-statement and building with `nix-build .`
#with import <nixpkgs>{};
{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
    pname = "monego-font";

    # printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
    version = "r25.ad2acdc";

    meta = with lib; {
        description = "Monaco monospace font with bold, italic and optionally ligatures or nerd font.";
        homepage = "https://github.com/cseelus/monego";
        platforms = platforms.all;
    };

    src = fetchFromGitHub {
        owner = "cseelus";
        repo = "monego";
        rev = "ad2acdcfc48277dabdededd3a46f1348f720d110";
        hash = "sha256-eNZEzbqovs0A07gzz2auCCKUtoiyGbs0KYKGn3TdEeg="; # `nix-prefetch ./default.nix`
    };

    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;
    dontCheck = true;
    installPhase = ''
        runHook preInstall

        install -m444 -Dt $out/share/fonts/opentype */*.otf

        runHook postInstall
    '';
}
