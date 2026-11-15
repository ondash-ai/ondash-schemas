# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Protocol Buffer schema repository for Ondash AI, serving as the single source of truth for data structures shared across multiple services (frontend TypeScript, backend Python, Go microservices, Kafka, etc.).

**Important**: This repository contains **only** the `.proto` schema definitions. Each consuming service generates code locally from these schemas.

## Architecture

**Schema Organization**: Schemas are organized by domain under `schemas/` with versioned subdirectories:
- `schemas/chat/v1/` - Chat message structures with content blocks (text, confirmation, chart, data preview) and event streams
- `schemas/upload/v1/` - File upload metadata

**Code Generation Pattern**:
- Each consuming repository includes this repo as a git submodule or references it as a sibling directory
- Each service generates code locally using their own build scripts
- Services control when to pull schema updates

**Consuming Services**:
- `ondash-frontend` - TypeScript code generation (uses ts-proto)
- `ondash-llm` - Python code generation (uses protoc)
- `ondash-socket` - Go code generation (uses protoc-gen-go)

## Common Commands

### Setup
No package.json: the scripts need only `jq` (`brew install jq`) and `curl`.

### Publishing to Schema Registry
One domain at a time; the topics come from `schemas/<domain>/v<N>/topics.json`.
There is one registry per broker (prod `redpanda`, dev `redpanda-dev`); upload to both.
```bash
# prod registry (ondash:30081 until the prod broker becomes cluster-only)
./scripts/upload-schema.sh artifact

# dev registry: port-forward, dev topics carry the "dev." prefix
kubectl port-forward -n events svc/redpanda-dev 18081:8081 &
SCHEMA_REGISTRY_URL=http://127.0.0.1:18081 TOPIC_PREFIX=dev. ./scripts/upload-schema.sh artifact
```

## Using Schemas in Consuming Services

### Setting up a new service

**Option 1: Sibling directory (current setup)**
```bash
# In consuming repo (ondash-socket, ondash-llm, ondash-frontend)
# Schemas are expected at ../ondash-schemas/schemas/
```

**Option 2: Git submodule**
```bash
# In consuming repo
git submodule add <url-to-ondash-schemas> schemas
git submodule update --init --recursive
```

### Code Generation Examples

**TypeScript (ts-proto)**:
```bash
protoc \
  --plugin=./node_modules/.bin/protoc-gen-ts_proto \
  --ts_proto_out=src/types/schemas \
  --ts_proto_opt=esModuleInterop=true \
  --ts_proto_opt=outputIndex=true \
  ../ondash-schemas/schemas/**/*.proto
```

**Python**:
```bash
protoc \
  --python_out=src/models \
  --pyi_out=src/models \
  --proto_path=../ondash-schemas \
  ../ondash-schemas/schemas/**/*.proto
```

**Go**:
```bash
protoc \
  --go_out=internal/pb \
  --go_opt=paths=source_relative \
  --proto_path=../ondash-schemas \
  ../ondash-schemas/schemas/**/*.proto
```

Note: Go schemas include `go_package` option pointing to `github.com/looptroops/socket/internal/pb/schemas/{domain}/{version}`

## Schema Design Patterns

**Message Metadata Pattern**: The `chat.v1.Message` includes a comprehensive `MessageMetadata` structure tracking:
- Tool execution (ToolCall records with timing)
- Token usage and model version
- Error information
- User/session context
- Service processing tags

**Event Stream Pattern**: The `chat.v1.EventEnvelope` provides real-time event streaming with typed events:
- StatusEvent - Progress updates during execution
- TextEvent - Text content chunks
- ChartEvent - Chart visualizations
- ErrorEvent - Error reporting with severity levels
- CompletionEvent - Task/conversation completion

**Content Block Pattern**: Uses protobuf `oneof` to support multiple content types (TextBlock, ConfirmationBlock, ChartBlock, DataPreviewBlock) in a type-safe way.

**Versioning**: Schemas use package versioning (e.g., `chat.v1`) to support backward compatibility. Breaking changes should increment the version directory.

## Kafka Topics and Schema Validation

**Topics**: `chat-messages` and `upload-messages`

**Redpanda Console**: http://ondash:30011 (configured in `kubernetes/core/redpanda-dev/`)

**Producing Messages**: Use `rpk` with the ondash profile:
```bash
# Chat messages (schema id: 2)
rpk topic produce chat-messages --profile ondash --schema-id 2 --schema-type chat.v1.Message

# Upload messages (schema id: 1)
rpk topic produce upload-messages --profile ondash --schema-id 1 --schema-type upload.v1.Message
```

Provide JSON matching the proto structure - `rpk` will encode to protobuf.

## Important Notes

- **Decentralized code generation**: Each consuming service generates code locally from these schemas
- **Schema updates**: Services pull schema updates when they choose to regenerate code
- **Redpanda Schema Registry**: Configured to upload to `http://ondash:30081` (running in Kubernetes)
  - Port mappings: Schema Registry (30081), Kafka (30092), Pandaproxy (30082)
  - The script uploads schemas in JSON format with `schemaType: "PROTOBUF"`
  - Subject naming: `<topic-name>-value` (e.g., `chat-messages-value`)
- **Dependencies**: Requires `jq` (JSON processor) and `rpk` (Redpanda CLI) installed on the system
- **Protoc plugins**: Each consuming service needs appropriate protoc plugins:
  - TypeScript: `ts-proto` (npm package)
  - Python: Built into `protoc`
  - Go: `protoc-gen-go` (`go install google.golang.org/protobuf/cmd/protoc-gen-go@latest`)
