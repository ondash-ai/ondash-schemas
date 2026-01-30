#!/bin/bash
set -e

DOMAIN=$1
if [ -z "$DOMAIN" ]; then
  echo "Usage: $0 <domain>"
  echo "Example: $0 llm"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Auto-detect latest version
latest=$(ls -d "$REPO_ROOT/schemas/$DOMAIN"/v* 2>/dev/null | sort -V | tail -1)
if [ -z "$latest" ]; then
  echo "Error: No version directory found for domain '$DOMAIN'"
  exit 1
fi

TOPICS_FILE="$latest/topics.json"
if [ ! -f "$TOPICS_FILE" ]; then
  echo "Error: $TOPICS_FILE not found"
  exit 1
fi

# Read topics from JSON array
topics=$(jq -r '.[]' "$TOPICS_FILE")
if [ -z "$topics" ]; then
  echo "No topics defined for domain '$DOMAIN'"
  exit 0
fi

echo "Creating topics for domain: $DOMAIN ($(basename "$latest"))"
echo ""

for topic in $topics; do
  echo "Creating topic: $topic"
  rpk topic create "$topic" --profile ondash || true
done

echo ""
echo "Done."
