#!/bin/bash
# Proto Evolution Checker - Continuous Integration Github Actions
set -euo pipefail

PROTO_DIR="modules/contracts/src/main/protobuf"
FAIL=0

echo "Running Proto File Evolution Guidelines checks..."

# 1. Check for 'required' keyword
if grep -r --include="*.proto" '\brequired\b' "$PROTO_DIR"; then
  echo "Error: 'required' fields are not allowed."
  FAIL=1
fi

# 2. Check for missing 'reserved' declarations after field removal
if grep -r --include="*.proto" -P '^\s*(int32|int64|string|bool|bytes|float|double)\s+\w+\s*=\s*\d+\s*;' "$PROTO_DIR" | grep -v 'reserved'; then
  echo "Warning: Consider reserving field numbers after removal to prevent reuse."
fi

# 3. Check for field renaming (heuristic: same number, different name)
if git diff --cached --name-only | grep '\.proto$' | while read -r file; do
  git diff --cached "$file" | grep -E '^\+|^-' | grep -E '=\s*[0-9]+;' | cut -d= -f2 | sort | uniq -d
done | grep .; then
  echo "Warning: Field numbers appear reused with different names. Ensure semantics are stable."
fi

# 4. Check for audit fields
if ! grep -r --include="*.proto" 'created_at' "$PROTO_DIR"; then
  echo "Warning: Missing 'created_at' timestamp field for auditability."
fi

# 5. Check for map usage in core messages
if grep -r --include="*.proto" 'map<' "$PROTO_DIR"; then
  echo "Warning: Map fields detected. Ensure they are used only for non-critical metadata."
fi

exit $FAIL
