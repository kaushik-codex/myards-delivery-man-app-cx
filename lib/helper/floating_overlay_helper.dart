import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart' hide NotificationVisibility;
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/services/order_service_interface.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/screens/order_details_screen.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/screens/order_location_screen.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';

class FloatingOverlayHelper {
  static const String portName = 'floating_overlay_port';
  static ReceivePort? _receivePort;
  static StreamSubscription? _subscription;
  static bool _foregroundCallbackRegistered = false;

  /// Initializes listening for messages sent from the floating overlay window
  static void initListener() {
    print('====> [FloatingOverlayHelper] initListener called');

    // 1. IsolateNameServer: Guaranteed in-memory direct port between isolates in same OS process
    if (_receivePort == null) {
      try {
        IsolateNameServer.removePortNameMapping(portName);
        _receivePort = ReceivePort();
        final bool registered = IsolateNameServer.registerPortWithName(_receivePort!.sendPort, portName);
        print('====> [FloatingOverlayHelper] IsolateNameServer registered: $registered');

        _receivePort!.listen((event) {
          print('====> [FloatingOverlayHelper] Received event via IsolatePort: $event');
          _processOverlayEvent(event);
        });
      } catch (e) {
        print('====> [FloatingOverlayHelper] IsolateNameServer setup error: $e');
      }
    }

    // 2. FlutterForegroundTask communication port
    if (!_foregroundCallbackRegistered) {
      try {
        FlutterForegroundTask.initCommunicationPort();
        FlutterForegroundTask.addTaskDataCallback((data) {
          print('====> [FloatingOverlayHelper] Received event via ForegroundTask: $data');
          _processOverlayEvent(data);
        });
        _foregroundCallbackRegistered = true;
        print('====> [FloatingOverlayHelper] Registered ForegroundTask data callback');
      } catch (e) {
        print('====> [FloatingOverlayHelper] ForegroundTask port error: $e');
      }
    }

    // 3. FlutterOverlayWindow overlayListener
    if (_subscription == null) {
      try {
        _subscription = FlutterOverlayWindow.overlayListener.listen((event) {
          print('====> [FloatingOverlayHelper] Received raw overlay event: $event');
          _processOverlayEvent(event);
        }, onError: (e) {
          print('====> [FloatingOverlayHelper] overlayListener error: $e');
        });
        print('====> [FloatingOverlayHelper] overlayListener registered');
      } catch (e) {
        print('====> [FloatingOverlayHelper] overlayListener setup error: $e');
      }
    }
  }

  static String? _lastProcessedActionKey;
  static DateTime? _lastProcessedTime;

  /// Central processor for incoming overlay action events
  static void _processOverlayEvent(dynamic event) {
    if (event == null) return;
    try {
      final Map<String, dynamic> data = event is String
          ? jsonDecode(event)
          : Map<String, dynamic>.from(event as Map);

      final String? action = data['action']?.toString();
      if (action == null) {
        print('====> [FloatingOverlayHelper] Ignoring payload without action');
        return;
      }

      // Deduplicate rapid duplicate events across multiple communication channels
      final String? orderId = data['order_id']?.toString();
      final String actionKey = '${action}_${orderId ?? ''}';
      final DateTime now = DateTime.now();
      if (_lastProcessedActionKey == actionKey &&
          _lastProcessedTime != null &&
          now.difference(_lastProcessedTime!).inMilliseconds < 1500) {
        print('====> [FloatingOverlayHelper] Deduplicating action $actionKey (already processed within 1.5s)');
        return;
      }
      _lastProcessedActionKey = actionKey;
      _lastProcessedTime = now;

      print('====> [FloatingOverlayHelper] Processing action: $action, data: $data');

      switch (action) {
        case 'accept':
          _handleAcceptOrder(data);
          break;
        case 'decline':
          _handleDeclineOrder(data);
          break;
        case 'view_on_maps':
          _handleViewOnMaps(data);
          break;
        default:
          print('====> [FloatingOverlayHelper] Unrecognized action: $action');
      }
    } catch (e, stack) {
      print('====> [FloatingOverlayHelper] Error processing overlay event: $e\n$stack');
    }
  }

