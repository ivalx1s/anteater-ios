#!/bin/bash
#
# This script recursively replaces all occurrences of a given word (in file and directory names,
# as well as in file contents) within the current directory (excluding the .git directory).
# It also renames the current directory if its name contains the old word.
#
# The script takes two arguments: the old word and the new word.
#
# Features:
# 1. Renames all files and directories containing `old_word` or its lowercase variant `old_word_lower`
#    to use `new_word` and `new_word_lower` respectively.
# 2. Modifies file contents to replace all occurrences of `old_word` and `old_word_lower`.
# 3. Attempts to rename the current working directory if it contains `old_word` or `old_word_lower`.
# 4. The script is self-deleting after completion by default.
# 5. An optional `-v` or `--verbose` flag can be specified to see detailed output.
# 6. An optional `--no-delete` flag can be specified to prevent self-deletion.
#
# Usage:
#   ./rename_script.sh [--no-delete] [-v|--verbose] old_word new_word
#
# Example:
#   ./rename_script.sh Shopmate Shopbro
#
# Will rename and replace all "Shopmate" to "Shopbro" (and "shopmate" to "shopbro") and rename the current directory if needed.
#

set -euo pipefail

verbose=false
auto_delete=true
script_filename=$(basename "$0")

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            verbose=true
            shift
            ;;
        --no-delete)
            auto_delete=false
            shift
            ;;
        *)
            if [ -z "${old_word:-}" ]; then
                old_word="$1"
            elif [ -z "${new_word:-}" ]; then
                new_word="$1"
            else
                echo "Usage: $0 [--no-delete] [-v|--verbose] old_word new_word"
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate arguments
if [ -z "${old_word:-}" ] || [ -z "${new_word:-}" ]; then
    echo "Usage: $0 [--no-delete] [-v|--verbose] old_word new_word"
    exit 1
fi

old_word_lower=$(echo "$old_word" | tr '[:upper:]' '[:lower:]')
new_word_lower=$(echo "$new_word" | tr '[:upper:]' '[:lower:]')

# Arrays to track failures
declare -a rename_failures=()

# --- Function: rename_items ---
rename_items() {
    local path="$1"
    local newpath
    newpath=$(echo "$path" | sed -e "s/${old_word}/${new_word}/g" -e "s/${old_word_lower}/${new_word_lower}/g")

    if [ "$path" != "$newpath" ]; then
        mkdir -p "$(dirname "$newpath")"
        if [ -d "$path" ]; then
            $verbose && echo "Renaming directory: $path -> $newpath"
            if [ -e "$newpath" ]; then
                $verbose && echo "Target directory $newpath already exists. Merging contents."
                rsync -a "$path"/ "$newpath"/
                rm -rf "$path"
            else
                if ! mv "$path" "$newpath"; then
                    rename_failures+=("$path")
                fi
            fi
        else
            $verbose && echo "Renaming file: $path -> $newpath"
            if ! mv "$path" "$newpath"; then
                rename_failures+=("$path")
            fi
        fi
    fi
}

# --- Function: replace_in_file ---
replace_in_file() {
    local file="$1"

    # If file doesn't exist or is a directory, skip
    if [ ! -f "$file" ]; then
        return
    fi

    LC_ALL=C sed -i.bak \
      -e "s/${old_word_lower}_icon\.jpg/${new_word_lower}_icon.jpg/g" \
      -e "s/${old_word}/${new_word}/g" \
      -e "s/${old_word_lower}/${new_word_lower}/g" \
      "$file" 2>/dev/null || true

    rm -f "$file.bak"
}

$verbose && echo "Starting replacement process..."

# --- Step 1: Rename directories and files (bottom-up) ---
# Exclude the script itself from renaming
find . -depth ! -path "*/.git/*" ! -name "$script_filename" | while read -r item; do
    rename_items "$item"
done

if [ ${#rename_failures[@]} -ne 0 ]; then
    echo "ERROR: Some items could not be renamed:"
    for f in "${rename_failures[@]}"; do
        echo "  $f"
    done
    exit 1
fi

# --- Step 2: Replace contents in files ---
# Exclude the script itself from content replacement
find . -type f ! -path "*/.git/*" ! -name "$script_filename" | while read -r file; do
    replace_in_file "$file"
done

$verbose && echo "Verifying replacement (excluding .git)..."

# --- Step 3: Verification ---
if grep -r -i --exclude-dir=.git "$old_word" .; then
    echo "ERROR: Found remaining instances of '$old_word'."
    grep -r -i --exclude-dir=.git "$old_word" . | sed 's/^/  /'
    exit 1
fi

echo "SUCCESS: All instances of '$old_word' have been replaced with '$new_word'."

# --- Step 4: Attempt to rename the current working directory ---
parent_dir=$(dirname "$(pwd)")
current_dir_basename=$(basename "$(pwd)")
new_dir_name=$(echo "$current_dir_basename" | sed -e "s/${old_word}/${new_word}/g" -e "s/${old_word_lower}/${new_word_lower}/g")

if [ "$current_dir_basename" != "$new_dir_name" ]; then
    $verbose && echo "Renaming current directory: $current_dir_basename -> $new_dir_name"
    cd "$parent_dir"
    mv "$current_dir_basename" "$new_dir_name"
    cd "$new_dir_name"
fi

# --- Step 5: Self-delete (if auto_delete is true) ---
if $auto_delete; then
    if [ -f "$script_filename" ]; then
        rm -- "$script_filename"
    else
        $verbose && echo "Script file $script_filename not found for deletion."
    fi
fi