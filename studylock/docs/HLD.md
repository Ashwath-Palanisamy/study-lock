# High-Level Design

## 1. System context

```text
                  +----------------------------+
                  | External AI HTTP Backend   |
                  | upload / chat / mcq-ai     |
                  +-------------^--------------+
                                |
                         HTTPS / Dio
                                |
+-------------------------------+-------------------------------+
| Flutter StudyLock Application                                  |
| Dashboard | Focus Mode | Preparation Mode | Riverpod State     |
+------------------^-------------------------^------------------+
                   | MethodChannel            | File picker
                   v                          v
        +------------------------+       Local selected file
        | Android MainActivity   |
        | channel endpoint       |
        +-----------^------------+
                    |
                    v
        +------------------------+
        | AppBlockerService      |
        | AccessibilityService   |
        +-----------^------------+
                    |
                    v
          Android window events
```

## 2. Components

- **Flutter presentation**: Material screens and reusable components.
- **Riverpod application state**: Focus timer and AI workflow state.
- **Dio integration**: Calls the external AI backend and handles streaming chat.
- **MainActivity**: Exposes the lockdown method channel to Flutter.
- **AppBlockerService**: Receives Android window-state events and redirects blocked launches.
- **Android Accessibility settings**: Grants or revokes the capability required by the native service.
- **External AI backend**: Stores/parses study files and invokes AI workflows.

## 3. Trust boundaries

- Flutter to Android native code crosses a `MethodChannel`.
- Flutter to backend crosses the public network and must use HTTPS.
- Uploaded files cross from the device to external infrastructure.
- Android Accessibility permission is a sensitive OS capability and must be explicitly user-enabled.

## 4. Primary flows

### Start focus

```text
User -> FocusModeView -> AppBlockerService status
     -> Android settings if disabled
     -> FocusProvider -> phone permission
     -> MainActivity.startBlocking
     -> AppBlockerService enabled
     -> timer starts
```

### Block an app

```text
Android window event -> AppBlockerService
  -> allow StudyLock / launcher / phone / SMS / required system package
  -> otherwise launch StudyLock with is_blocked_attempt=true
```

### Prepare with AI

```text
FilePicker -> selected file -> POST /upload-file
  -> file_uri -> POST /chat or POST /mcq-ai
  -> display streamed answer or generated questions
```

## 5. Deployment view

- Flutter produces an Android APK.
- The backend is deployed independently at the configured Render URL.
- No backend deployment manifests are currently stored in this repository.
