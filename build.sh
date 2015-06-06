#!/bin/sh

set -e

LVSTHW_DIR="$1"
BOOKMARKDOWN_DIR="${2:-${LVSTHW_DIR}/../bookmarkdown}"

if [ -z "$LVSTHW_DIR" ]; then
    echo "1 argument is required." >&2
    exit
fi

cd "$LVSTHW_DIR"
python "$BOOKMARKDOWN_DIR/bookmarkdown/bookmarkdown" build

DOCSET_DIR=LearnVimScriptTheHardWay.docset
DOCSET_DOCROOT=$DOCSET_DIR/Contents/Resources/Documents
DOCSET_INFOPLIST=$DOCSET_DIR/Contents/info.plist
DOCSET_INDEXDB=$DOCSET_DIR/Contents/Resources/docSet.dsidx

rm -r "$DOCSET_DIR"
mkdir -p "$DOCSET_DOCROOT"
rsync -a "$LVSTHW_DIR/build/html/" "$DOCSET_DOCROOT/"
cat <<PLIST > "$DOCSET_INFOPLIST"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>learnvimscriptthehardway</string>
    <key>CFBundleName</key>
    <string>Learn VimScript The Hard Way</string>
    <key>DocSetPlatformFamily</key>
    <string>learnvimscriptthehardway</string>
    <key>isDashDocset</key>
    <true/>
    <key>dashIndexFilePath</key>
    <string>index.html</string>
</dict>
</plist>
PLIST

sqlite3 "$DOCSET_INDEXDB" <<SQL
CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);
CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);
SQL

for CHAPTER in chapters/*markdown; do
    chapter_path="$(echo $CHAPTER | sed 's/\.markdown$/.html/')"
    chapter_number="$(basename $CHAPTER | sed 's/\.markdown$//')"
    chapter_name="$(head -1 $CHAPTER)"
    sqlite3 "$DOCSET_INDEXDB" "INSERT OR IGNORE INTO searchIndex (name, type, path) VALUES ('Chapter ${chapter_number}: $chapter_name', 'Section', '$chapter_path')"
done

ls "$DOCSET_DOCROOT"/*.html | xargs sed -i '' -e 's,href="/,href="./,g'
ls "$DOCSET_DOCROOT"/*.html | xargs sed -i '' -e 's,src="/,src="./,g'
ls "$DOCSET_DOCROOT"/*/*.html | xargs sed -i '' -e 's,href="/,href="../,g'
ls "$DOCSET_DOCROOT"/*/*.html | xargs sed -i '' -e 's,src="/,src="../,g'
