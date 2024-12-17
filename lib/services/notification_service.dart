// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    const InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification(RemoteMessage message) async {
    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
      const NotificationDetails(android: androidDetails),
    );
  }
  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    print('토픽 구독 성공: $topic');
    _saveSubscriptionStatus(topic, true);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    print('토픽 구독 해제: $topic');
    _saveSubscriptionStatus(topic, false);
  }

  Future<void> _saveSubscriptionStatus(String topic, bool isSubscribed) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(topic, isSubscribed);
  }

  Future<Set<String>> loadSubscribedTopics() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    return keys.where((key) => prefs.getBool(key) ?? false).toSet();
  }
}
