# Code Generation

Every component which needs the protobuf and the generated code, they do it for themselves. 




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