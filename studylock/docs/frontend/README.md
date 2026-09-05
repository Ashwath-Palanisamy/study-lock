# StudyLock Frontend

## Overview

The frontend is a Flutter application using Riverpod for state management. It provides:

- A dashboard with Focus Mode and Preparation Mode.
- A focus timer with 5–60 minute duration selection.
- Accessibility-service status and settings navigation.
- File selection for PDF, TXT, and DOCX study material.
- AI upload, streaming chat, and MCQ-generation flows.

## Structure

| Area | Location | Responsibility |
| --- | --- | --- |
| App entry point | `lib/main.dart` | Creates the Material app and Riverpod scope |
| Dashboard | `lib/views/home_dashboard_view.dart` | Main navigation and study tips |
| Focus UI | `lib/views/focus_mode_view.dart` | Permission state, timer controls, and session status |
| Preparation UI | `lib/views/preparation_mode_view.dart` | Study-material selection and upload navigation |
| Focus state | `lib/riverpod/focus_provider.dart` | Timer, phone-call handling, and lockdown orchestration |
| AI state | `lib/riverpod/ai_*.dart` | Upload, scanning, chat, and MCQ state |
| HTTP client | `lib/api/api_config.dart` | Dio base URL and client configuration |
| AI API wrapper | `lib/api/ai_functions.dart` | Upload, chat, and MCQ requests |
| Native bridge | `lib/services/app_lockdown_service.dart` | Flutter `MethodChannel` for Android lockdown |
| Shared widgets | `lib/components/` | Reusable buttons, sections, and text styles |

## Focus-session lifecycle

1. `FocusModeView` checks the custom Android accessibility service.
2. If disabled, the user is sent to Android Accessibility settings.
3. `FocusProvider` requests phone permission and subscribes to phone-state changes.
4. The provider calls `AppBlockerService.startBlocking`.
5. The timer changes the session to `focusing`; an active phone call changes it to `breaking`.
6. Reset or timer completion calls `AppBlockerService.stopBlocking`.

## Native channel contract

Channel: `com.example.studylock/blocker`

| Method | Arguments | Result |
| --- | --- | --- |
| `isAccessibilityServiceEnabled` | none | `bool` |
| `openAccessibilitySettings` | none | `void` |
| `startBlocking` | `restrictedPackages: List<String>` | `bool` |
| `stopBlocking` | none | `void` |

An empty package list enables strict mode in the Android service. The service then blocks packages except the allowed system, launcher, phone, SMS, and StudyLock packages.

## AI HTTP contract

The client uses the base URL in `lib/api/api_config.dart`:

```text
https://study-lock-xakx.onrender.com
```

- `POST /upload-file` — multipart field `file`; returns `file_uri`.
- `POST /chat?file_uri=<uri>&question=<text>` — streamed response body.
- `POST /mcq-ai?file_uri=<uri>` — returns a JSON object containing generated MCQs.

## Development

```bash
flutter pub get
flutter analyze
flutter run
```

Use an Android device for validating Accessibility settings and app redirection. The lockdown feature cannot be fully validated on iOS, desktop, or web targets.
