#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
sdk="${PLAYDATE_SDK_PATH:-$HOME/Developer/PlaydateSDK}"
test -x "$sdk/bin/pdc" || { echo "Playdate SDK not found: $sdk"; exit 1; }
stage=$(mktemp -d /tmp/sky-hamster-variants.XXXXXX)
mkdir -p builds/variants
for rule in speed throttle brake steering latch reverse track lock absolute; do
  mkdir -p "$stage/$rule"
  cp source/*.lua "$stage/$rule/"
  cp "variants/$rule/build.lua" "$stage/$rule/build.lua"
  cp "variants/$rule/pdxinfo" "$stage/$rule/pdxinfo"
  "$sdk/bin/pdc" -sdkpath "$sdk" "$stage/$rule" "builds/variants/sky-hamster-$rule.pdx"
  echo "Built $rule"
done
echo "Nine games: $PWD/builds/variants"
