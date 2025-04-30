import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:loyalty_card_app/models/loyalty_card.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initialize notification services
  Future<void> initialize() async {
    // Initialize timezone
    tz_data.initializeTimeZones();

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _notifications.initialize(initSettings);
    // Comment out Firebase Messaging logic
    // await _firebaseMessaging.requestPermission(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   _showNotification(
    //     title: message.notification?.title ?? 'New Notification',
    //     body: message.notification?.body ?? '',
    //     payload: message.data['cardId'],
    //   );
    // });
  }

  // Background message handler
  // static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //   debugPrint('Handling a background message: [message.messageId]');
  // }

  // Show a local notification
  Future<void> _showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Schedule an expiration notification
  Future<void> scheduleExpirationNotification(LoyaltyCard card) async {
    if (card.expiryDate == null) return;
    // Schedule notification 7 days before expiry
    final scheduledDate = tz.TZDateTime.from(
      card.expiryDate!.subtract(const Duration(days: 7)),
      tz.local,
    );
    // Only schedule if the date is in the future
    if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      const androidDetails = AndroidNotificationDetails(
        'expiry_channel',
        'Card Expiry',
        channelDescription: 'Notifications for card expiration',
        importance: Importance.high,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      await _notifications.zonedSchedule(
        card.id.hashCode,
        'Card Expiring Soon',
        '${card.name} will expire in 7 days',
        scheduledDate,
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: card.id,
      );
    }
  }

  // Cancel a scheduled notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Remove FCM topic and token methods
}