  /// Stops any running foreground service / alarm audio and ensures overlay is closed
  static Future<void> _stopAlertService() async {
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
    } catch (e) {
      print('====> [FloatingOverlayHelper] Error stopping foreground service: $e');
    }
    try {
      if (await FlutterOverlayWindow.isActive()) {
        await FlutterOverlayWindow.closeOverlay();
      }
    } catch (_) {}
  }

  /// Handles "Accept" button action from overlay
  static Future<void> _handleAcceptOrder(Map<String, dynamic> data) async {
    print('====> [FloatingOverlayHelper] Executing _handleAcceptOrder');
    await _stopAlertService();

    final dynamic rawOrderId = data['order_id'];
    if (rawOrderId == null) {
      print('====> [FloatingOverlayHelper] Error: order_id is null');
      return;
    }
    final int? orderId = int.tryParse(rawOrderId.toString());
    if (orderId == null) {
      print('====> [FloatingOverlayHelper] Error: could not parse order_id: $rawOrderId');
      return;
    }

    if (!Get.isRegistered<OrderController>()) {
      print('====> [FloatingOverlayHelper] Error: OrderController not registered in GetX');
      return;
    }
    final OrderController orderController = Get.find<OrderController>();

    // Check if the order is already in latestOrderList
    int index = orderController.latestOrderList?.indexWhere((o) => o.id == orderId) ?? -1;
    print('====> [FloatingOverlayHelper] Order #$orderId initial index in latestOrderList: $index');

    if (index != -1) {
      OrderModel orderModel = orderController.latestOrderList![index];
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      bool isSuccess = await orderController.acceptOrder(orderId, index, orderModel);
      print('====> [FloatingOverlayHelper] acceptOrder result: $isSuccess');
      if (isSuccess) {
        orderModel.orderStatus = (orderModel.orderStatus == 'pending' || orderModel.orderStatus == 'confirmed')
            ? 'accepted'
            : orderModel.orderStatus;
        Get.toNamed(
          RouteHelper.getOrderDetailsRoute(orderModel.id),
          arguments: OrderDetailsScreen(
            orderId: orderModel.id,
            isRunningOrder: true,
            orderIndex: (orderController.currentOrderList?.length ?? 1) - 1,
          ),
        );
      } else {
        await orderController.getLatestOrders();
      }
    } else {
      // Reload latest orders and attempt acceptance again
      print('====> [FloatingOverlayHelper] Order not in local list, refreshing latest orders...');
      await orderController.getLatestOrders();
      int newIndex = orderController.latestOrderList?.indexWhere((o) => o.id == orderId) ?? -1;
      print('====> [FloatingOverlayHelper] Order #$orderId refreshed index: $newIndex');

      if (newIndex != -1) {
        OrderModel orderModel = orderController.latestOrderList![newIndex];
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
        bool isSuccess = await orderController.acceptOrder(orderId, newIndex, orderModel);
        print('====> [FloatingOverlayHelper] acceptOrder after refresh result: $isSuccess');
        if (isSuccess) {
          orderModel.orderStatus = (orderModel.orderStatus == 'pending' || orderModel.orderStatus == 'confirmed')
              ? 'accepted'
              : orderModel.orderStatus;
          Get.toNamed(
            RouteHelper.getOrderDetailsRoute(orderModel.id),
            arguments: OrderDetailsScreen(
              orderId: orderModel.id,
              isRunningOrder: true,
              orderIndex: (orderController.currentOrderList?.length ?? 1) - 1,
            ),
          );
        }
      } else {
        // Fallback: Accept order directly via OrderServiceInterface
        print('====> [FloatingOverlayHelper] Fallback: accepting order directly via OrderServiceInterface');
        try {
          if (Get.isRegistered<OrderServiceInterface>()) {
            final response = await Get.find<OrderServiceInterface>().acceptOrder(orderId);
            print('====> [FloatingOverlayHelper] OrderServiceInterface acceptOrder isSuccess: ${response.isSuccess}');
            if (response.isSuccess) {
              orderController.getRunningOrders(1, status: 'all');
              orderController.getLatestOrders();
              Get.toNamed(
                RouteHelper.getOrderDetailsRoute(orderId),
                arguments: OrderDetailsScreen(
                  orderId: orderId,
                  isRunningOrder: true,
                  orderIndex: 0,
                ),
              );
            } else {
              showCustomSnackBar(response.message, isError: true);
            }
          }
        } catch (e) {
          print('====> [FloatingOverlayHelper] Direct accept order error: $e');
        }
      }
    }
  }

  /// Handles "Decline" button action from overlay using existing ignoreOrder(index)
  static Future<void> _handleDeclineOrder(Map<String, dynamic> data) async {
    print('====> [FloatingOverlayHelper] Executing _handleDeclineOrder');
    await _stopAlertService();

    final dynamic rawOrderId = data['order_id'];
    if (rawOrderId == null) {
      print('====> [FloatingOverlayHelper] Error: decline order_id is null');
      return;
    }
    final int? orderId = int.tryParse(rawOrderId.toString());
    if (orderId == null) {
      print('====> [FloatingOverlayHelper] Error: could not parse decline order_id: $rawOrderId');
      return;
    }

    if (!Get.isRegistered<OrderController>()) {
      print('====> [FloatingOverlayHelper] Error: OrderController not registered in GetX');
      return;
    }
    final OrderController orderController = Get.find<OrderController>();

    int index = orderController.latestOrderList?.indexWhere((o) => o.id == orderId) ?? -1;
    print('====> [FloatingOverlayHelper] Decline order #$orderId index: $index');
    if (index != -1) {
      orderController.ignoreOrder(index);
      print('====> [FloatingOverlayHelper] Invoked orderController.ignoreOrder($index)');
    } else {
      print('====> [FloatingOverlayHelper] Order not found in latestOrderList, refreshing...');
      await orderController.getLatestOrders();
      int newIndex = orderController.latestOrderList?.indexWhere((o) => o.id == orderId) ?? -1;
      print('====> [FloatingOverlayHelper] Decline order #$orderId refreshed index: $newIndex');
      if (newIndex != -1) {
        orderController.ignoreOrder(newIndex);
        print('====> [FloatingOverlayHelper] Invoked orderController.ignoreOrder($newIndex) after refresh');
      }
    }
    showCustomSnackBar('order_ignored'.tr, isError: false);
  }

  /// Handles "View on Maps" button action from overlay
  static Future<void> _handleViewOnMaps(Map<String, dynamic> data) async {
    print('====> [FloatingOverlayHelper] Executing _handleViewOnMaps with data: $data');
    await _stopAlertService();

    final dynamic rawOrderId = data['order_id'];
    final int? orderId = rawOrderId != null ? int.tryParse(rawOrderId.toString()) : null;

    if (!Get.isRegistered<OrderController>()) {
      print('====> [FloatingOverlayHelper] Error: OrderController not registered in GetX');
      return;
    }
    final OrderController orderController = Get.find<OrderController>();

    void openMapScreen(OrderModel model, int idx) {
      Future.delayed(const Duration(milliseconds: 150), () {
        Get.to(() => OrderLocationScreen(
          orderModel: model,
          orderController: orderController,
          index: idx,
          onTap: () {},
        ));
      });
    }

    if (orderId != null) {
      // 1. Check latestOrderList
      int index = orderController.latestOrderList?.indexWhere((o) => o.id == orderId) ?? -1;
      print('====> [FloatingOverlayHelper] ViewOnMaps order #$orderId index in latest: $index');
      if (index != -1) {
        openMapScreen(orderController.latestOrderList![index], index);
        return;
      }

      // 2. Check currentOrderList
      int currentIndex = orderController.currentOrderList?.indexWhere((o) => o.id == orderId) ?? -1;
      print('====> [FloatingOverlayHelper] ViewOnMaps order #$orderId index in current: $currentIndex');
      if (currentIndex != -1) {
        openMapScreen(orderController.currentOrderList![currentIndex], currentIndex);
        return;
      }

      // 3. Refresh latest orders
      print('====> [FloatingOverlayHelper] ViewOnMaps: Order not in local list, refreshing...');
      await orderController.getLatestOrders();
      int newIndex = orderController.latestOrderList?.indexWhere((o) => o.id == orderId) ?? -1;
      print('====> [FloatingOverlayHelper] ViewOnMaps order #$orderId refreshed index: $newIndex');
      if (newIndex != -1) {
        openMapScreen(orderController.latestOrderList![newIndex], newIndex);
        return;
      }
    }

    // 4. Open in-app OrderLocationScreen using order details from payload
    String? lat = data['latitude']?.toString() ?? data['lat']?.toString();
    String? lng = data['longitude']?.toString() ?? data['lng']?.toString();
    String deliveryAddress = data['delivery_address']?.toString() ?? 'Delivery Location';
    String? storeLat = data['store_lat']?.toString() ?? lat;
    String? storeLng = data['store_lng']?.toString() ?? lng;
    String storeName = data['store_name']?.toString() ?? 'Store';

    print('====> [FloatingOverlayHelper] Opening OrderLocationScreen with payload data: lat=$lat, lng=$lng');
    final String nowIso = DateTime.now().toIso8601String();
    OrderModel fallbackModel = OrderModel(
      id: orderId ?? 100234,
      orderAmount: double.tryParse((data['order_amount'] ?? '').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 32.50,
      orderStatus: 'pending',
      orderType: 'delivery',
      storeLat: storeLat,
      storeLng: storeLng,
      storeName: storeName,
      storeAddress: data['store_address']?.toString() ?? 'Store Address',
      createdAt: nowIso,
      originalDeliveryCharge: 5.0,
      dmTips: 0.0,
      paymentMethod: 'cash_on_delivery',
      deliveryAddress: DeliveryAddress(
        address: deliveryAddress,
        latitude: lat,
        longitude: lng,
        contactPersonName: 'Customer',
      ),
      receiverDetails: DeliveryAddress(
        address: deliveryAddress,
        latitude: lat,
        longitude: lng,
        contactPersonName: 'Customer',
      ),
    );

    openMapScreen(fallbackModel, 0);
  }
}
