from google.protobuf.internal import enum_type_wrapper as _enum_type_wrapper
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from collections.abc import Mapping as _Mapping
from typing import ClassVar as _ClassVar, Optional as _Optional, Union as _Union

DESCRIPTOR: _descriptor.FileDescriptor

class FileState(int, metaclass=_enum_type_wrapper.EnumTypeWrapper):
    __slots__ = ()
    FILE_STATE_UNSPECIFIED: _ClassVar[FileState]
    FILE_STATE_CREATED: _ClassVar[FileState]
    FILE_STATE_UPLOADED: _ClassVar[FileState]
    FILE_STATE_SCHEDULED: _ClassVar[FileState]
    FILE_STATE_PROCESSING: _ClassVar[FileState]
    FILE_STATE_PROCESSED: _ClassVar[FileState]
    FILE_STATE_DELETED: _ClassVar[FileState]
    FILE_STATE_ERROR: _ClassVar[FileState]
    FILE_STATE_CANCELLED: _ClassVar[FileState]

class FileCommandType(int, metaclass=_enum_type_wrapper.EnumTypeWrapper):
    __slots__ = ()
    FILE_COMMAND_UNSPECIFIED: _ClassVar[FileCommandType]
    FILE_COMMAND_EXTRACT: _ClassVar[FileCommandType]
    FILE_COMMAND_OVERWRITE: _ClassVar[FileCommandType]
    FILE_COMMAND_DELETE: _ClassVar[FileCommandType]
    FILE_COMMAND_CANCEL: _ClassVar[FileCommandType]
    FILE_COMMAND_RECALCULATE: _ClassVar[FileCommandType]
FILE_STATE_UNSPECIFIED: FileState
FILE_STATE_CREATED: FileState
FILE_STATE_UPLOADED: FileState
FILE_STATE_SCHEDULED: FileState
FILE_STATE_PROCESSING: FileState
FILE_STATE_PROCESSED: FileState
FILE_STATE_DELETED: FileState
FILE_STATE_ERROR: FileState
FILE_STATE_CANCELLED: FileState
FILE_COMMAND_UNSPECIFIED: FileCommandType
FILE_COMMAND_EXTRACT: FileCommandType
FILE_COMMAND_OVERWRITE: FileCommandType
FILE_COMMAND_DELETE: FileCommandType
FILE_COMMAND_CANCEL: FileCommandType
FILE_COMMAND_RECALCULATE: FileCommandType

class FileEventEnvelope(_message.Message):
    __slots__ = ("id", "file_id", "filename", "timestamp", "file_event", "file_cmd")
    ID_FIELD_NUMBER: _ClassVar[int]
    FILE_ID_FIELD_NUMBER: _ClassVar[int]
    FILENAME_FIELD_NUMBER: _ClassVar[int]
    TIMESTAMP_FIELD_NUMBER: _ClassVar[int]
    FILE_EVENT_FIELD_NUMBER: _ClassVar[int]
    FILE_CMD_FIELD_NUMBER: _ClassVar[int]
    id: str
    file_id: str
    filename: str
    timestamp: int
    file_event: FileEvent
    file_cmd: FileCommand
    def __init__(self, id: _Optional[str] = ..., file_id: _Optional[str] = ..., filename: _Optional[str] = ..., timestamp: _Optional[int] = ..., file_event: _Optional[_Union[FileEvent, _Mapping]] = ..., file_cmd: _Optional[_Union[FileCommand, _Mapping]] = ...) -> None: ...

class FileEvent(_message.Message):
    __slots__ = ("path", "state", "message", "error", "progress", "project_id", "schema_name")
    PATH_FIELD_NUMBER: _ClassVar[int]
    STATE_FIELD_NUMBER: _ClassVar[int]
    MESSAGE_FIELD_NUMBER: _ClassVar[int]
    ERROR_FIELD_NUMBER: _ClassVar[int]
    PROGRESS_FIELD_NUMBER: _ClassVar[int]
    PROJECT_ID_FIELD_NUMBER: _ClassVar[int]
    SCHEMA_NAME_FIELD_NUMBER: _ClassVar[int]
    path: str
    state: FileState
    message: str
    error: str
    progress: str
    project_id: str
    schema_name: str
    def __init__(self, path: _Optional[str] = ..., state: _Optional[_Union[FileState, str]] = ..., message: _Optional[str] = ..., error: _Optional[str] = ..., progress: _Optional[str] = ..., project_id: _Optional[str] = ..., schema_name: _Optional[str] = ...) -> None: ...

class FileCommand(_message.Message):
    __slots__ = ("command", "project_id", "user_id", "company_name", "period_start", "period_end", "s3_path", "schema_name")
    COMMAND_FIELD_NUMBER: _ClassVar[int]
    PROJECT_ID_FIELD_NUMBER: _ClassVar[int]
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    COMPANY_NAME_FIELD_NUMBER: _ClassVar[int]
    PERIOD_START_FIELD_NUMBER: _ClassVar[int]
    PERIOD_END_FIELD_NUMBER: _ClassVar[int]
    S3_PATH_FIELD_NUMBER: _ClassVar[int]
    SCHEMA_NAME_FIELD_NUMBER: _ClassVar[int]
    command: FileCommandType
    project_id: str
    user_id: str
    company_name: str
    period_start: str
    period_end: str
    s3_path: str
    schema_name: str
    def __init__(self, command: _Optional[_Union[FileCommandType, str]] = ..., project_id: _Optional[str] = ..., user_id: _Optional[str] = ..., company_name: _Optional[str] = ..., period_start: _Optional[str] = ..., period_end: _Optional[str] = ..., s3_path: _Optional[str] = ..., schema_name: _Optional[str] = ...) -> None: ...
