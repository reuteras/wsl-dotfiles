#!/bin/bash
#
# Compare the files in this repo against their counterparts in the sibling
# ../dotfiles repo and offer to copy over any that differ.
#
# Usage: ./check-dotfiles-sync.sh [-y|--yes] [-n|--dry-run]

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$(cd "$SCRIPT_DIR/../dotfiles" 2>/dev/null && pwd)"

if [[ -z "$SOURCE_DIR" ]]; then
    echo "Could not find sibling dotfiles repo at $SCRIPT_DIR/../dotfiles" >&2
    exit 1
fi

ASSUME_YES=0
DRY_RUN=0

for arg in "$@"; do
    case "$arg" in
        -y | --yes) ASSUME_YES=1 ;;
        -n | --dry-run) DRY_RUN=1 ;;
        -h | --help)
            echo "Usage: $0 [-y|--yes] [-n|--dry-run]"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            exit 1
            ;;
    esac
done

# Top-level files that only exist in this repo and have no dotfiles counterpart.
SKIP_TOP_LEVEL=(LICENSE README.md wsl_debian_setup.sh check-dotfiles-sync.sh)

is_skipped() {
    local rel="$1"
    [[ "$rel" == */* ]] && return 1
    for skip in "${SKIP_TOP_LEVEL[@]}"; do
        [[ "$rel" == "$skip" ]] && return 0
    done
    return 1
}

# Echo the matching path in the source repo for a given relative path, trying
# the exact name first and then toggling a leading dot on top-level files
# (e.g. .bashrc <-> bashrc).
find_source_path() {
    local rel="$1"
    local candidate="$SOURCE_DIR/$rel"
    if [[ -f "$candidate" ]]; then
        echo "$candidate"
        return 0
    fi
    if [[ "$rel" != */* ]]; then
        if [[ "$rel" == .* ]]; then
            candidate="$SOURCE_DIR/${rel#.}"
        else
            candidate="$SOURCE_DIR/.$rel"
        fi
        if [[ -f "$candidate" ]]; then
            echo "$candidate"
            return 0
        fi
    fi
    return 1
}

show_diff() {
    local src="$1" dst="$2"
    if command -v git >/dev/null 2>&1; then
        git --no-pager diff --no-index -- "$dst" "$src"
    else
        diff -u "$dst" "$src"
    fi
}

checked=0
updated=0
skipped=0

while IFS= read -r -d '' file; do
    rel="${file#"$SCRIPT_DIR"/}"

    is_skipped "$rel" && continue

    src=$(find_source_path "$rel") || {
        skipped=$((skipped + 1))
        continue
    }

    checked=$((checked + 1))

    cmp -s "$file" "$src" && continue

    echo
    echo "=== $rel differs from dotfiles/${src#"$SOURCE_DIR"/} ==="
    show_diff "$src" "$file"

    if [[ $DRY_RUN -eq 1 ]]; then
        continue
    fi

    if [[ $ASSUME_YES -eq 1 ]]; then
        reply=y
    else
        read -r -p "Copy updated version from dotfiles into wsl-dotfiles? [y/N] " reply
    fi

    if [[ "$reply" =~ ^[Yy]$ ]]; then
        cp -p "$src" "$file"
        echo "Updated $rel"
        updated=$((updated + 1))
    fi
done < <(find "$SCRIPT_DIR" -type f \
    -not -path "$SCRIPT_DIR/.git/*" \
    -not -path "$SCRIPT_DIR/.github/*" \
    -print0)

echo
echo "Checked $checked file(s), updated $updated, skipped $skipped with no dotfiles counterpart."
