#!/usr/bin/env bash
# Clone upstream lite-kit at a pinned revision and apply this repository's patches.
set -euo pipefail
dest=${1:?usage: apply.sh DEST [REV]}
rev=${2:-8a82ff32d75ea27b2604685671a6647ca625bf10}
here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
[[ ! -e $dest ]] || { echo "ABORT: $dest exists" >&2; exit 1; }
git clone -q https://github.com/krevetkqqq/lite-kit "$dest"
git -C "$dest" checkout -q "$rev"
for patch in "$here"/patches/*.patch; do
  git -C "$dest" apply --check "$patch"
  git -C "$dest" apply "$patch"
  echo "applied $(basename "$patch")" >&2
done
