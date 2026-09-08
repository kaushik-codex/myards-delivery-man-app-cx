# Implementation Summary Report: Truecaller-Style Floating Order Overlay

This report provides a complete, line-by-line audit of all files created and modified to implement the system floating window overlay (Truecaller/Uber-style popup) in the 6amMart Delivery Man application.

---

## 1. Dependencies Added

### [pubspec.yaml](file:///t:/CodeX/Practice%20Projects%20by%20PPS%20Sir/codecanyon-36772148-6ammart-delivery-man-app/Delivery%20Man%20App/pubspec.yaml)
* **Added Package**: `flutter_overlay_window: ^0.4.5`
* **Location**: Line 54
* **Purpose**: Spawns a secondary Flutter engine inside Android's native `WindowManager` (`TYPE_APPLICATION_OVERLAY`) to draw interactive Flutter widgets over other applications.

```yaml
53:   file_picker: ^10.3.10
54:   flutter_overlay_window: ^0.4.5
55: 
```

---

## 2. Android Manifest Permissions & Services

### [android/app/src/main/AndroidManifest.xml](file:///t:/CodeX/Practice%20Projects%20by%20PPS%20Sir/codecanyon-36772148-6ammart-delivery-man-app/Delivery%20Man%20App/android/app/src/main/AndroidManifest.xml)

#### A. Permission Added (Line 13)
* **Code**: `<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />`
* **Purpose**: Allows the application to draw overlay windows on top of third-party apps ("Display over other apps" / "Appear on top").

```xml
11:     <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
12:     <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
13:     <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
14:     
```

