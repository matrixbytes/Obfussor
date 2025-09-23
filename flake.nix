{
  description = "Tauri development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
  }:
    flake-utils.lib.eachDefaultSystem (system: let

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ rust-overlay.overlays.default ];
      };
      llvmPkgs = pkgs.llvmPackages_latest;

    in {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          pkg-config
          cmake
          ninja

          # explicit LLVM derivations
          llvmPkgs.clang
          llvmPkgs.llvm
          llvmPkgs.lld
          mold

          rustc
          cargo
          cargo-tauri
          nodejs
          bun
          openjdk17

          python3
          clang-tools
        ];

        buildInputs = with pkgs; [
          gtk3
          webkitgtk_4_1
          openssl
          librsvg
          libsoup_3

          # explicit runtime GUI deps
          pango
          cairo
          gdk-pixbuf
          glib
          harfbuzz
        ];
        
        shellHook = ''
          # Essential library path
          export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath (with pkgs; [
            at-spi2-atk
            atkmm
            cairo
            gdk-pixbuf
            glib
            gtk3
            gtk4
            harfbuzz
            librsvg
            libsoup_3
            pango
            webkitgtk_4_1
            openssl
          ])}:$LD_LIBRARY_PATH"
          # OpenSSL
          export OPENSSL_INCLUDE_DIR="${pkgs.openssl.dev}/include"
          export OPENSSL_LIB_DIR="${pkgs.openssl.out}/lib"
          echo "🦀 Tauri Environment is Ready"
        '';
      };
    });
}
