#!/bin/bash
#
#  publish-whiskywine.sh
#  Whisky
#
#  Publishes a built WhiskyWine `Libraries` folder as the assets Whisky downloads:
#  Libraries.tar.gz and WhiskyWineVersion.plist on the `whiskywine-<major version>` release.
#  Each major version gets its own release so an app only downloads a runtime it can run.
#
#  Usage: scripts/publish-whiskywine.sh <path/to/Libraries>
#

set -euo pipefail

# Must match WhiskyWineInstaller.distributionURL; this checkout also has the upstream remote
readonly REPOSITORY="iStorry/Brandy"
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
for required in "$VERSION_FILE" "Wine/bin/wine" "Wine/bin/wineserver"; do
    if [[ ! -e "$libraries/$required" ]]; then
        echo "Missing $required in $libraries" >&2
        exit 65
    fi
done

version_component() {
    plutil -extract "version.$1" raw -o - "$libraries/$VERSION_FILE"
}
version="$(version_component major).$(version_component minor).$(version_component patch)"
release_tag="whiskywine-$(version_component major)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "Packaging WhiskyWine $version"
COPYFILE_DISABLE=1 tar -zcf "$work/$ARCHIVE_NAME" -C "$(dirname "$libraries")" Libraries
cp "$libraries/$VERSION_FILE" "$work/$VERSION_FILE"

if ! gh release view "$release_tag" --repo "$REPOSITORY" > /dev/null 2>&1; then
    gh release create "$release_tag" --repo "$REPOSITORY" --title "WhiskyWine $(version_component major) runtime" --latest=false \
        --notes "Wine runtime downloaded by Whisky during setup. Not an app release."
fi
gh release upload "$release_tag" --repo "$REPOSITORY" "$work/$ARCHIVE_NAME" "$work/$VERSION_FILE" --clobber
gh release edit "$release_tag" --repo "$REPOSITORY" --notes "Wine runtime downloaded by Whisky during setup. Not an app release.

Current version: $version"

echo "Published WhiskyWine $version to the $release_tag release of $REPOSITORY"
