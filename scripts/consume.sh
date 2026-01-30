#!/bin/bash
set -e

TOPIC=$1
if [ -z "$TOPIC" ]; then
  echo "Usage: $0 <topic>"
  echo "Example: $0 llm.status"
  exit 1
fi

echo "Consuming from topic: $TOPIC"
echo ""

rpk topic consume "$TOPIC" --profile ondash
