#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
SRC="$(pwd)"
OUT="$SRC/build"
COMMON="$SRC/../../common"
LIB="$SRC/server/lib/fastcgi-lib.jar"

clean() {
    rm -rf "$OUT"
}

deploy() {
    clean
    mkdir -p "$OUT/conf" "$OUT/fcgi-bin" "$OUT/htdocs" "$OUT/classes"

    cp "$SRC/index.html" "$OUT/htdocs/"
    cp -r "$SRC/js" "$OUT/htdocs/js"
    cp -r "$COMMON" "$OUT/htdocs/common"
    cp "$SRC/httpd.conf" "$OUT/conf/"

    # На Helios стоит JDK 17, локально может быть новее
    javac --release 17 -encoding UTF-8 -cp "$LIB" -d "$OUT/classes" "$SRC"/server/app/*.java
    (cd "$OUT/classes" && jar xf "$LIB" com)
    jar --create --file "$OUT/fcgi-bin/lab2-server.jar" --main-class app.Main -C "$OUT/classes" .
    rm -rf "$OUT/classes"

    echo "Раскладка для Helios: src/build"
}

case "${1:-deploy}" in
    deploy) deploy ;;
    clean) clean ;;
    *) echo "Использование: $0 [deploy|clean]" >&2; exit 2 ;;
esac
