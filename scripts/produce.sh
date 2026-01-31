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

# Look up schema ID from registry
SCHEMA_REGISTRY_URL="http://ondash:30081"
SUBJECT="${TOPIC}-value"
SCHEMA_ID=$(curl -s "$SCHEMA_REGISTRY_URL/subjects/$SUBJECT/versions/latest" | jq -r '.id')

if [ -z "$SCHEMA_ID" ] || [ "$SCHEMA_ID" = "null" ]; then
  echo "Warning: No schema found for subject '$SUBJECT', producing raw JSON"
  cat "$SAMPLE_FILE" | rpk topic produce "$TOPIC" --profile ondash
else
  # Find the proto package to derive the schema type (e.g., chat.v1.Message)
  PROTO_FILE=$(find "$latest" -maxdepth 1 -name "*.proto" | head -1)
  PACKAGE=$(grep '^package ' "$PROTO_FILE" | sed 's/package //;s/;//')
  MESSAGE=$(grep '^message ' "$PROTO_FILE" | head -1 | sed 's/message //;s/ {//')
  SCHEMA_TYPE="${PACKAGE}.${MESSAGE}"

  echo "Schema ID: $SCHEMA_ID, Type: $SCHEMA_TYPE"
  cat "$SAMPLE_FILE" | rpk topic produce "$TOPIC" --profile ondash --schema-id "$SCHEMA_ID" --schema-type "$SCHEMA_TYPE"
fi

echo ""
echo "Done."
