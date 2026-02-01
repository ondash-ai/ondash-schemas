
# Tools

# Generating code with protoc
You can use google protoc for generating code. 

**Prerequisites**:
```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go get google.golang.org/protobuf
```


example
```bash
#!/bin/bash
set -e

SCHEMA_DIR="../ondash-schemas"
OUTPUT_DIR="internal/pb"

rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR

# Find all .proto files
PROTO_FILES=$(find $SCHEMA_DIR/schemas -name "*.proto")

protoc \
  --go_out=$OUTPUT_DIR \            # go code
  --go_opt=paths=source_relative \  # go code
  --proto_path=$SCHEMA_DIR \
  $PROTO_FILES

echo "✓ Go schemas generated -> $OUTPUT_DIR"
```


```
more examples
```bash
#!/bin/bash
# generate.sh

# TypeScript for Frontend
protoc --ts_proto_out=frontend/src/types schemas/chat.proto

# Python for AI Agent & Backend
protoc --python_out=backend/generated --pyi_out=backend/generated schemas/chat.proto

# GraphQL Schema (via intermediate JSON)
protoc --plugin=protoc-gen-jsonschema --jsonschema_out=. schemas/chat.proto
node scripts/jsonschema-to-graphql.js

```
```

# Kafka command line tool
### Prerequisites

- `jq` - JSON processor for Kafka scripts
- `rpk` - Redpanda CLI for testing
- Access to Redpanda cluster at `ondash:30081`

### Installation

```bash
# macOS
brew install jq

# Install rpk
brew install redpanda-data/tap/redpanda
```

### Message Production

Using `rpk` CLI:

```bash
# Chat messages (schema id: 2)
rpk topic produce chat-messages --profile ondash \
  --schema-id 2 \
  --schema-type chat.v1.Message

# File events (schema id: 1)
rpk topic produce file-events --profile ondash \
  --schema-id 1 \
  --schema-type file.v1.FileEvent
```

Verify topics exist:
```bash
rpk topic list --profile ondash
```

### Message Production Fails

Validate JSON structure matches proto:
```bash
# Check schema structure
protoc --decode=chat.v1.Message schemas/chat/v1/chat.proto < message.bin
```


