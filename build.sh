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
# Run from the project root:  sh build.sh
set -e

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

echo "built $OUT —  $(du -sh "$OUT" | cut -f1)"
echo
echo "largest pieces:"
du -sh "$OUT"/* 2>/dev/null | sort -rh | head -6
