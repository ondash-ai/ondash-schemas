# Versioning


### Versioning Strategy

Schemas are organized by domain and version:
- `{domain}/{version}/{schema}.proto`
- Example: `chat/v1/chat.proto`, `chat/v1/events.proto`

**Version incrementing:**
- **v1 → v2**: Breaking changes (field removal, type changes)
- **Patch updates**: Additive changes (new optional fields)



**Guidelines:**
- Use optional fields for non-breaking changes
- Never remove or rename existing fields (breaks compatibility)
- Add new message types for major changes
- Increment version (v1 → v2) for breaking changes



# Tag versions semantically
```bash
git tag v1.0.0  # Initial release
git tag v1.1.0  # New field added (backward compatible)
git tag v2.0.0  # Breaking change
```

# Services pin to specific versions
```
# frontend/package.json
"@yourcompany/schemas": "^1.1.0"  # Allow patches
```
# For breaking changes, coordinate updates across services