#### B. Foreground Service Registration (Lines 102–106)
* **Purpose**: Because the project targets **Android 14+ (SDK 36)** in [build.gradle.kts](file:///t:/CodeX/Practice%20Projects%20by%20PPS%20Sir/codecanyon-36772148-6ammart-delivery-man-app/Delivery%20Man%20App/android/app/build.gradle.kts#L35), any background/overlay service calling `startForeground()` must explicitly specify a `foregroundServiceType`. This declaration prevents Android 14/15 security crashes.

```xml
102:         <service
103:             android:name="flutter.overlay.window.flutter_overlay_window.OverlayService"
104:             android:exported="false"
105:             android:foregroundServiceType="dataSync"
106:             tools:replace="android:foregroundServiceType" />
```

---

## 3. New File Created: Floating Overlay UI

### [lib/features/delivery_module/order/widgets/floating_order_overlay_widget.dart](file:///t:/CodeX/Practice%20Projects%20by%20PPS%20Sir/codecanyon-36772148-6ammart-delivery-man-app/Delivery%20Man%20App/lib/features/delivery_module/order/widgets/floating_order_overlay_widget.dart) (167 lines)

* **Purpose**: Dedicated standalone widget that runs in the secondary isolate when the floating window is triggered.
* **Key Components**:
* 
  1. **Event Communication Listener** (Lines 29–35):
       Subscribes to `FlutterOverlayWindow.overlayListener` to receive real-time order data (`order_id`, `store_name`, `order_amount`, `delivery_address`) passed from the main app or background push handler.
  2. **UI Card Layout** (Lines 45–164):
       Renders a transparent full-screen backdrop containing an elevated card with:
        * Header: Order ID, amount badge, and close button (`FlutterOverlayWindow.closeOverlay()`).
        * Body: Store name, store icon, delivery destination, and location pin.
        * Actions: **"Decline"** (dismisses overlay) and **"View Order"** (closes overlay and focuses the app).

---

## 4. Root Entrypoint & Engine Hook

### [lib/main.dart](file:///t:/CodeX/Practice%20Projects%20by%20PPS%20Sir/codecanyon-36772148-6ammart-delivery-man-app/Delivery%20Man%20App/lib/main.dart)

#### A. Import Added (Line 20)
```dart
import 'package:sixam_mart_delivery/features/delivery_module/order/widgets/floating_order_overlay_widget.dart';
```

#### B. Direct `overlayMain` Declaration (Lines 22–30)
* **Purpose**: Android's native plugin initializes `DartEntrypoint(findAppBundlePath(), "overlayMain")` without a specific library URI. Declaring `overlayMain` directly in root `main.dart` ensures Flutter's isolate runner resolves the entrypoint function without failing in AOT compilation.

```dart
22: /// Top-level overlay entry point directly declared in root main.dart
23: @pragma("vm:entry-point")
24: void overlayMain() {
25:   WidgetsFlutterBinding.ensureInitialized();
26:   runApp(const MaterialApp(
27:     debugShowCheckedModeBanner: false,
28:     home: FloatingOrderOverlayWidget(),
29:   ));
30: }
```

---

## 5. UI Permission & Client Testing Setup

### [lib/features/home/screens/home_screen.dart](file:///t:/CodeX/Practice%20Projects%20by%20PPS%20Sir/codecanyon-36772148-6ammart-delivery-man-app/Delivery%20Man%20App/lib/features/home/screens/home_screen.dart)

#### A. Imports Added (Lines 27–31)
```dart
import 'dart:convert';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:sixam_mart_delivery/common/widgets/confirmation_dialog_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
```

#### B. Permission Check Integration (Line 130)
* Automatically triggers overlay permission check when notification and battery optimization checks complete:
```dart
129:   Get.find<ProfileController>().setBackgroundNotificationActive(true);
130:   checkAndRequestOverlayPermission();
131: }
```

#### C. Permission Request Dialog (Lines 150–165)
```dart
Future<void> checkAndRequestOverlayPermission() async {
  bool isGranted = await FlutterOverlayWindow.isPermissionGranted();
  if (!isGranted) {
    Get.dialog(
      ConfirmationDialogWidget(
        icon: Images.warning,
        title: 'Floating Order Alerts',
        description: 'Allow 6amMart Delivery to display floating alerts over other apps so you never miss a new delivery request.',
        onYesPressed: () async {
          Get.back();
          await FlutterOverlayWindow.requestPermission();
        },
      ),
    );
  }
}
```

#### D. Test Trigger Handler `_testFloatingOverlay` (Lines 167–209)
* Resets any stale active window.
* Calls `FlutterOverlayWindow.showOverlay` with `enableDrag: false` on `WindowSize.matchParent` to prevent fullscreen window conflicts.
* Delays 600ms before `shareData` to ensure the isolate's `overlayListener` is registered.
* Wraps execution in `try-catch` to surface any native platform error.

#### E. Test Button in AppBar (Lines 252–256)
* Added a Picture-in-Picture icon button next to the notification bell:
```dart
252: IconButton(
253:   icon: Icon(Icons.picture_in_picture_alt, size: 24, color: Theme.of(context).primaryColor),
254:   tooltip: 'Test Floating Overlay',
255:   onPressed: () => _testFloatingOverlay(),
256: ),
```

---

## 6. Background Push Notification Integration

### [lib/helper/notification_helper.dart](file:///t:/CodeX/Practice%20Projects%20by%20PPS%20Sir/codecanyon-36772148-6ammart-delivery-man-app/Delivery%20Man%20App/lib/helper/notification_helper.dart)

#### A. Disambiguated Imports (Lines 7–8, 38)
* `package:flutter_foreground_task` and `package:flutter_local_notifications` both export `NotificationVisibility`. `hide NotificationVisibility` was added to resolve the compiler conflict:
```dart
7: import 'package:flutter_foreground_task/flutter_foreground_task.dart' hide NotificationVisibility;
8: import 'package:flutter_local_notifications/flutter_local_notifications.dart' hide NotificationVisibility;
...
38: import 'package:flutter_overlay_window/flutter_overlay_window.dart';
```

#### B. Top-Level `myBackgroundMessageHandler` (Lines 752–788)
* When a background FCM notification of type `order` or `order_request` arrives:
    1. Checks `FlutterOverlayWindow.isPermissionGranted()`.
    2. If granted and not already active, launches `FlutterOverlayWindow.showOverlay()`.
    3. Sends `message.data` to the overlay via `FlutterOverlayWindow.shareData()`.
    4. Continues starting `FlutterForegroundTask` for status-bar persistence.

```dart
760:     // 1. Check if the driver has granted "Display over other apps"
761:     try {
762:       bool isPermissionGranted = await FlutterOverlayWindow.isPermissionGranted();
763:       if (isPermissionGranted) {
764:         if (!await FlutterOverlayWindow.isActive()) {
765:           await FlutterOverlayWindow.showOverlay(
766:             enableDrag: false,
767:             overlayTitle: "New Order Request",
768:             overlayContent: 'Order #${message.data['order_id']}',
769:             flag: OverlayFlag.defaultFlag,
770:             alignment: OverlayAlignment.center,
771:             visibility: NotificationVisibility.visibilityPublic,
772:             positionGravity: PositionGravity.auto,
773:             height: WindowSize.matchParent,
774:             width: WindowSize.matchParent,
775:           );
776:         }
777:         await FlutterOverlayWindow.shareData(jsonEncode(message.data));
778:       }
779:     } catch (e) {
780:       customPrint("Overlay error: $e");
781:     }
```

---

## 7. Change Matrix Summary

| File | Type | Lines Changed / Added | Key Purpose |
| :--- | :---: | :---: | :--- |
| `pubspec.yaml` | Modified | Line 54 | Added `flutter_overlay_window: ^0.4.5` dependency |
| `AndroidManifest.xml` | Modified | Line 13, Lines 102–106 | Added `SYSTEM_ALERT_WINDOW` permission & `OverlayService` (Android 14+ FGS) |
| `floating_order_overlay_widget.dart` | **NEW** | Lines 1–167 | Standalone UI and entrypoint for the Truecaller-style floating popup |
| `main.dart` | Modified | Line 20, Lines 22–30 | Declared `@pragma("vm:entry-point") void overlayMain()` directly in root library |
| `home_screen.dart` | Modified | Lines 27–31, 130, 150–209, 252–256 | Added permission prompt, testing handler, and AppBar test action button |
| `notification_helper.dart` | Modified | Lines 7–8, 38, 752–788 | Resolved import conflicts & added automatic overlay launch on background FCM dispatches |