#!/usr/bin/env zsh
set -euo pipefail

APP_NAME="MenuCal"
PROJECT="MenuCal.xcodeproj"
SCHEME="MenuCal"
CONFIGURATION="Release"
DESTINATION="generic/platform=macOS"

BUILD_DIR="build"
ARCHIVE_PATH="$BUILD_DIR/$APP_NAME.xcarchive"
DMG_STAGING_DIR="$BUILD_DIR/dmg"
DMG_PATH="$BUILD_DIR/$APP_NAME.dmg"
ZIP_PATH="$BUILD_DIR/$APP_NAME.zip"
APPCAST_ITEM_PATH="$BUILD_DIR/appcast-item.xml"

MIN_SYSTEM_VERSION="26.5"
APP_VERSION=""
APP_BUILD=""
APP_TAG_NAME=""
RELEASE_NOTES_URL=""
SPARKLE_KEY_FILE="${SPARKLE_KEY_FILE:-}"
AD_HOC_SIGNING=false
SKIP_ARCHIVE=false
SKIP_DMG=false
SKIP_ZIP=false

function usage() {
    cat <<'EOF'
Usage:
  scripts/package.sh [options]

Options:
  --version VERSION        Marketing version, e.g. 1.0.1.
  --build BUILD           Build number. Defaults to git commit count.
  --tag TAG               Release tag. Defaults to latest git tag, then vVERSION.
  --min-system VERSION    Sparkle minimum system version. Default: 26.5.
  --release-notes URL     Optional Sparkle release notes URL.
  --sparkle-key-file PATH Sparkle private key file.
  --ad-hoc                Use ad-hoc signing when you do not have a Developer ID.
  --skip-archive          Reuse build/MenuCal.xcarchive.
  --skip-dmg              Do not create build/MenuCal.dmg.
  --skip-zip              Do not create build/MenuCal.zip.
  -h, --help              Show this help.

Sparkle signing:
  Set SPARKLE_KEY_FILE to the private key file path, or set SPARKLE_KEY to the
  private EdDSA key content. Set SPARKLE_SIGN_UPDATE to override the sign_update
  executable path. When the key and sign_update are available,
  build/appcast-item.xml will include the signed DMG enclosure.

Examples:
  scripts/package.sh --version 1.0.1 --build 2
  scripts/package.sh --version 1.0.1 --build 2 --tag v1.0.1 --sparkle-key-file "$HOME/Desktop/MenuCal-Sparkle-private-key"
  SPARKLE_KEY_FILE="$HOME/Desktop/MenuCal-Sparkle-private-key" scripts/package.sh --version 1.0.1 --build 2 --tag v1.0.1
  scripts/package.sh --version 1.0.1 --build 2 --ad-hoc
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --version)
            APP_VERSION="$2"
            shift 2
            ;;
        --build)
            APP_BUILD="$2"
            shift 2
            ;;
        --tag)
            APP_TAG_NAME="$2"
            shift 2
            ;;
        --min-system)
            MIN_SYSTEM_VERSION="$2"
            shift 2
            ;;
        --release-notes)
            RELEASE_NOTES_URL="$2"
            shift 2
            ;;
        --sparkle-key-file)
            SPARKLE_KEY_FILE="$2"
            shift 2
            ;;
        --ad-hoc)
            AD_HOC_SIGNING=true
            shift
            ;;
        --skip-archive)
            SKIP_ARCHIVE=true
            shift
            ;;
        --skip-dmg)
            SKIP_DMG=true
            shift
            ;;
        --skip-zip)
            SKIP_ZIP=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

function project_setting() {
    local key="$1"
    sed -n "s/.*$key = \(.*\);/\1/p" "$PROJECT/project.pbxproj" | tail -n 1
}

function latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || true
}

function version_from_tag() {
    local tag="$1"

    if [[ "$tag" =~ '^v?([0-9]+\.[0-9]+\.[0-9]+)' ]]; then
        echo "$match[1]"
    fi
}

function git_commit_count() {
    git rev-list --count HEAD 2>/dev/null || true
}

function repo_url() {
    if [[ -n "${GITHUB_SERVER_URL:-}" && -n "${GITHUB_REPOSITORY:-}" ]]; then
        echo "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY"
        return
    fi

    local origin
    origin="$(git config --get remote.origin.url 2>/dev/null || true)"
    if [[ "$origin" =~ '^git@github.com:(.*)\.git$' ]]; then
        echo "https://github.com/$match[1]"
    elif [[ "$origin" =~ '^https://github.com/(.*)\.git$' ]]; then
        echo "https://github.com/$match[1]"
    elif [[ -n "$origin" ]]; then
        echo "$origin"
    else
        echo "https://github.com/gp0119/MenuCal"
    fi
}

function find_sign_update() {
    if [[ -n "${SPARKLE_SIGN_UPDATE:-}" && -x "$SPARKLE_SIGN_UPDATE" ]]; then
        echo "$SPARKLE_SIGN_UPDATE"
        return
    fi

    if [[ -x "bin/sign_update" ]]; then
        echo "bin/sign_update"
        return
    fi

    find "$HOME/Library/Developer/Xcode/DerivedData" \
        -path "*/Sparkle/bin/sign_update" \
        -type f \
        -perm -u+x \
        -print \
        -quit 2>/dev/null || true
}

function create_zip() {
    echo "Creating ZIP: $ZIP_PATH"
    rm -f "$ZIP_PATH"
    ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"
}

