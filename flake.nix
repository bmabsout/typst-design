{
  description = "typst-design: Bassel El Mabsout's design system for Typst";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      version = (builtins.fromTOML (builtins.readFile ./typst.toml)).package.version;
      # The package as Typst expects it on a package path:
      # <path>/local/typst-design/<version>. A consumer points
      # TYPST_PACKAGE_PATH at this and imports "@local/typst-design:<version>".
      packagePath = pkgs: pkgs.linkFarm "typst-design-packages" [
        { name = "local/typst-design/${version}"; path = self; }
      ];
    in
    {
      lib = { inherit version packagePath; };
    }
    // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        packages-dir = packagePath pkgs;
        fonts = with pkgs; [ source-serif source-sans crimson-pro libertinus font-awesome_5 eb-garamond ];
        fontArgs = pkgs.lib.concatMapStringsSep " " (f: "--font-path ${f}/share/fonts") fonts;
        typstEnv = ''
          export TYPST_PACKAGE_PATH=${packages-dir}
          export TYPST_FONT_PATHS=${pkgs.lib.concatMapStringsSep ":" (f: "${f}/share/fonts") fonts}
        '';
      in
      {
        packages = {
          default = packages-dir;
          # The gallery: every ramp, mark, callout and template on a few pages.
          gallery = pkgs.runCommand "typst-design-gallery" { nativeBuildInputs = [ pkgs.typst ]; } ''
            ${typstEnv}
            export SOURCE_DATE_EPOCH=0
            mkdir -p $out
            typst compile --root ${self} --ignore-system-fonts ${fontArgs} ${self}/gallery/gallery.typ $out/gallery.pdf
          '';
        };

        checks.laws = pkgs.runCommand "typst-design-laws" { nativeBuildInputs = [ pkgs.typst ]; } ''
          ${typstEnv}
          typst compile --root ${self} --ignore-system-fonts ${fontArgs} ${self}/tests/laws.typ laws.pdf
          touch $out
        '';

        devShells.default = pkgs.mkShell {
          packages = [ pkgs.typst pkgs.tinymist ];
          shellHook = typstEnv;
        };
      });
}
