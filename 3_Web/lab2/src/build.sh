#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
SRC="$(pwd)"
OUT="$SRC/build"
REDIRECT_OUT="$SRC/redirect/build"
LIB="$SRC/server/lib/fastcgi-lib.jar"

clean() {
    rm -rf "$OUT" "$REDIRECT_OUT"
}

build() {
    clean
    mkdir -p "$OUT/conf" "$OUT/fcgi-bin" "$OUT/htdocs" "$OUT/classes"

    cp "$SRC/index.html" "$OUT/htdocs/"
    cp -r "$SRC/js" "$OUT/htdocs/js"
    cp "$SRC/httpd.conf" "$OUT/conf/"

    # На Helios стоит JDK 17, локально может быть новее
    javac --release 17 -encoding UTF-8 -cp "$LIB" -d "$OUT/classes" "$SRC"/server/app/*.java
    (cd "$OUT/classes" && jar xf "$LIB" com)
    jar --create --file "$OUT/fcgi-bin/lab2-server.jar" --main-class app.Main -C "$OUT/classes" .
    # classes -- промежуточный результат компиляции, в готовой раскладке ему не место
    rm -rf "$OUT/classes"

    echo "Раскладка для Helios: src/build"
}

redirect() {
    rm -rf "$REDIRECT_OUT"
    mkdir -p "$REDIRECT_OUT/js"

    find "$SRC/redirect" -mindepth 1 -maxdepth 1 ! -path "$REDIRECT_OUT" \
        -exec cp -R {} "$REDIRECT_OUT/" \;

    echo "Страница-переход: src/redirect/build"
}

case "${1:-build}" in
    build) build ;;
    redirect) redirect ;;
    clean) clean ;;
    *) echo "Использование: $0 [build|redirect|clean]" >&2; exit 2 ;;
esac
