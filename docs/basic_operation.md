# basic operations:
  - create new topic
  - upload schema
  - test: produce
  - test: consume

```bash
# create topics for a domain
./scripts/create-topic.sh llm

# upload schema to registry
./scripts/upload-schema.sh llm

# produce a sample message
./scripts/produce.sh llm.status

# consume messages from a topic
./scripts/consume.sh llm.status
```