function create_dmg() {
    echo "Creating DMG: $DMG_PATH"
    rm -rf "$DMG_STAGING_DIR"
    mkdir -p "$DMG_STAGING_DIR"
    cp -R "$APP_PATH" "$DMG_STAGING_DIR/"
    ln -s /Applications "$DMG_STAGING_DIR/Applications"
    rm -f "$DMG_PATH"
    hdiutil create \
        -volname "$APP_NAME $APP_TAG_NAME" \
        -srcfolder "$DMG_STAGING_DIR" \
        -ov \
        -format UDZO \
        "$DMG_PATH" >/dev/null
}

function create_appcast_item() {
    local download_url="$1"
    local file_length
    local enclosure_attrs="url=\"$download_url\" type=\"application/octet-stream\""
    local sign_update

    file_length="$(stat -f%z "$DMG_PATH")"
    sign_update="$(find_sign_update)"
    if [[ -n "$SPARKLE_KEY_FILE" && -f "$SPARKLE_KEY_FILE" && -n "$sign_update" ]]; then
        local signature
        signature="$("$sign_update" -f "$SPARKLE_KEY_FILE" "$DMG_PATH")"
        if [[ "$signature" != *' length='* ]]; then
            signature="$signature length=\"$file_length\""
        fi
        enclosure_attrs="$enclosure_attrs $signature"
    elif [[ -n "${SPARKLE_KEY:-}" && -n "$sign_update" ]]; then
        local signature
        signature="$(echo "$SPARKLE_KEY" | "$sign_update" -f - "$DMG_PATH")"
        if [[ "$signature" != *' length='* ]]; then
            signature="$signature length=\"$file_length\""
        fi
        enclosure_attrs="$enclosure_attrs $signature"
    else
        echo "Skipping Sparkle signature: SPARKLE_KEY_FILE/SPARKLE_KEY or sign_update is unavailable." >&2
        enclosure_attrs="$enclosure_attrs length=\"$file_length\""
    fi

    {
        echo "<item>"
        echo "    <title>$APP_NAME $APP_VERSION</title>"
        if [[ -n "$RELEASE_NOTES_URL" ]]; then
            echo "    <sparkle:releaseNotesLink>$RELEASE_NOTES_URL</sparkle:releaseNotesLink>"
        fi
        echo "    <pubDate>$(LC_ALL=C date -u "+%a, %d %b %Y %H:%M:%S %z")</pubDate>"
        echo "    <sparkle:version>$APP_BUILD</sparkle:version>"
        echo "    <sparkle:shortVersionString>$APP_VERSION</sparkle:shortVersionString>"
        echo "    <sparkle:minimumSystemVersion>$MIN_SYSTEM_VERSION</sparkle:minimumSystemVersion>"
        echo "    <enclosure $enclosure_attrs />"
        echo "</item>"
    } > "$APPCAST_ITEM_PATH"
}

tag="$(latest_tag)"
if [[ -z "$APP_VERSION" && -n "$tag" ]]; then
    APP_VERSION="$(version_from_tag "$tag")"
fi
if [[ -z "$APP_VERSION" ]]; then
    APP_VERSION="$(project_setting MARKETING_VERSION)"
fi
if [[ -z "$APP_BUILD" ]]; then
    APP_BUILD="$(git_commit_count)"
fi
if [[ -z "$APP_BUILD" ]]; then
    APP_BUILD="$(project_setting CURRENT_PROJECT_VERSION)"
fi
if [[ -z "$APP_TAG_NAME" ]]; then
    APP_TAG_NAME="${tag:-v$APP_VERSION}"
fi

if [[ -z "$APP_VERSION" || -z "$APP_BUILD" ]]; then
    echo "Failed to determine app version or build number." >&2
    exit 1
fi

mkdir -p "$BUILD_DIR"

echo "APP_NAME=$APP_NAME"
echo "APP_VERSION=$APP_VERSION"
echo "APP_BUILD=$APP_BUILD"
echo "APP_TAG_NAME=$APP_TAG_NAME"
echo "MIN_SYSTEM_VERSION=$MIN_SYSTEM_VERSION"

if [[ "$SKIP_ARCHIVE" == false ]]; then
    sign_args=()
    if [[ "$AD_HOC_SIGNING" == true ]]; then
        sign_args+=(CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM=)
    fi

    xcodebuild archive \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination "$DESTINATION" \
        -archivePath "$ARCHIVE_PATH" \
        MARKETING_VERSION="$APP_VERSION" \
        CURRENT_PROJECT_VERSION="$APP_BUILD" \
        "${sign_args[@]}"
fi

APP_PATH="$ARCHIVE_PATH/Products/Applications/$APP_NAME.app"
if [[ ! -d "$APP_PATH" ]]; then
    echo "$APP_PATH does not exist. Run without --skip-archive first." >&2
    exit 1
fi

if [[ "$SKIP_ZIP" == false ]]; then
    create_zip
fi

if [[ "$SKIP_DMG" == false ]]; then
    create_dmg
    create_appcast_item "$(repo_url)/releases/download/$APP_TAG_NAME/$APP_NAME.dmg"
fi

echo ""
echo "Done:"
[[ "$SKIP_ZIP" == true ]] || echo "  ZIP: $ZIP_PATH"
[[ "$SKIP_DMG" == true ]] || echo "  DMG: $DMG_PATH"
[[ "$SKIP_DMG" == true ]] || echo "  Appcast item: $APPCAST_ITEM_PATH"
