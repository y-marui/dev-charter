#!/usr/bin/env bash
# Update badge.json to match the current VERSION.
# Run this whenever you update the VERSION file.
set -euo pipefail

VERSION=$(head -1 VERSION 2>/dev/null || echo "")
if [ -z "$VERSION" ]; then
  echo "ERROR: VERSION file not found or empty" >&2
  exit 1
fi

cat > badge.json <<EOF
{
  "schemaVersion": 1,
  "label": "dev-charter",
  "message": "${VERSION}",
  "color": "blue"
}
EOF

echo "badge.json updated to ${VERSION}"
