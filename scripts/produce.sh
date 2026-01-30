#!/bin/bash
set -e

TOPIC=$1
if [ -z "$TOPIC" ]; then
  echo "Usage: $0 <topic>"
  echo "Example: $0 llm.status"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Derive domain and subtopic from topic name (e.g., llm.status -> domain=llm, subtopic=status)
DOMAIN="${TOPIC%%.*}"
SUBTOPIC="${TOPIC#*.}"

# Auto-detect latest version
latest=$(ls -d "$REPO_ROOT/schemas/$DOMAIN"/v* 2>/dev/null | sort -V | tail -1)
if [ -z "$latest" ]; then
  echo "Error: No version directory found for domain '$DOMAIN'"
  exit 1
fi

SAMPLE_FILE="$latest/samples/$SUBTOPIC.json"
if [ ! -f "$SAMPLE_FILE" ]; then
  echo "Error: Sample file not found: $SAMPLE_FILE"
  exit 1
fi

echo "Producing to topic: $TOPIC"
echo "Sample file: $SAMPLE_FILE"
echo ""

cat "$SAMPLE_FILE" | rpk topic produce "$TOPIC" --profile ondash

echo ""
echo "Done."
