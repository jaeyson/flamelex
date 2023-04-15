{
  description = "Flamelex - an Alchemical laboratory.";
  # https://baez.link/getting-started-using-nix-flakes-as-an-elixir-development-environment

inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        # lib = nixpkgs.lib;

      in
      {
        devShell = pkgs.mkShell {

          pkgconf libglfw3 libglfw3-dev libglew2.0 libglew-dev


          buildInputs = [
            pkgs.beam.packages.erlang.elixir
            #pkgs.glibcLocales
            pkgs.git
            pkgs.gcc
            pkgs.glfw
            pkgs.glew
            pkgs.pkgconf
            #pkgs.xorg.libXau
            #pkgs.xorg.libXdmcp
            #pkgs.xorg.libX11
            #pkgs.xorg.libXcursor
            #pkgs.xorg.libXrandr
            #pkgs.xorg.libXinerama
          ];

          shellHook = ''
            echo "Running shellHook..."
            export PATH="${pkgs.git}/bin:$PATH"
            #export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:"${pkgs.xorg.libX11}/lib/pkgconfig:${pkgs.xorg.libXcursor}/lib/pkgconfig:${pkgs.xorg.libXrandr}/lib/pkgconfig:${pkgs.xorg.libXinerama}/lib/pkgconfig:${pkgs.xorg.libXdmcp}/lib/pkgconfig"
            pkgconf libglfw3 libglfw3-dev libglew2.0 libglew-dev
            export LIBRARY_PATH=$LIBRARY_PATH:"${pkgs.glfw}/lib:${pkgs.glew}/lib"
          '';
        };
      }
    );
}
