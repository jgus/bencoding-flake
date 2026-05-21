{
  description = "bencoding: tiny Python bencode encoder/decoder used by Kapowarr.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pin = import ./pin.nix;
        inherit (pin) version hash;
        pkgs = import nixpkgs { inherit system; };
        bencoding = pkgs.python3Packages.buildPythonPackage {
          pname = "bencoding";
          inherit version;
          pyproject = true;
          src = pkgs.python3Packages.fetchPypi {
            pname = "bencoding";
            inherit version hash;
          };
          build-system = [ pkgs.python3Packages.setuptools ];
          doCheck = false;
        };
        update-version = pkgs.writeShellApplication {
          name = "update-version";
          text = ''exec ${./update-version.sh} "$@"'';
        };
        update-branches = pkgs.writeShellApplication {
          name = "update-branches";
          text = ''exec ${./update-branches.sh} "$@"'';
        };
      in
      {
        packages = {
          inherit bencoding update-version update-branches;
          default = bencoding;
        };
      });
}
