// lib/data/services/notification_service.dart
import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:masjid_sabilillah/presentation/controllers/notification_controller.dart';

/// Top-level function untuk handle background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
  debugPrint('Payload: ${message.data}');
  
  // Initialize Firebase jika belum
  await Firebase.initializeApp();
  
  // Show notification menggunakan flutter_local_notifications
  final notificationService = NotificationService();
  await notificationService.showNotificationFromRemoteMessage(message);
}

class NotificationService extends GetxService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  final RxString fcmToken = ''.obs;
  final Rx<RemoteMessage?> initialMessage = Rx<RemoteMessage?>(null);
  
  // Stream untuk notification clicks
  final _notificationClickController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get notificationClickStream => _notificationClickController.stream;

  /// Initialize notification service
  Future<void> initialize() async {
    debugPrint('NotificationService: Initializing...');
    
    try {
      // Request permission untuk notifications
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      debugPrint('NotificationService: Permission status: ${settings.authorizationStatus}');
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Initialize local notifications
        await _initializeLocalNotifications();
        
        // Initialize Firebase Cloud Messaging
        await _initializeFCM();
        
        // Get FCM token
        await _getFCMToken();
        
        // Check for initial message (app opened from terminated state)
        await _checkInitialMessage();
        
        debugPrint('NotificationService: Initialization complete');
      } else {
        debugPrint('NotificationService: Permission denied');
      }
    } catch (e) {
      debugPrint('NotificationService: Initialization error: $e');
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel untuk Android (Heads-up notifications)
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'masjid_sabilillah_channel',
        'Masjid Sabilillah Notifications',
        description: 'Notifikasi untuk pengumuman dan informasi Masjid Sabilillah',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFCM() async {
    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        fcmToken.value = token;
        debugPrint('NotificationService: FCM Token: $token');
      }
    } catch (e) {
      debugPrint('NotificationService: Error getting FCM token: $e');
    }
  }

  /// Check for initial message (app opened from terminated state)
  Future<void> _checkInitialMessage() async {
    final message = await _firebaseMessaging.getInitialMessage();
    if (message != null) {
      initialMessage.value = message;
      debugPrint('NotificationService: Initial message found: ${message.messageId}');
      debugPrint('NotificationService: Initial message data: ${message.data}');
      
      // Handle navigation after a delay to ensure app is fully initialized
      Future.delayed(const Duration(seconds: 1), () {
        _handleNotificationTap(message);
      });
    }
  }

  /// Handle foreground messages (app is open)
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('NotificationService: Foreground message received');
    debugPrint('NotificationService: Message ID: ${message.messageId}');
    debugPrint('NotificationService: Payload: ${message.data}');
    debugPrint('NotificationService: Title: ${message.notification?.title}');
    debugPrint('NotificationService: Body: ${message.notification?.body}');
    
    // Add to notification history via controller
    _addToNotificationHistory(message);
    
    // Show local notification dengan custom sound
    _showLocalNotification(message);
  }
  
  /// Add notification to history
  void _addToNotificationHistory(RemoteMessage message) {
    try {
      // Try to get controller if it's already initialized
      if (Get.isRegistered<NotificationController>()) {
        final controller = Get.find<NotificationController>();
        final notification = NotificationModel(
          id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: message.notification?.title ?? 'Masjid Sabilillah',
          body: message.notification?.body ?? '',
          timestamp: message.sentTime ?? DateTime.now(),
          data: message.data.isNotEmpty ? message.data : null,
        );
        controller.addNotification(notification);
      }
    } catch (e) {
      debugPrint('NotificationService: Error adding to history: $e');
    }
  }

  /// Show local notification dengan custom sound
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      'masjid_sabilillah_channel',
      'Masjid Sabilillah Notifications',
      channelDescription: 'Notifikasi untuk pengumuman dan informasi Masjid Sabilillah',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      // Custom sound - jika ada file di assets/sounds/notification_sound.mp3
      // sound: const RawResourceAndroidNotificationSound('notification_sound'),
      // Untuk sekarang menggunakan default sound, bisa diganti dengan custom sound
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // Custom sound untuk iOS
      // sound: 'notification_sound.caf',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title ?? 'Masjid Sabilillah',
      notification.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  /// Show notification from remote message (untuk background handler)
  Future<void> showNotificationFromRemoteMessage(RemoteMessage message) async {
    // Add to notification history
    _addToNotificationHistory(message);
    // Show local notification
    await _showLocalNotification(message);
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('NotificationService: Notification tapped');
    debugPrint('NotificationService: Message data: ${message.data}');
    
    // Add to notification history if not already added
    _addToNotificationHistory(message);
    
    // Emit event ke stream
    _notificationClickController.add(message.data);
  }

  /// Handle notification tap dari local notifications
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('NotificationService: Local notification tapped');
    debugPrint('NotificationService: Payload: ${response.payload}');
    
    // Parse payload jika ada
    if (response.payload != null) {
      // Payload biasanya berisi data dari remote message
      // Untuk sekarang, kita akan trigger navigation berdasarkan default
      _notificationClickController.add({'action': 'open_app'});
    }
  }

  /// Dispose resources
  @override
  void onClose() {
    _notificationClickController.close();
    super.onClose();
  }
}

