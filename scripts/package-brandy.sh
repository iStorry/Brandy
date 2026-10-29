#!/bin/bash
#
#  package-brandy.sh
#  Brandy
#
#  Builds Brandy for release without a Developer ID and packages it as a disk image.
#  An ad-hoc signature has no Team ID, so the hardened runtime's library validation would refuse to
#  load the embedded Sparkle.framework and the app would exit at launch. Every piece of code is
#  therefore signed ad-hoc without the runtime, inside out, keeping each target's entitlements.
#
#  Usage: scripts/package-brandy.sh [output folder]   (run from the repository root; default build/release)
#

set -euo pipefail

readonly APP_NAME="Brandy"
readonly APP_ENTITLEMENTS="Whisky/Whisky.entitlements"
readonly THUMBNAIL_ENTITLEMENTS="WhiskyThumbnail/WhiskyThumbnail.entitlements"

output="${1:-build/release}"
mkdir -p "$output"
output="$(cd "$output" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "Building $APP_NAME"
xcodebuild build -quiet -project Whisky.xcodeproj -scheme Whisky -configuration Release \
    -destination "generic/platform=macOS" -derivedDataPath "$work/DerivedData" -onlyUsePackageVersionsFromResolvedFile \
    CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY=""

app="$work/$APP_NAME.app"
ditto "$work/DerivedData/Build/Products/Release/$APP_NAME.app" "$app"
contents="$app/Contents"
sparkle="$contents/Frameworks/Sparkle.framework"

sign() {
    codesign --force --sign - --timestamp=none "$@"
}

echo "Signing"
sign --preserve-metadata=entitlements \
    "$sparkle/Versions/B/XPCServices/Installer.xpc" \
    "$sparkle/Versions/B/XPCServices/Downloader.xpc" \
    "$sparkle/Versions/B/Autoupdate" \
    "$sparkle/Versions/B/Updater.app"
sign "$sparkle"
sign "$contents/Resources/WhiskyCmd" "$contents/Resources/cabextract"
sign --entitlements "$THUMBNAIL_ENTITLEMENTS" "$contents/PlugIns/WhiskyThumbnail.appex"
sign --entitlements "$APP_ENTITLEMENTS" "$app"
codesign --verify --deep --strict "$app"

version="$(plutil -extract CFBundleShortVersionString raw -o - "$contents/Info.plist")"
build="$(plutil -extract CFBundleVersion raw -o - "$contents/Info.plist")"
image="$output/$APP_NAME-$version.dmg"

echo "Packaging $APP_NAME $version ($build)"
staging="$work/staging"
mkdir "$staging"
mv "$app" "$staging/"
ln -s /Applications "$staging/Applications"
hdiutil create -quiet -volname "$APP_NAME" -srcfolder "$staging" -fs HFS+ -format UDZO -ov "$image"
hdiutil verify -quiet "$image"

echo "$image"
shasum -a 256 "$image"
