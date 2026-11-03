#!/bin/sh
# Installs doc-fill-template @VERSION@ into ~/.local/bin after checking the archive's SHA-256.
# curl -fsSL https://github.com/nowmyagentcan/doc-fill-template/releases/latest/download/install.sh | sh
set -eu
version=@VERSION@
base=${DOC_FILL_TEMPLATE_BASE:-https://github.com/nowmyagentcan/doc-fill-template/releases/download/$version}
case "$(uname -s)-$(uname -m)" in
  Linux-x86_64) target=linux-x64 ;;
  Linux-aarch64 | Linux-arm64) target=linux-arm64 ;;
  Darwin-x86_64) target=macos-x64 ;;
  Darwin-arm64) target=macos-arm64 ;;
  *) echo "doc-fill-template: no build for $(uname -s) $(uname -m)." >&2; exit 1 ;;
esac
archive=doc-fill-template-$version-$target.tar.gz
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/$archive" "$base/$archive"
curl -fsSL -o "$tmp/SHA256SUMS" "$base/SHA256SUMS"
expected=$(awk -v f="$archive" '$2 == f { print $1 }' "$tmp/SHA256SUMS")
if command -v sha256sum >/dev/null; then actual=$(sha256sum "$tmp/$archive"); else actual=$(shasum -a 256 "$tmp/$archive"); fi
if [ -z "$expected" ] || [ "${actual%% *}" != "$expected" ]; then
  echo "doc-fill-template: the SHA-256 of $archive doesn't match SHA256SUMS; nothing was installed." >&2
  exit 1
fi
tar -xzf "$tmp/$archive" -C "$tmp" doc-fill-template
# An empty file "runs" as an empty script, so the answer is checked too.
case $("$tmp/doc-fill-template" --version 2>/dev/null || :) in
  "doc-fill-template "*) ;;
  *) echo "doc-fill-template: $archive has no doc-fill-template that runs here; nothing was installed." >&2; exit 1 ;;
esac
dir=$HOME/.local/bin
mkdir -p "$dir"
mv "$tmp/doc-fill-template" "$dir/doc-fill-template"
"$dir/doc-fill-template" --version
case ":$PATH:" in
  *":$dir:"*) ;;
  *) echo "Add $dir to your PATH: export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
esac
