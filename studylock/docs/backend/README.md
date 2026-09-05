# StudyLock Backend

## Scope

The backend is an external HTTP service. Its implementation is not included in this repository. The Flutter client currently targets:

```text
https://study-lock-xakx.onrender.com
```

This document records the client-observed contract and the integration expectations for the backend implementation.

## API contract

### Upload study material

```http
POST /upload-file
Content-Type: multipart/form-data
```

Multipart field:

```text
file: PDF, TXT, or DOCX
```

Expected success response:

```json
{
  "file_uri": "string"
}
```

The returned URI is passed to the chat and MCQ endpoints.

### Stream AI chat

```http
POST /chat?file_uri=<file_uri>&question=<question>
```

The client expects a streamed response body and decodes each response chunk as UTF-8 text.

### Generate MCQs

```http
POST /mcq-ai?file_uri=<file_uri>
```

The client expects a JSON object containing the generated MCQ data. The exact schema is currently consumed as `Map<String, dynamic>` and should be formalized before introducing a versioned public API.

## Backend responsibilities

- Validate file type and size.
- Store uploaded material temporarily or permanently according to the retention policy.
- Extract text from supported document formats.
- Ground chat and MCQ generation in the uploaded material.
- Stream chat output without corrupting UTF-8 boundaries.
- Return stable, actionable HTTP errors.
- Apply authentication, rate limiting, logging redaction, and abuse controls before production use.

## Recommended error contract

The frontend currently maps transport failures to user-facing messages. A future backend should standardize errors as:

```json
{
  "error": {
    "code": "FILE_TOO_LARGE",
    "message": "The uploaded file exceeds the allowed size.",
    "request_id": "string"
  }
}
```

## Security and operations

- Do not expose model-provider keys to the Flutter application.
- Enforce maximum upload size and request timeouts.
- Virus-scan or safely sandbox uploaded files before parsing.
- Avoid logging document contents, questions, or generated answers by default.
- Use HTTPS in all environments.
- Add authentication and per-user quotas before public deployment.
- Configure health checks and metrics for upload, chat, parsing, and model latency.

## Local backend development

No backend source or local backend command is present in this repository. To develop the backend locally, add its service as a separate project and make the Flutter base URL configurable by environment rather than editing `lib/api/api_config.dart`.
