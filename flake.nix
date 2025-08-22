{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # To update run: `nix flake update nixpkgs-claude`
    nixpkgs-claude.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, flake-utils, nixpkgs-claude }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        claude-code = (import nixpkgs-claude {
          inherit system;
          config.allowUnfree = true;
        }).claude-code;
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ yaml-language-server ] ++ [ claude-code ];
        };
      });
}
