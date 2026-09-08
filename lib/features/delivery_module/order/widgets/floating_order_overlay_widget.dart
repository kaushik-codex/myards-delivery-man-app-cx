import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart' hide NotificationVisibility;
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class FloatingOrderOverlayWidget extends StatefulWidget {
  const FloatingOrderOverlayWidget({super.key});

  @override
  State<FloatingOrderOverlayWidget> createState() => _FloatingOrderOverlayWidgetState();
}

class _FloatingOrderOverlayWidgetState extends State<FloatingOrderOverlayWidget> {
  Map<String, dynamic>? _orderData;
  StreamSubscription? _overlaySubscription;

  @override
  void initState() {
    super.initState();
    _overlaySubscription = FlutterOverlayWindow.overlayListener.listen((event) {
      if (event != null) {
        try {
          final Map<String, dynamic> data = event is String
              ? jsonDecode(event)
              : Map<String, dynamic>.from(event as Map);

          // Only accept incoming order data payloads (ignore outbound action events)
          if (data['action'] == null) {
            if (mounted) {
              setState(() {
                _orderData = data;
              });
            }
          }
        } catch (e) {
          debugPrint('====> Error decoding overlay data: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _overlaySubscription?.cancel();
    super.dispose();
  }

  /// Dispatches actions from the overlay window across all available inter-isolate channels
  void _dispatchAction(Map<String, dynamic> payload) {
    final String jsonStr = jsonEncode(payload);
    print('====> [FloatingOrderOverlayWidget] Dispatching action: $payload');

    // 1. IsolateNameServer: Direct in-memory SendPort registered as 'floating_overlay_port'
    try {
      final SendPort? port = IsolateNameServer.lookupPortByName('floating_overlay_port');
      if (port != null) {
        port.send(jsonStr);
        print('====> [FloatingOrderOverlayWidget] Sent via IsolateNameServer');
      } else {
        print('====> [FloatingOrderOverlayWidget] "floating_overlay_port" not found in IsolateNameServer');
      }
    } catch (e) {
      print('====> [FloatingOrderOverlayWidget] IsolateNameServer send error: $e');
    }

    // 2. FlutterForegroundTask communication channel
    try {
      FlutterForegroundTask.sendDataToMain(jsonStr);
      print('====> [FloatingOrderOverlayWidget] Sent via FlutterForegroundTask.sendDataToMain');
    } catch (e) {
      print('====> [FloatingOrderOverlayWidget] FlutterForegroundTask sendDataToMain error: $e');
    }

    // 3. FlutterOverlayWindow shareData (fire-and-forget, non-blocking)
    try {
      FlutterOverlayWindow.shareData(jsonStr);
      print('====> [FloatingOrderOverlayWidget] Sent via FlutterOverlayWindow.shareData');
    } catch (e) {
      print('====> [FloatingOrderOverlayWidget] FlutterOverlayWindow.shareData error: $e');
    }
  }

  Future<void> _onDecline(String orderId) async {
    print('====> [FloatingOrderOverlayWidget] _onDecline tapped for order: $orderId');
    _dispatchAction({
      'action': 'decline',
      'order_id': orderId,
    });

    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 200));
    await FlutterOverlayWindow.closeOverlay();
    print('====> [FloatingOrderOverlayWidget] Overlay closed after decline');
  }

  Future<void> _onAccept(String orderId) async {
    print('====> [FloatingOrderOverlayWidget] _onAccept tapped for order: $orderId');
    _dispatchAction({
      'action': 'accept',
      'order_id': orderId,
      'order_data': _orderData,
    });

    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
    } catch (_) {}

    try {
      FlutterForegroundTask.launchApp();
      print('====> [FloatingOrderOverlayWidget] launchApp requested (without route)');
    } catch (e) {
      print('====> [FloatingOrderOverlayWidget] Error launching app: $e');
    }

    await Future.delayed(const Duration(milliseconds: 200));
    await FlutterOverlayWindow.closeOverlay();
    print('====> [FloatingOrderOverlayWidget] Overlay closed after accept');
  }

  Future<void> _onViewOnMaps(String orderId, String deliveryAddress) async {
    print('====> [FloatingOrderOverlayWidget] _onViewOnMaps tapped for order: $orderId');
    final String? lat = _orderData?['latitude']?.toString() ??
        _orderData?['lat']?.toString() ??
        _orderData?['delivery_lat']?.toString();
    final String? lng = _orderData?['longitude']?.toString() ??
        _orderData?['lng']?.toString() ??
        _orderData?['delivery_lng']?.toString();
    final String? storeLat = _orderData?['store_lat']?.toString();
    final String? storeLng = _orderData?['store_lng']?.toString();
    final String? storeName = _orderData?['store_name']?.toString();

    _dispatchAction({
      'action': 'view_on_maps',
      'order_id': orderId,
      'delivery_address': deliveryAddress,
      'latitude': lat,
      'longitude': lng,
      'store_lat': storeLat,
      'store_lng': storeLng,
      'store_name': storeName,
      'order_data': _orderData,
    });

    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
    } catch (_) {}

    try {
      FlutterForegroundTask.launchApp();
      print('====> [FloatingOrderOverlayWidget] launchApp requested (without route)');
    } catch (e) {
      print('====> [FloatingOrderOverlayWidget] Error launching app: $e');
    }

    await Future.delayed(const Duration(milliseconds: 200));
    await FlutterOverlayWindow.closeOverlay();
    print('====> [FloatingOrderOverlayWidget] Overlay closed after view_on_maps');
  }

  @override
  Widget build(BuildContext context) {
    String orderId = _orderData?['order_id']?.toString() ?? 'New';
    String orderAmount = _orderData?['order_amount']?.toString() ?? '';
    String storeName = _orderData?['store_name']?.toString() ?? 'Incoming Delivery Request';
    String deliveryAddress = _orderData?['delivery_address']?.toString() ?? 'Tap to view details';

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15,
                spreadRadius: 2,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.delivery_dining, color: Theme.of(context).primaryColor, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #$orderId',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (orderAmount.isNotEmpty)
                          Text('Amount: $orderAmount', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => FlutterOverlayWindow.closeOverlay(),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Store / Address details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.storefront, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(storeName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      deliveryAddress,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Action Buttons: Decline & Accept Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Decline', style: TextStyle(fontWeight: FontWeight.w600)),
                      onPressed: () => _onDecline(orderId),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Accept', style: TextStyle(fontWeight: FontWeight.w600)),
                      onPressed: () => _onAccept(orderId),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // View on Maps Button beneath Decline & Accept
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.map_outlined, size: 20),
                  label: const Text(
                    'View on Maps',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  onPressed: () => _onViewOnMaps(orderId, deliveryAddress),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
