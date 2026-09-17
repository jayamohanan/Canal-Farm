#!/bin/sh
# Build the folder that gets uploaded.
#
# A COPY, not the project itself: the project holds tools, notes, art sources and
# scratch folders that have no business on a games portal, and deciding what to
# leave out by hand every time is how a 3MB editor ends up shipped.
#
# EXCLUDE, rather than list what to include. A list of includes goes stale the
# moment a new art folder appears and quietly ships a game missing its pictures —
# the failure is silent and looks like a bug. An exclude list fails the other way:
# something unwanted slips in, the upload is a little larger, and nothing breaks.
#
# Run from anywhere:  sh build.sh   or   sh /path/to/project/build.sh
set -e

# WORK FROM THE SCRIPT'S OWN FOLDER, not from wherever it was called. Everything
# below copies "the current folder" — so run from somewhere else, the script
# would not fail, it would copy THAT folder instead: a home directory, say. Moving
# to the script's location first makes it do the same thing from anywhere.
cd "$(dirname "$0")"

OUT=build

rm -rf "$OUT"
mkdir -p "$OUT"

rsync -a \
  --exclude '.git' \
  --exclude '.gitignore' \
  --exclude '.claude' \
  --exclude '.DS_Store' \
  --exclude '._*' \
  --exclude 'build' \
  --exclude 'build.sh' \
  --exclude 'dev' \
  --exclude 'tools' \
  --exclude 'style' \
  --exclude '*.md' \
  --exclude 'sounds' \
  --exclude 'LoadingScene.js' \
  --exclude 'WinScene.js' \
  --exclude 'untitled folder' \
  ./ "$OUT/"

# ── STRIP THE COMMENTS FROM OUR OWN SCRIPTS ────────────────────────────────────
# The source is written to be read: game.js is a third comments and config.js
# over two-thirds. That is worth having while the game is being made and worth
# nothing to a player, who downloads every word of it. So the BUILD COPY has them
# removed. The source files are never touched.
#
# COMMENTS AND WHITESPACE ONLY — names are left exactly as written. These files
# are plain scripts sharing globals: config.js defines CONFIG, levels.js defines
# LEVEL_DATA, and game.js reads both. A minifier free to rename would shorten
# those in one file without knowing another file depends on them, and the game
# would break on load. Keeping names costs a little size and removes that risk.
#
# phaser.min.js is left alone: it is already minified.
#
# Skip it with  sh build.sh --no-minify  when debugging a build — a minified file
# puts its whole program on a few lines, so an error's line number points nowhere
# useful.
if [ "$1" != "--no-minify" ]; then
  for f in game.js config.js levels.js batteryChargeData.js; do
    [ -f "$OUT/$f" ] || continue
    npx --yes esbuild@0.24.0 "$OUT/$f" \
      --minify-whitespace --minify-syntax --legal-comments=none \
      --log-level=warning --outfile="$OUT/$f.tmp"
    mv "$OUT/$f.tmp" "$OUT/$f"
  done
fi

echo "built $OUT —  $(du -sh "$OUT" | cut -f1)"
echo
echo "largest pieces:"
du -sh "$OUT"/* 2>/dev/null | sort -rh | head -6
