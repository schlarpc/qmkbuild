let
  pkgs = (import <nixpkgs> { });
  src = pkgs.fetchgit {
    url = "https://github.com/qmk/qmk_firmware.git";
    rev = "refs/tags/0.21.1";
    hash = "sha256-flR3sjynN25pkGGlxY7pCjYzSP/+civbXNiQtuZi7xM=";
  };
  shell = (import "${src}/shell.nix" { });
  filterShellAttrs = key: value: !builtins.elem key [ "nobuildPhase" "phases" ];
  drv = pkgs.stdenv.mkDerivation
    ((pkgs.lib.filterAttrs filterShellAttrs shell.drvAttrs) // {
      src = src;
      buildPhase = ''
        KEYMAP_DIR="keyboards/fc660c/keymaps/schlarpc"
        mkdir $KEYMAP_DIR
        cp ${./config.h} $KEYMAP_DIR/config.h
        qmk json2c -o $KEYMAP_DIR/keymap.c ${./keymap.json}
        make fc660c:schlarpc
      '';
      installPhase = ''
        mkdir $out
        cp .build/*.hex $out
      '';
    });
in drv
