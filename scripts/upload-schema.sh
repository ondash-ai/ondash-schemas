#!/bin/bash
set -e

# Registry and topic prefix can be overridden, e.g. for the dev broker:
#   kubectl port-forward -n events svc/redpanda-dev 18081:8081 &
#   SCHEMA_REGISTRY_URL=http://127.0.0.1:18081 TOPIC_PREFIX=dev. ./scripts/upload-schema.sh artifact
SCHEMA_REGISTRY_URL="${SCHEMA_REGISTRY_URL:-http://ondash:30081}"
TOPIC_PREFIX="${TOPIC_PREFIX:-}"

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

# Find the .proto file in the version directory
PROTO_FILE=$(find "$latest" -maxdepth 1 -name "*.proto" | head -1)
if [ -z "$PROTO_FILE" ]; then
  echo "Error: No .proto file found in $latest"
  exit 1
fi

# Read topics from JSON array
topics=$(jq -r '.[]' "$TOPICS_FILE")
if [ -z "$topics" ]; then
  echo "No topics defined for domain '$DOMAIN'"
  exit 0
fi

echo "Uploading schema for domain: $DOMAIN ($(basename "$latest"))"
echo "Proto file: $PROTO_FILE"
echo ""

# Prepare payload
payload=$(jq -n --rawfile schema "$PROTO_FILE" '{schemaType: "PROTOBUF", schema: $schema}')

for topic in $topics; do
  topic="${TOPIC_PREFIX}${topic}"
  subject="${topic}-value"

  echo "Uploading schema for topic: $topic (subject: $subject)"

  # Delete existing subject (ignore errors if it doesn't exist)
  curl -s -X DELETE "$SCHEMA_REGISTRY_URL/subjects/$subject" > /dev/null 2>&1 || true
  curl -s -X DELETE "$SCHEMA_REGISTRY_URL/subjects/$subject?permanent=true" > /dev/null 2>&1 || true

  # Upload new schema
  response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/vnd.schemaregistry.v1+json" \
    -d "$payload" \
    "$SCHEMA_REGISTRY_URL/subjects/$subject/versions")

  http_code=$(echo "$response" | tail -n1)
  body=$(echo "$response" | sed '$d')

  if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
    echo "  Success: $body"
  else
    echo "  Failed (HTTP $http_code): $body"
  fi
done

echo ""
echo "Done."
