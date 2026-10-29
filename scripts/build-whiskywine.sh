#!/bin/bash
#
#  build-whiskywine.sh
#  Whisky
#
#  Assembles the WhiskyWine runtime (a `Libraries` folder) from pinned upstream releases.
#  Every download is checked against a pinned SHA-256 or fetched at a pinned commit.
#  Publish the result with scripts/publish-whiskywine.sh.
#
#  Usage: scripts/build-whiskywine.sh <output-folder>
#

set -euo pipefail

readonly RUNTIME_MAJOR=3
readonly RUNTIME_MINOR=0
readonly RUNTIME_PATCH=0

# Official WineHQ macOS package (Wine 11.0 stable), built by Gcenx/macOS_Wine_builds
readonly WINE_URL="https://github.com/Gcenx/macOS_Wine_builds/releases/download/11.0_1/wine-stable-11.0_1-osx64.tar.xz"
readonly WINE_SHA256="b50dc50ec7f41d58b115a6b685d4d1315ba3c797bd3aa0f49213f2703cb82388"
readonly WINE_FOLDER="Wine Stable.app/Contents/Resources/wine"

# The non-"builtin" DXVK variant: Wine ignores DLLs marked as builtin when they are copied into system32
readonly DXVK_URL="https://github.com/Gcenx/DXVK-macOS/releases/download/v1.10.3-20230507-repack/dxvk-macOS-async-v1.10.3-20230507-repack.tar.gz"
readonly DXVK_SHA256="acd1520ad105d8ef124a09c8e11a259a5dc8bdc565ad18e0e52693f9807b2477"
readonly DXVK_FOLDER="dxvk-macOS-async-v1.10.3-20230507-repack"

readonly WINETRICKS_COMMIT="f3890f670867b5ffbc3938726db45c0f7d16c8ba"
readonly WINETRICKS_RAW="https://raw.githubusercontent.com/Winetricks/winetricks/$WINETRICKS_COMMIT"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <output-folder>" >&2
    exit 64
fi

mkdir -p "$1"
libraries="$(cd "$1" && pwd)/Libraries"
if [[ -e "$libraries" ]]; then
    echo "$libraries already exists" >&2
    exit 73
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

fetch() {
    local url="$1" sha256="$2" destination="$3"
    curl -fL --retry 3 --silent --show-error -o "$destination" "$url"
    echo "$sha256  $destination" | shasum -a 256 -c - > /dev/null
}

echo "Downloading Wine"
fetch "$WINE_URL" "$WINE_SHA256" "$work/wine.tar.xz"
tar -xJf "$work/wine.tar.xz" -C "$work"

echo "Downloading DXVK"
fetch "$DXVK_URL" "$DXVK_SHA256" "$work/dxvk.tar.gz"
tar -xzf "$work/dxvk.tar.gz" -C "$work"

echo "Assembling $libraries"
mkdir -p "$libraries/DXVK"
ditto "$work/$WINE_FOLDER" "$libraries/Wine"
ditto "$work/$DXVK_FOLDER/x64" "$libraries/DXVK/x64"
ditto "$work/$DXVK_FOLDER/x32" "$libraries/DXVK/x32"
curl -fL --retry 3 --silent --show-error -o "$libraries/winetricks" "$WINETRICKS_RAW/src/winetricks"
curl -fL --retry 3 --silent --show-error -o "$libraries/verbs.txt" "$WINETRICKS_RAW/files/verbs/all.txt"
chmod +x "$libraries/winetricks"

version_file="$libraries/WhiskyWineVersion.plist"
plutil -create xml1 "$version_file"
plutil -insert version -dictionary "$version_file"
plutil -insert version.major -integer "$RUNTIME_MAJOR" "$version_file"
plutil -insert version.minor -integer "$RUNTIME_MINOR" "$version_file"
plutil -insert version.patch -integer "$RUNTIME_PATCH" "$version_file"
plutil -insert version.preRelease -string "" "$version_file"
plutil -insert version.build -string "" "$version_file"

for required in Wine/bin/wine Wine/bin/wineserver DXVK/x64/d3d11.dll DXVK/x32/d3d11.dll winetricks verbs.txt; do
    if [[ ! -e "$libraries/$required" ]]; then
        echo "Missing $required" >&2
        exit 70
    fi
done

echo "Built WhiskyWine $RUNTIME_MAJOR.$RUNTIME_MINOR.$RUNTIME_PATCH at $libraries"
