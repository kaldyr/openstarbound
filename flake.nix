{
  description = "OpenStarbound package for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/e4bae1bd10c9c57b2cf517953ab70060a828ee6f";
  };

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
      ];

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
            }
          )
        );
    in
    {
      packages = forAllSystems (
        pkgs:
        let
          imgui = pkgs.callPackage ./imgui { };

          openstarbound = pkgs.callPackage ./openstarbound {
            inherit imgui;
          };
        in
        {
          inherit openstarbound;
          default = openstarbound;
        }
      );
    };
}
