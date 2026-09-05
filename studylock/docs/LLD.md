# Low-Level Design

## 1. Flutter modules

### `FocusProvider`

`FocusProvider` owns:

- `Timer? _timer`
- `StreamSubscription<PhoneState>? _phoneStateSubscription`
- `FocusTimerModel` state: `idle`, `focusing`, or `breaking`

`startSessionTimer`:

1. Cancels an existing timer and phone subscription.
2. Checks `AppBlockerService.isAccessibilityServiceEnabled`.
3. Opens Android settings and returns when the service is disabled.
4. Requests phone permission and subscribes to call state.
5. Filters configured restricted packages.
6. Invokes `AppBlockerService.startBlocking`.
7. Starts a one-second countdown.

`resetSessionTimer` and timer completion call `stopBlocking`.

### `AppBlockerService`

`lib/services/app_lockdown_service.dart` wraps the channel:

```text
com.example.studylock/blocker
```

The wrapper should remain the only Flutter call site for Android lockdown methods.

### `AiFunctions`

`AiFunctions` uses a shared Dio client and exposes:

- `uploadfile(PlatformFile)` returning `file_uri`
- `chatAPI(fileUri, message)` returning a text stream
- `getMcqs(fileUri)` returning `Map<String, dynamic>`

## 2. Android implementation

### Manifest

`AndroidManifest.xml` declares `AppBlockerService` with:

- `android.permission.BIND_ACCESSIBILITY_SERVICE`
- `android.accessibilityservice.AccessibilityService`
- `res/xml/accessibilityservice.xml`

### `MainActivity`

The method channel handles:

- `isAccessibilityServiceEnabled`: reads `Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES` and compares it with the app service component.
- `openAccessibilitySettings`: starts `Settings.ACTION_ACCESSIBILITY_SETTINGS`.
- `startBlocking`: stores packages and enables the in-memory service state.
- `stopBlocking`: clears packages and disables blocking.

### `AppBlockerService`

The service listens for `TYPE_WINDOW_STATE_CHANGED`.

Allowed packages:

- StudyLock application package.
- Resolved default launcher plus common launcher fallbacks.
- Default dialer from `TelecomManager`.
- Default SMS package from `Telephony.Sms`.
- Android, System UI, and Settings.

In strict mode, represented by an empty restricted list, every other observed package is redirected to StudyLock. A non-empty list blocks only packages in that list.

## 3. Data and state

- Focus state is in-memory Riverpod state.
- Lockdown state is in-memory companion-object state in `AppBlockerService`.
- Uploaded-file references are held by the AI workflow state.
- No local database or persistent authentication store is currently used.

## 4. Error handling

- Android returns `ACCESSIBILITY_DISABLED` when a start request arrives without the service enabled.
- Dio failures are logged only in debug mode and mapped to user-facing fallback errors.
- Backend error schemas are not yet strongly typed.

## 5. Important implementation constraints

- Accessibility services cannot guarantee enforcement against every OEM-specific system surface.
- The service must never block Android Settings or the launcher, or the user could lose a recovery path.
- Timer and native blocking state can diverge after process death; persistent recovery is a future requirement.
- The backend base URL should be moved to build-time configuration before production release.
