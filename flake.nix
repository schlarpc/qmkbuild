{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    qmk = {
      url = "git+https://github.com/qmk/qmk_firmware?submodules=1";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, qmk }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      qmkpkgs = import (import "${qmk.outPath}/util/nix/sources.nix" { }).nixpkgs { inherit system; };
      shell = (import "${qmk.outPath}/shell.nix" { pkgs = qmkpkgs; });
      filterShellAttrs = key: value: !builtins.elem key [ "nobuildPhase" "phases" ];
      drv = pkgs.stdenv.mkDerivation ((pkgs.lib.filterAttrs filterShellAttrs shell.drvAttrs) // {
        src = qmk.outPath;
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
    in {
      packages.default = drv;
    }
  );
}
