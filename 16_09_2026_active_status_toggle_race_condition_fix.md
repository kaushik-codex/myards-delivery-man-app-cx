# Audit Report: Active-Status Toggle Race Condition Fix

**Date**: 16 September 2026  
**Project**: 6amMart Delivery Man App (Flutter / Android / iOS)  
**Status**: Completed, Audited & Pushed  

---

## 1. Executive Summary

This report documents the minimal, safe architectural fix resolving the active-status toggle race-condition and state-inversion bug.

### Key Deliverables:
1. **Centralized In-Flight Guard & Deduplication**:
   - Introduced `_isActiveStatusLoading` in `ProfileController` to ensure that duplicate concurrent requests are blocked at the source.
   - Any secondary taps or dispatches arriving while a request is in flight return `false` immediately without triggering network I/O or modifying state.
2. **Compact Inline Loading Indicator**:
   - In `OnlineStatusToggleWidget`, an inline micro-progress indicator (`CircularProgressIndicator`, 13x13, strokeWidth: 2) is rendered directly inside the 22x22 circular thumb.
   - Maintains the exact 80x28 toggle dimensions, corner radius, background track color, status text ("Online" / "Offline"), and thumb position without layout shifts or jitter.
3. **Guaranteed Lock Release**:
   - Wrapped the asynchronous API request in a `try ... finally` block within `ProfileController.updateActiveStatus()`, guaranteeing that `_isActiveStatusLoading` is reset to `false` and `update()` is called in all outcomes (success, server error, timeout, or uncaught network exception).
4. **Cross-Page Synchronization & Lock**:
   - Tap interactions on both the homepage header toggle and Profile screen switch (`CupertinoSwitch.onChanged`) are disabled while a request is in progress.
5. **State Retention on Failure**:
   - The toggle retains its server-confirmed status until a successful response (200 OK) is received; failures leave the status untouched and re-enable interaction with existing error snackbar feedback.

---

## 2. File-by-File Detailed Audit

### A. `lib/features/profile/controllers/profile_controller.dart`
* **Status**: `[MODIFIED]`
* **Affected Line Numbers**:
  - `Lines 30–31`: Added private `_isActiveStatusLoading` flag and public getter `isActiveStatusLoading` to track ongoing active status synchronization requests.
  - `Lines 100–125`: Added in-flight guard `if (_isActiveStatusLoading) return false;`, set `_isActiveStatusLoading = true; update();`, and wrapped the API request and location recording logic in a `try ... finally` block to guarantee the lock is released in every outcome.

### B. `lib/features/home/widgets/online_status_toggle_widget.dart`
* **Status**: `[MODIFIED]`
* **Affected Line Numbers**:
  - `Line 20`: Added static `_isSyncing` flag to synchronously guard `_handleToggle` from concurrent rapid tap executions during asynchronous permission checks.
  - `Line 32`: Extracted `isLoading = profileController.isActiveStatusLoading` from the active GetX controller instance.
  - `Line 35`: Set `InkWell.onTap` to `null` when `isLoading` is true to completely disable tap gestures while synchronization is in flight.
  - `Lines 85–98`: Embedded a centered, compact 13x13 `CircularProgressIndicator` inside the 22x22 circular thumb container when `isLoading` is true, preserving the toggle layout and visible state.
  - `Lines 116–207`: Guarded `_handleToggle` with `_isSyncing` and `isActiveStatusLoading` checks and wrapped in `try ... finally { _isSyncing = false; }` to lock out secondary taps during permission evaluation.

### C. `lib/features/profile/screens/profile_screen.dart`
* **Status**: `[MODIFIED]`
* **Affected Line Numbers**:
  - `Line 213`: Set `CupertinoSwitch.onChanged` to `null` when `profileController.isActiveStatusLoading` is true to disable the Profile page toggle during background requests.

### D. `test/active_status_toggle_test.dart`
* **Status**: `[NEW]`
* **Affected Line Numbers**:
  - `Lines 1–137`: Added automated unit and widget test suite verifying that rapid repeated taps result in only one network request, prevent state inversion, and restore interactive state on both success and failure.

---

## 3. Automated Verification Results

- **Static Analysis**: `flutter analyze` completed with **0 issues found** across all modified files.
- **Unit & Widget Tests**: `flutter test test/active_status_toggle_test.dart` completed with **All tests passed (2/2)**:
  1. `Rapid repeated calls trigger only ONE request and prevent race condition` — PASSED.
  2. `Failure outcome restores interactive state without leaving lock engaged` — PASSED.

---

## 4. Git Commit & Push Audit

* **Target Branch**: `main`
* **Remote Repository**: `origin (git@github-second:kaushik-codex/myards-delivery-man-app-cx.git)`
* **Primary Feature Commit**: `247fece` (`fix: resolve active-status toggle race condition with tap lock and inline loader`)
* **Push Status**: `54b16dd..247fece main -> main` (Successfully pushed)

---

## 5. Security & Sensitive Key Sanitization Audit

All sensitive and private API keys across Android, iOS, Web, and Flutter were audited and sanitized with standard placeholders prior to pushing, and then fully reverted to their operational keys in the local environment:

| File Location | Parameter Sanitized in Remote | Placeholder Value Committed | Local State Restored |
| :--- | :--- | :--- | :--- |
| `android/app/src/main/AndroidManifest.xml` | `com.google.android.geo.API_KEY` | `"YOUR_GOOGLE_MAPS_API_KEY"` | Operational Key Restored |
| `ios/Runner/AppDelegate.swift` | `GMSServices.provideAPIKey(...)` | `"YOUR_GOOGLE_MAPS_API_KEY"` | Operational Key Restored |
| `lib/main.dart` | `FirebaseOptions.apiKey / appId / messagingSenderId / projectId` | `"YOUR_FIREBASE_API_KEY"`, etc. | Operational Key Restored |
| `lib/util/app_constants.dart` | `AppConstants.polylineMapKey` | `'YOUR_GOOGLE_MAPS_API_KEY'` | Operational Key Restored |
| `web/firebase-messaging-sw.js` | Firebase web configuration | `"YOUR_FIREBASE_API_KEY"`, etc. | Operational Key Restored |
| `web/index.html` | Firebase web initialization config | `"YOUR_FIREBASE_API_KEY"`, etc. | Operational Key Restored |
