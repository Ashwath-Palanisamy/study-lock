# Product Requirements Document

## 1. Product summary

StudyLock helps students prepare from their own study material and protect a timed focus session from distracting Android applications.

## 2. Goals

1. Start a reliable, visible focus timer.
2. Prevent accidental access to distracting Android applications during a session.
3. Keep phone, default SMS, launcher, Settings, and StudyLock available.
4. Let students upload supported study material and use AI-assisted chat and MCQ generation.
5. Clearly explain and request the Android Accessibility capability required for lockdown.

## 3. User stories and acceptance criteria

### Focus session

- As a student, I can choose a duration between 5 and 60 minutes.
- Starting a session requires the StudyLock Accessibility Service to be enabled.
- While active, the timer displays remaining minutes and seconds.
- Completing or resetting a session disables app blocking.
- An active phone call pauses the focus timer and the timer resumes after the call ends.

### Lockdown

- During a session, pressing Home can take me to the launcher.
- Attempting to open a blocked application returns me to StudyLock.
- The default phone and SMS applications remain available.
- StudyLock, Android System UI, and Settings remain available.
- If the Accessibility Service is disabled, the session does not start.

### Preparation

- I can select PDF, TXT, or DOCX material.
- I can upload the selected material.
- I can ask questions about the uploaded material.
- I can request generated MCQs.

## 4. Non-functional requirements

- Android lockdown actions should occur promptly after a window-state event.
- The app must not silently start a session when required permissions are missing.
- Network failures must surface a user-readable error.
- API credentials and model-provider secrets must never be stored in the mobile app.
- The application should remain usable when the AI backend is unavailable.

## 5. Out of scope

- iOS app blocking.
- Device-owner or enterprise kiosk enforcement.
- Cross-device session synchronization.
- Persistent session recovery after process death.
- Backend implementation and deployment, which are external to this repository.

## 6. Success metrics

- A user can complete the Accessibility setup without developer assistance.
- A focus session starts only with the required service enabled.
- Blocked app launches are redirected consistently on supported Android versions.
- Upload, chat, and MCQ flows provide deterministic success or error states.
