# Implementation & Audit Report: Homepage Header Modern Active-Status Toggle

**Date**: 15 September 2026  
**Project**: 6amMart Delivery Man App (Flutter / Android / iOS)  
**Status**: Completed & Verified  

---

## 1. Executive Summary

This report documents the design, implementation, and verification of the modern pill-shaped active-status toggle on the delivery-man homepage top header area.

### Key Deliverables:
1. **Modern Pill-Shaped Toggle Component**:
   * Created [OnlineStatusToggleWidget](file:///t:/CodeX/Practice%20Projects%20by%20PPS%20Sir/codecanyon-36772148-6ammart-delivery-man-app/Delivery%20Man%20App/lib/features/home/widgets/online_status_toggle_widget.dart).
   * **When Active (Online)**: Exact project primary green background (`Theme.of(context).primaryColor`), white circular thumb aligned to the **right**, and "Online" (`'online'.tr`) label in white typography on the left.
   * **When Inactive (Offline)**: Project disabled grey background (`Theme.of(context).disabledColor`), white circular thumb aligned to the **left**, and "Offline" (`'offline'.tr`) label in white typography on the right.
   * Smooth, modern transitions implemented with `AnimatedContainer` and `AnimatedAlign`.
2. **Reused Business Logic & State Integrity**:
   * Reuses the exact business logic from the Profile page:
     - Delivery order check: Blocks switching offline if there are active running delivery orders (`orderController.currentOrderList?.isNotEmpty`), displaying the `you_cant_go_offline` bottom sheet.
     - Ride order check: Blocks switching offline if a ride trip is in progress (`haveRunningRide`), displaying `you_cant_go_offline_now_for_ride`.
     - Confirmation dialog: Displays the confirmation bottom sheet (`go_offline` / `are_you_sure_to_offline` with `Images.dmOfflineIcon`) when attempting to go offline.
     - Location permission check: Requests and verifies location permissions via `Geolocator.checkPermission()` and launches [LocationAccessDialog](file:///t:/CodeX/Practice%20Projects%20by%20PPS%20Sir/codecanyon-36772148-6ammart-delivery-man-app/Delivery%20Man%20App/lib/features/home/widgets/location_access_dialog.dart) when necessary before toggling online.
     - API handler: Triggers [ProfileController.updateActiveStatus](file:///t:/CodeX/Practice%20Projects%20by%20PPS%20Sir/codecanyon-36772148-6ammart-delivery-man-app/Delivery%20Man%20App/lib/features/profile/controllers/profile_controller.dart#L97-L113) to record or stop location tracking.
3. **Preserved Profile Page & Existing Layout**:
   * The Profile page ([profile_screen.dart](file:///t:/CodeX/Practice%20Projects%20by%20PPS%20Sir/codecanyon-36772148-6ammart-delivery-man-app/Delivery%20Man%20App/lib/features/profile/screens/profile_screen.dart)) was left 100% untouched as requested.
   * The homepage header ([home_screen.dart](file:///t:/CodeX/Practice%20Projects%20by%20PPS%20Sir/codecanyon-36772148-6ammart-delivery-man-app/Delivery%20Man%20App/lib/features/home/screens/home_screen.dart)) layout, leading logo, title styling, and trailing action buttons were preserved without disruption.

---

## 2. File-by-File Detailed Audit

### A. [lib/features/home/widgets/online_status_toggle_widget.dart](file:///t:/CodeX/Practice%20Projects%20by%20PPS%20Sir/codecanyon-36772148-6ammart-delivery-man-app/Delivery%20Man%20App/lib/features/home/widgets/online_status_toggle_widget.dart)
* **Status**: `[NEW]`
* **Lines Added**: `1–197`
* **One-line explanation**: Implemented the standalone modern pill-shaped toggle widget encapsulating the active-status visual states, animated transitions, permission verifications, and Profile business logic.

### B. [lib/features/home/screens/home_screen.dart](file:///t:/CodeX/Practice%20Projects%20by%20PPS%20Sir/codecanyon-36772148-6ammart-delivery-man-app/Delivery%20Man%20App/lib/features/home/screens/home_screen.dart)
* **Status**: `[MODIFIED]`
* **Affected Line Numbers**:
  - `Line 25`: Added `import 'package:sixam_mart_delivery/features/home/widgets/online_status_toggle_widget.dart';` to access the new toggle widget.
  - `Lines 277–278`: Placed `const Center(child: OnlineStatusToggleWidget())` and `const SizedBox(width: Dimensions.paddingSizeExtraSmall)` as the first children in `AppBar.actions` immediately preceding the test overlay and notification icons.
* **One-line explanation**: Integrated the `OnlineStatusToggleWidget` into the homepage `AppBar` actions row on the left of the notification icon while preserving existing header layout and spacing.

---

## 3. Synchronization & Navigation Verification

1. **Reactive State Sharing**:
   * `ProfileController` is registered as a permanent GetX service in the dependency tree.
   * Both `HomeScreen` and `ProfileScreen` bind to `ProfileController` via `GetBuilder<ProfileController>`.
2. **Single Source of Truth**:
   * Toggling active status from `OnlineStatusToggleWidget` on `HomeScreen` invokes `profileController.updateActiveStatus()`.
   * Upon successful API response, `profileController.updateActiveStatus()` flips `profileModel.active` (between 0 and 1) and calls `update()`.
   * This immediately triggers reactivity in all listening `GetBuilder<ProfileController>` instances across both `HomeScreen` and `ProfileScreen`.
3. **Cross-Page Navigation**:
   * Switching the status from the homepage updates the state in memory.
   * Navigating to the Profile page tab displays the identical active/inactive state on the Profile switch.
   * Conversely, toggling from the Profile switch immediately updates the homepage pill toggle when switching back to the Home tab.

---

## 4. Git Commit & Push Audit

* **Target Branch**: `main`
* **Remote Repository**: `origin (git@github-second:kaushik-codex/myards-delivery-man-app-cx.git)`
* **Commit Hash**: `a698c6d`
* **Commit Subject**: `feat: add modern pill-shaped active-status toggle to homepage header`
* **Push Status**: `b2d06f1..a698c6d main -> main` (Successfully pushed)

---

## 5. Security & Sensitive Key Sanitization Audit

All sensitive and private API keys across Android, iOS, Web, and Flutter were audited and sanitized with standard placeholders prior to pushing:

| File Location | Parameter Sanitized | Placeholder Value Set |
| :--- | :--- | :--- |
| `android/app/src/main/AndroidManifest.xml` | `com.google.android.geo.API_KEY` | `"YOUR_GOOGLE_MAPS_API_KEY"` |
| `ios/Runner/AppDelegate.swift` | `GMSServices.provideAPIKey(...)` | `"YOUR_GOOGLE_MAPS_API_KEY"` |
| `lib/main.dart` | `FirebaseOptions.apiKey / appId / messagingSenderId / projectId` | `"YOUR_FIREBASE_API_KEY"`, etc. |
| `lib/util/app_constants.dart` | `AppConstants.polylineMapKey` | `'YOUR_GOOGLE_MAPS_API_KEY'` |
| `web/firebase-messaging-sw.js` | Firebase web configuration | `"YOUR_FIREBASE_API_KEY"`, etc. |
| `web/index.html` | Firebase web initialization config | `"YOUR_FIREBASE_API_KEY"`, etc. |

