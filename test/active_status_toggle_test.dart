import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sixam_mart_delivery/common/models/response_model.dart';
import 'package:sixam_mart_delivery/features/address/domain/models/record_location_body_model.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/profile/domain/models/profile_model.dart';
import 'package:sixam_mart_delivery/features/profile/domain/services/profile_service_interface.dart';

class MockProfileService implements ProfileServiceInterface {
  int updateCallCount = 0;
  Completer<ResponseModel>? completer;
  bool shouldSucceed = true;

  @override
  Future<ResponseModel> updateActiveStatus() async {
    updateCallCount++;
    if (completer != null) {
      return completer!.future;
    }
    return ResponseModel(shouldSucceed, shouldSucceed ? 'Status updated' : 'Update failed');
  }

  @override
  Future<ProfileModel?> getProfileInfo() async => null;

  @override
  Future<ResponseModel> updateProfile(ProfileModel userInfoModel, XFile? data, String token) async =>
      ResponseModel(true, 'success');

  @override
  Future<void> recordWebSocketLocation(RecordLocationBodyModel recordLocationBody, String zoneId) async {}

  @override
  Future<Response> recordLocation(RecordLocationBodyModel recordLocationBody, String zoneId) async =>
      const Response(statusCode: 200);

  @override
  Future<ResponseModel> deleteDriver() async => ResponseModel(true, 'deleted');

  @override
  void checkPermission(Function callback) {}

  @override
  Future<String> addressPlaceMark(Position locationResult) async => 'address';

  @override
  Future<String> getZoneId(Position locationResult) async => '1';

  @override
  Future<dynamic> getProfileLevelInfo() async => null;
}

void main() {
  tearDown(() {
    Get.reset();
  });

  testWidgets('Rapid repeated calls trigger only ONE request and prevent race condition', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
    final mockService = MockProfileService();
    mockService.completer = Completer<ResponseModel>();
    final controller = ProfileController(profileServiceInterface: mockService);

    // Initialize _profileModel via updateUserInfo
    await controller.updateUserInfo(ProfileModel(id: 1, active: 0, fName: 'Test', lName: 'Driver'), 'token');
    await tester.pump(const Duration(seconds: 4));
    expect(controller.profileModel?.active, 0);

    // Call updateActiveStatus 5 times concurrently
    final future1 = controller.updateActiveStatus();
    expect(controller.isActiveStatusLoading, true);

    final future2 = controller.updateActiveStatus();
    final future3 = controller.updateActiveStatus();
    final future4 = controller.updateActiveStatus();
    final future5 = controller.updateActiveStatus();

    // Secondary calls must return false immediately and not dispatch additional service calls
    expect(await future2, false);
    expect(await future3, false);
    expect(await future4, false);
    expect(await future5, false);

    // Only 1 call was dispatched to profileServiceInterface
    expect(mockService.updateCallCount, 1);
    expect(controller.isActiveStatusLoading, true);

    // Now complete the pending first request
    mockService.completer!.complete(ResponseModel(true, 'Success'));
    final result1 = await future1;
    await tester.pump(const Duration(seconds: 4));

    expect(result1, true);
    // Profile active state must have flipped exactly once from 0 to 1
    expect(controller.profileModel?.active, 1);
    // Lock must be released
    expect(controller.isActiveStatusLoading, false);
  });

  testWidgets('Failure outcome restores interactive state without leaving lock engaged', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
    final mockService = MockProfileService();
    mockService.completer = Completer<ResponseModel>();
    final controller = ProfileController(profileServiceInterface: mockService);

    await controller.updateUserInfo(ProfileModel(id: 1, active: 0, fName: 'Test', lName: 'Driver'), 'token');
    await tester.pump(const Duration(seconds: 4));
    expect(controller.profileModel?.active, 0);

    final future = controller.updateActiveStatus();
    expect(controller.isActiveStatusLoading, true);

    // Complete with failure
    mockService.completer!.complete(ResponseModel(false, 'Network Error'));
    final result = await future;
    await tester.pump(const Duration(seconds: 4));

    expect(result, false);
    // Profile active state remains unchanged (0)
    expect(controller.profileModel?.active, 0);
    // Lock must be released even on failure
    expect(controller.isActiveStatusLoading, false);

    // Subsequent tap must be allowed now that lock is released
    mockService.completer = Completer<ResponseModel>();
    final secondAttempt = controller.updateActiveStatus();
    expect(controller.isActiveStatusLoading, true);
    expect(mockService.updateCallCount, 2);

    mockService.completer!.complete(ResponseModel(true, 'Success'));
    expect(await secondAttempt, true);
    await tester.pump(const Duration(seconds: 4));

    expect(controller.profileModel?.active, 1);
    expect(controller.isActiveStatusLoading, false);
  });
}
