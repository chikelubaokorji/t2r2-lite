#!/bin/bash
# Proto Evolution Checker - Continuous Integration Github Actions
set -euo pipefail

PROTO_DIR="modules/contracts/src/main/protobuf"
FAIL=0

echo "Running Proto File Evolution Guidelines checks..."

# 0. GET VALID FILES
# Find all .proto files, BUT excludes 'scalapb' directory (external dependency) and 'target' directory (build artifacts)
PROTO_FILES=$(find "$PROTO_DIR" -name "*.proto" -not -path "*/scalapb/*" -not -path "*/target/*")

# If no files are found, exit early to prevent grep errors
if [ -z "$PROTO_FILES" ]; then
  echo "No internal Proto files found to check. Skipping."
  exit 0
fi

# 1. Check for 'required' keyword
# We pass $PROTO_FILES to grep so it only checks your specific files
if grep -w 'required' $PROTO_FILES; then
  echo "Error: 'required' fields are not allowed (Proto2 concept forbidden in Proto3)."
  FAIL=1
fi

# 2. Check for missing 'reserved' declarations after field removal
# Using -n to print line numbers for easier debugging
if grep -P '^\s*(int32|int64|string|bool|bytes|float|double)\s+\w+\s*=\s*\d+\s*;' $PROTO_FILES | grep -v 'reserved'; then
  echo "Warning: Consider reserving field numbers after removal to prevent reuse."
fi

# 3. Check for field renaming (heuristic: same number, different name)
# Added `grep -v "scalapb"` to exclude external files from git diff checks
if git diff --cached --name-only | grep '\.proto$' | grep -v "scalapb" | while read -r file; do
  git diff --cached "$file" | grep -E '^\+|^-' | grep -E '=\s*[0-9]+;' | cut -d= -f2 | sort | uniq -d
done | grep .; then
  echo "Warning: Field numbers appear reused with different names. Ensure semantics are stable."
fi

# 4. Check for audit fields
# Note: This check warns if 'created_at' is missing entirely from the file list. 
if ! grep -q 'created_at' $PROTO_FILES; then
  echo "Warning: Missing 'created_at' timestamp field for auditability."
fi

# 5. Check for map usage in core messages
if grep 'map<' $PROTO_FILES; then
  echo "Warning: Map fields detected. Ensure they are used only for non-critical metadata."
fi

exit $FAIL