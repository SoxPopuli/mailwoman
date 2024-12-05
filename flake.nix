{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system: 
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

  in
  {
    devShells = {
      default = pkgs.mkShell {
        packages = with pkgs; [
          corepack_22
          cargo
          rust-analyzer
          typescript-language-server

          dune_3

          ocamlPackages.melange
          ocaml-mlx
          ocaml-mlxmerlin
        ];
      };
    };
  });
}
