# Services

This is a list of services using the schemas.

# Generating code

The following cli commands should be run in the repository where the generated code wanted.

| Language | Build Tool | Generation Command |
|----------|------------|-------------------|
| Go | Mage | `mage schemas` |
| Python | Invoke | `invoke schemas` |
| TypeScript | npm | `npm run schemas` |


# Services using schemas:

- ondash-llm : llm, it sends answers status errors through this

- ondash-frontend: llm, chat, mail, file to receive every kind of live updates

- update-broker: it needs to filter based on the schemas, therefore it needs to open the protobuf messages 