## Best Practices

### Schema Design

✅ **Do:**
- Use optional fields for flexibility
- Add descriptive comments
- Use semantic versioning for packages
- Keep messages focused and cohesive
- Use `oneof` for union types

❌ **Don't:**
- Remove or rename existing fields
- Change field types (breaks deserialization)
- Use `required` (deprecated in proto3)
- Mix concerns in a single message

### Compatibility

**Backward Compatible Changes:**
- Adding new optional fields
- Adding new message types
- Adding new enum values (with default)

**Breaking Changes:**
- Removing fields
- Renaming fields
- Changing field types
- Changing field numbers