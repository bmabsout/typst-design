#!/usr/bin/env sh
# Link this checkout into Typst's local package directory, so documents can
# `#import "@local/typst-design:<version>": *` without Nix.
set -eu
here=$(cd "$(dirname "$0")/.." && pwd)
version=$(sed -n 's/^version = "\(.*\)"/\1/p' "$here/typst.toml")
case "$(uname)" in
  Darwin) data="$HOME/Library/Application Support" ;;
  *) data="${XDG_DATA_HOME:-$HOME/.local/share}" ;;
esac
dest="$data/typst/packages/local/typst-design"
mkdir -p "$dest"
ln -sfn "$here" "$dest/$version"
echo "linked $here -> $dest/$version"
