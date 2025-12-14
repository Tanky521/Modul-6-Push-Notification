// lib/presentation/controllers/notification_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_sabilillah/data/services/notification_service.dart';
import 'package:masjid_sabilillah/data/services/local_storage_service.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.data,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'data': data,
        'isRead': isRead,
      };

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        data: json['data'] as Map<String, dynamic>?,
        isRead: json['isRead'] as bool? ?? false,
      );
}

class NotificationController extends GetxController {
  final NotificationService _notificationService = NotificationService.instance;
  final LocalStorageService _storageService = LocalStorageService();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString fcmToken = ''.obs;

  StreamSubscription? _notificationClickSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
    _listenToNotificationClicks();
    _listenToFCMToken();
  }

  @override
  void onClose() {
    _notificationClickSubscription?.cancel();
    super.onClose();
  }

  /// Initialize notifications
  Future<void> _initializeNotifications() async {
    isLoading.value = true;
    try {
      // Load saved notifications from local storage
      await _loadNotifications();
      
      // Check for initial message (app opened from notification)
      final initialMessage = _notificationService.initialMessage.value;
      if (initialMessage != null) {
        await _handleNotificationMessage(initialMessage);
      }
    } catch (e) {
      print('Error initializing notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load notifications from local storage
  Future<void> _loadNotifications() async {
    try {
      final saved = await _storageService.getString('notifications');
      if (saved != null && saved.isNotEmpty) {
        final List<dynamic> jsonList = 
            (await _storageService.getObject('notifications')) as List<dynamic>? ?? [];
        notifications.value = jsonList
            .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();
        _updateUnreadCount();
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  /// Save notifications to local storage
  Future<void> _saveNotifications() async {
    try {
      final jsonList = notifications.map((n) => n.toJson()).toList();
      await _storageService.saveObject('notifications', jsonList);
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  /// Listen to FCM token changes
  void _listenToFCMToken() {
    fcmToken.value = _notificationService.fcmToken.value;
    ever(_notificationService.fcmToken, (token) {
      fcmToken.value = token;
      print('FCM Token updated: $token');
    });
  }

  /// Listen to notification clicks
  void _listenToNotificationClicks() {
    _notificationClickSubscription = _notificationService.notificationClickStream.listen(
      (data) {
        _handleNotificationNavigation(data);
      },
    );
  }

  /// Handle notification message (add to history)
  Future<void> _handleNotificationMessage(dynamic message) async {
    if (message == null) return;

    try {
      final notification = NotificationModel(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: message.notification?.title ?? 'Masjid Sabilillah',
        body: message.notification?.body ?? '',
        timestamp: message.sentTime ?? DateTime.now(),
        data: message.data is Map<String, dynamic> ? message.data : null,
      );

      // Check if notification already exists
      if (!notifications.any((n) => n.id == notification.id)) {
        // Add to beginning of list
        notifications.insert(0, notification);
        _updateUnreadCount();
        await _saveNotifications();
      }
    } catch (e) {
      print('Error handling notification message: $e');
    }
  }

  /// Handle notification navigation based on data
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    print('Handling notification navigation with data: $data');
    
    // Wait a bit to ensure app is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      // Extract route from data
      final route = data['route'] as String?;
      final type = data['type'] as String?;
      
      // Get context from GetX
      final context = Get.context;
      if (context == null) {
        print('Context is null, cannot navigate');
        return;
      }
      
      // Navigate based on type or route using go_router
      String targetRoute = '/pengumuman'; // Default
      
      if (route != null && route.isNotEmpty) {
        targetRoute = route;
      } else if (type != null) {
        switch (type.toLowerCase()) {
          case 'pengumuman':
          case 'announcement':
            targetRoute = '/pengumuman';
            break;
          case 'donasi':
          case 'donation':
            targetRoute = '/donasi';
            break;
          case 'jadwal':
          case 'prayer':
          case 'sholat':
            targetRoute = '/jadwal';
            break;
          default:
            targetRoute = '/pengumuman';
        }
      }
      
      // Navigate using go_router
      context.go(targetRoute);
      print('Navigated to: $targetRoute');
    });
  }

  /// Add notification to history
  Future<void> addNotification(NotificationModel notification) async {
    notifications.insert(0, notification);
    _updateUnreadCount();
    await _saveNotifications();
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = NotificationModel(
        id: notifications[index].id,
        title: notifications[index].title,
        body: notifications[index].body,
        timestamp: notifications[index].timestamp,
        data: notifications[index].data,
        isRead: true,
      );
      _updateUnreadCount();
      await _saveNotifications();
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = NotificationModel(
          id: notifications[i].id,
          title: notifications[i].title,
          body: notifications[i].body,
          timestamp: notifications[i].timestamp,
          data: notifications[i].data,
          isRead: true,
        );
      }
    }
    _updateUnreadCount();
    await _saveNotifications();
  }

  /// Delete notification
  Future<void> deleteNotification(String id) async {
    notifications.removeWhere((n) => n.id == id);
    _updateUnreadCount();
    await _saveNotifications();
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    notifications.clear();
    _updateUnreadCount();
    await _saveNotifications();
  }

  /// Update unread count
  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  /// Get FCM token untuk testing
  String getFCMToken() {
    return fcmToken.value;
  }
}

