{
  description = "ModernCV of Sebastian Nagel";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      perSystem = { pkgs, ... }:
        let
          tex = pkgs.texlive.combine {
            inherit (pkgs.texlive)
              scheme-medium
              moderncv
              fontawesome5
              academicons
              multirow
              arydshln
              lato
              fontaxes
              ;
          };
          buildCommand = ''
            latexmk -xelatex -interaction=nonstopmode -halt-on-error cv.tex
          '';
          cleanCommand = ''
            latexmk -c
          '';
        in
        rec {
          packages = {
            cv = pkgs.stdenv.mkDerivation {
              pname = "cv-sebastian-nagel";
              version = "0.0.1";
              nativeBuildInputs = with pkgs; [
                tex
              ];
              meta = { };
              src = ./.;
              buildPhase = buildCommand;
              installPhase = ''
                mkdir $out
                cp cv.pdf $out/cv.pdf
              '';
            };

            default = packages.cv;
          };

          # TODO: https://flake.parts/options/devshell or https://devenv.sh/
          devShells.default = packages.cv.overrideAttrs (oldAttrs: {
            nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
              (pkgs.writeScriptBin "build" buildCommand)
              (pkgs.writeScriptBin "clean" cleanCommand)
            ];
          });
        };
    };
}
