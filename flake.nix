{
  description = "typst-design: a design system of OKLCH ramps, marks, callouts and document templates, for Typst";

  # nixpkgs comes from the channel tarball, so the flake locks and builds
  # without the GitHub API.
  inputs.nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

  outputs = { self, nixpkgs }:
    let
      version = (builtins.fromTOML (builtins.readFile ./typst.toml)).package.version;
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      # The package as Typst expects it on a package path,
      # <path>/local/typst-design/<version>. Point TYPST_PACKAGE_PATH at it
      # and import "@local/typst-design:<version>".
      packagePath = pkgs: pkgs.linkFarm "typst-design-packages" [
        { name = "local/typst-design/${version}"; path = self; }
      ];

      fontsOf = pkgs: with pkgs; [ source-serif source-sans crimson-pro libertinus font-awesome_5 eb-garamond ];
      fontArgs = pkgs: pkgs.lib.concatMapStringsSep " " (f: "--font-path ${f}/share/fonts") (fontsOf pkgs);
      typstEnv = pkgs: ''
        export TYPST_PACKAGE_PATH=${packagePath pkgs}
        export TYPST_FONT_PATHS=${pkgs.lib.concatMapStringsSep ":" (f: "${f}/share/fonts") (fontsOf pkgs)}
      '';
      compile = pkgs: file: out: "typst compile --root ${self} --ignore-system-fonts ${fontArgs pkgs} ${self}/${file} ${out}";
    in
    {
      lib = { inherit version packagePath; };

      packages = forAllSystems (pkgs: {
        default = packagePath pkgs;
        # Every ramp, mark, callout and template on a few pages.
        gallery = pkgs.runCommand "typst-design-gallery" { nativeBuildInputs = [ pkgs.typst ]; } ''
          ${typstEnv pkgs}
          export SOURCE_DATE_EPOCH=0
          mkdir -p $out
          ${compile pkgs "gallery/gallery.typ" "$out/gallery.pdf"}
        '';
      });

      checks = forAllSystems (pkgs: {
        # The laws hold, and every example compiles.
        laws = pkgs.runCommand "typst-design-laws" { nativeBuildInputs = [ pkgs.typst ]; } ''
          ${typstEnv pkgs}
          ${compile pkgs "tests/laws.typ" "laws.pdf"}
          for f in ${self}/examples/*.typ; do
            ${compile pkgs "examples/$(basename $f)" "example.pdf"}
          done
          touch $out
        '';
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [ pkgs.typst pkgs.tinymist ];
          shellHook = typstEnv pkgs;
        };
      });
    };
}
