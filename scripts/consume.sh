#!/bin/bash
set -e

TOPIC=$1
if [ -z "$TOPIC" ]; then
  echo "Usage: $0 <topic>"
  echo "Example: $0 chat"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Derive domain from topic name (e.g., llm.status -> llm, chat -> chat)
DOMAIN="${TOPIC%%.*}"

# Auto-detect latest version to find proto file
latest=$(ls -d "$REPO_ROOT/schemas/$DOMAIN"/v* 2>/dev/null | sort -V | tail -1)

# Look up schema from registry
SCHEMA_REGISTRY_URL="http://ondash:30081"
SUBJECT="${TOPIC}-value"
SCHEMA_ID=$(curl -s "$SCHEMA_REGISTRY_URL/subjects/$SUBJECT/versions/latest" | jq -r '.id' 2>/dev/null)

if [ -n "$SCHEMA_ID" ] && [ "$SCHEMA_ID" != "null" ] && [ -n "$latest" ]; then
  PROTO_FILE=$(find "$latest" -maxdepth 1 -name "*.proto" | head -1)
  PACKAGE=$(grep '^package ' "$PROTO_FILE" | sed 's/package //;s/;//')
  MESSAGE=$(grep '^message ' "$PROTO_FILE" | head -1 | sed 's/message //;s/ {//')
  SCHEMA_TYPE="${PACKAGE}.${MESSAGE}"

  echo "Consuming from topic: $TOPIC (schema: $SCHEMA_TYPE, id: $SCHEMA_ID)"
  echo ""
  rpk topic consume "$TOPIC" --profile ondash --schema-id "$SCHEMA_ID" --schema-type "$SCHEMA_TYPE"
else
  echo "Warning: No schema found for subject '$SUBJECT', consuming raw"
  echo ""
  rpk topic consume "$TOPIC" --profile ondash
fi
