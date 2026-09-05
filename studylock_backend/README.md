# StudyLock Backend

## Configuration

Copy `.env.example` to `.env` for local development and set:

- `GOOGLE_API_KEY`: server-side Google AI credential.
- `STUDYLOCK_APP_API_KEY`: long random value required by every API request.

The API expects the client to send:

```text
X-StudyLock-App-Key: <STUDYLOCK_APP_API_KEY>
```

Requests without the key or with an invalid key receive `401 Unauthorized`.
Never commit `.env` or embed the server's Google AI key in the Flutter app.

## Client build

Provide the same app key at build time:

```bash
flutter build apk --dart-define=STUDYLOCK_API_KEY="$STUDYLOCK_APP_API_KEY"
```

The key is necessarily present in the APK and can be extracted by a determined attacker. This gate blocks casual and unauthenticated access; it cannot prove that a request came from an untampered copy of the app. For production-grade app-only access, add Android Play Integrity verification (and App Attest for iOS) or user authentication with short-lived tokens.

## Rate limiting

The backend applies an in-memory sliding-window limit after authentication:

- General endpoints: `RATE_LIMIT_REQUESTS` requests per `RATE_LIMIT_WINDOW_SECONDS`.
- File uploads: `RATE_LIMIT_UPLOADS` requests per window.
- Chat and MCQ generation: `RATE_LIMIT_AI_REQUESTS` requests per window.

Exceeded requests receive `429 Too Many Requests` with a `Retry-After` header. Limits are keyed by client IP, authenticated app key, and route.

This is suitable for a single backend instance. If the service is scaled horizontally, use a shared Redis-backed limiter so callers cannot bypass limits by moving between instances.

## Tests

Run backend tests from this directory:

```bash
uv run pytest
```

Run Flutter tests from the Flutter project:

```bash
flutter test
```