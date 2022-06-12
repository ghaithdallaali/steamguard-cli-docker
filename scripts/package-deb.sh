#!/bin/bash

set -e

DISTRO=$(lsb_release -i -s)
DISTRO_VERSION=$(lsb_release -r -s)

BIN_PATH="target/release/steamguard-cli"
if [[ ! -f "$BIN_PATH" ]]; then
	echo "ERROR: Could not find release binaries, building them..."
	cargo build --release
fi
VERSION="$("$BIN_PATH" --version | cut -d " " -f 2)"
TEMP_PKG_PATH="/tmp/steamguard-cli_$VERSION"
echo "Building package on $DISTRO $DISTRO_VERSION for v$VERSION..."

mkdir -p "$TEMP_PKG_PATH/usr/local/bin"
mkdir -p "$TEMP_PKG_PATH/etc/bash_completion.d"
mkdir -p "$TEMP_PKG_PATH/DEBIAN"

cp "$BIN_PATH" "$TEMP_PKG_PATH/usr/local/bin/steamguard"
"$BIN_PATH" completion --shell bash > "$TEMP_PKG_PATH/etc/bash_completion.d/steamguard"

cat <<EOT >> $TEMP_PKG_PATH/DEBIAN/control
Package: steamguard-cli
Depends:
Version: $VERSION
Section: base
Priority: optional
Architecture: all
Maintainer: Carson McManus <carson.mcmanus1@gmail.com>
Description: steamguard-cli
 A command line utility to generate Steam 2FA codes and respond to confirmations.
EOT

dpkg-deb --build "$TEMP_PKG_PATH" "steamguard-cli_$VERSION-0.deb"

rm -rf "$TEMP_PKG_PATH"
