let
  pkgs = (import <nixpkgs> { });
  src = pkgs.fetchgit {
    url = "https://github.com/qmk/qmk_firmware.git";
    rev = "refs/tags/0.21.1";
    leaveDotGit = true;
    hash = "sha256-dqwqv+JeagH6uxRI6jFkVPR39BpyOD+3yHg0nTN8OZQ=";
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
      nativeBuildInputs = [ pkgs.which ];
    });
in drv
