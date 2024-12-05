{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
  };

  outputs = { self, nixpkgs, flake-utils, nix-filter }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};

      ocaml-mlx = pkgs.ocamlPackages.buildDunePackage {
        pname = "mlx";
        version = "0.9";
        duneVersion = "3";

        src = builtins.fetchGit {
          url = "https://github.com/ocaml-mlx/mlx";
          ref = "refs/tags/0.9";
          rev = "31bc70d5d7a7c67684209590086da466e1fff408";
        };

        buildInputs = with pkgs; [
          ocamlPackages.ocaml-compiler-libs
          ocamlPackages.ppxlib
        ];
      };
      ocaml-mlxmerlin = pkgs.ocamlPackages.buildDunePackage {
        pname = "ocamlmerlin-mlx";
        version = "0.9";
        duneVersion = "3";

        src = builtins.fetchGit {
          url = "https://github.com/ocaml-mlx/mlx";
          ref = "refs/tags/0.9";
          rev = "31bc70d5d7a7c67684209590086da466e1fff408";
        };

        buildInputs = with pkgs; [
          ocamlPackages.ocaml-compiler-libs
          ocamlPackages.ppxlib
          ocamlPackages.merlin-lib
        ];

        nativeBuildInputs = with pkgs; [
          ocamlPackages.cppo
        ];
      };

      ocamlformat-mlx-lib = pkgs.ocamlPackages.buildDunePackage {
        pname = "ocamlformat-mlx-lib";
        version = "0.9";
        duneVersion = "3";

        src = pkgs.fetchFromGitHub {
          owner = "ocaml-mlx";
          repo = "ocamlformat-mlx";
          rev = "bd2ecaaa906071f9cea2e87af2d8ffdb938b588e";
          hash = "sha256-I9ZP8Ory/CRFbHUCe5NkZKKYMwtL1gl8xw965k5R718=";
        };

        propagatedBuildInputs = with pkgs.ocamlPackages; [
          dune-build-info
          re
          uuseg
          ocp-indent
          ocaml-version
          either
          menhirLib
          stdio
          fpath
          cmdliner
          camlp-streams
          result
          astring
        ];
        nativeBuildInputs = with pkgs; [
          ocamlPackages.menhir
        ];
      };

      ocamlformat-mlx = pkgs.ocamlPackages.buildDunePackage {
        pname = "ocamlformat-mlx";
        version = "0.9";
        duneVersion = "3";

        src = pkgs.fetchFromGitHub {
          owner = "ocaml-mlx";
          repo = "ocamlformat-mlx";
          rev = "bd2ecaaa906071f9cea2e87af2d8ffdb938b588e";
          hash = "sha256-I9ZP8Ory/CRFbHUCe5NkZKKYMwtL1gl8xw965k5R718=";
        };

        buildInputs = [ ocamlformat-mlx-lib ];
      };

      reason-react-ppx = pkgs.ocamlPackages.buildDunePackage {
        pname = "reason-react-ppx";
        version = "0.10.1";
        duneVersion = "3";

        src = pkgs.fetchFromGitHub {
          owner = "reasonml";
          repo = "reason-react";
          rev = "f0cf5e4110c06159f36316cc73c791c977bd4471";
          hash = "sha256-hpCQ73GGvXWQWfqFaeYQCJsvzGwbtSvRvDnyI5IYJdE=";
        };

        buildInputs = with pkgs; [
          ocamlPackages.ppxlib
        ];
      };


      reason-react = pkgs.ocamlPackages.buildDunePackage {
        pname = "reason-react";
        version = "0.10.1";
        duneVersion = "3";

        src = pkgs.fetchFromGitHub {
          owner = "reasonml";
          repo = "reason-react";
          rev = "f0cf5e4110c06159f36316cc73c791c977bd4471";
          hash = "sha256-hpCQ73GGvXWQWfqFaeYQCJsvzGwbtSvRvDnyI5IYJdE=";
        };

        propagatedBuildInputs = [ reason-react-ppx ];

        buildInputs = with pkgs; [
          ocamlPackages.melange
        ];

        nativeBuildInputs = with pkgs; [
          ocamlPackages.reason
          ocamlPackages.melange
        ];
      };

      sources = {
        ocaml = nix-filter.lib {
          root = ./frontend;
          include = [
            ".ocamlformat"
            "dune-project"
            "dune"
            (nix-filter.lib.inDirectory "lib")
            (nix-filter.lib.inDirectory "test")
            (nix-filter.lib.matchExt "mlx")
            (nix-filter.lib.matchExt "ml")
          ];
        };
      };
    in
    {
      formatter = pkgs.nixpkgs-fmt;
      packages = {

        default = pkgs.ocamlPackages.buildDunePackage {
          pname = "frontend";
          version = "0.1.0";
          duneVersion = "3";

          src = sources.ocaml;

          nativeBuildInputs = with pkgs; [
            ocamlPackages.melange
            ocaml-mlx
            ocaml-mlxmerlin
          ];

          buildInputs = with pkgs; [
            ocamlPackages.yojson
            reason-react
          ];

          strictDeps = true;
          preBuild = "dune build";
        };

      };

      devShells = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            corepack_22
            cargo
            rust-analyzer
            typescript-language-server

            dune_3

            ocaml
            ocamlformat
            fswatch
            ocamlPackages.ocamlformat-rpc-lib
            ocamlPackages.ocaml-lsp

            ocamlformat-mlx
          ];

          inputsFrom = [ self.packages.${system}.default ];
        };
      };
    });
}
