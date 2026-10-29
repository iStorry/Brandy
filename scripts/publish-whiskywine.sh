#!/bin/bash
#
#  publish-whiskywine.sh
#  Whisky
#
#  Publishes a built WhiskyWine `Libraries` folder as the assets Whisky downloads:
#  Libraries.tar.gz and WhiskyWineVersion.plist on the `whiskywine` release.
#
#  Usage: scripts/publish-whiskywine.sh <path/to/Libraries>
#

set -euo pipefail

readonly RELEASE_TAG="whiskywine"
readonly ARCHIVE_NAME="Libraries.tar.gz"
readonly VERSION_FILE="WhiskyWineVersion.plist"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <path/to/Libraries>" >&2
    exit 64
fi

libraries="$(cd "$1" && pwd)"
if [[ "$(basename "$libraries")" != "Libraries" ]]; then
    echo "The folder must be named Libraries; the app extracts the archive expecting that top-level folder." >&2
    exit 65
fi
for required in "$VERSION_FILE" "Wine/bin/wine64" "Wine/bin/wineserver"; do
    if [[ ! -e "$libraries/$required" ]]; then
        echo "Missing $required in $libraries" >&2
        exit 65
    fi
done

version_component() {
    plutil -extract "version.$1" raw -o - "$libraries/$VERSION_FILE"
}
version="$(version_component major).$(version_component minor).$(version_component patch)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "Packaging WhiskyWine $version"
COPYFILE_DISABLE=1 tar -zcf "$work/$ARCHIVE_NAME" -C "$(dirname "$libraries")" Libraries
cp "$libraries/$VERSION_FILE" "$work/$VERSION_FILE"

if ! gh release view "$RELEASE_TAG" > /dev/null 2>&1; then
    gh release create "$RELEASE_TAG" --title "WhiskyWine runtime" --latest=false \
        --notes "Wine runtime downloaded by Whisky during setup. Not an app release."
fi
gh release upload "$RELEASE_TAG" "$work/$ARCHIVE_NAME" "$work/$VERSION_FILE" --clobber
gh release edit "$RELEASE_TAG" --notes "Wine runtime downloaded by Whisky during setup. Not an app release.

Current version: $version"

echo "Published WhiskyWine $version to the $RELEASE_TAG release"
