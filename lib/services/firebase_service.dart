// lib/services/firebase_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../constants/app_constants.dart';
import 'notification_service.dart';
import '../firebase_options.dart';

class FirebaseService {
  FirebaseMessaging? _messaging;

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      print("Firebase 초기화 성공");
    } catch (e) {
      print("Firebase 초기화 실패: $e");
      rethrow;
    }

    try {
      await NotificationService.initialize(); // 알림 초기화
      print("알림 서비스 초기화 성공");
    } catch (e) {
      print("알림 서비스 초기화 실패: $e");
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print("백그라운드 메시지 핸들러 설정 완료");

    await _setupFirebaseMessaging();
  }

  // FCM 백그라운드 메시지 핸들러
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      print("백그라운드 메시지 처리: ${message.messageId}");
      // 추가적인 백그라운드 처리 로직
    } catch (e) {
      print("백그라운드 메시지 처리 중 오류 발생: $e");
    }
  }

  Future<void> _setupFirebaseMessaging() async {
    try {
      _messaging = FirebaseMessaging.instance;
      final settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print('알림 권한 상태: ${settings.authorizationStatus}');
    } catch (e) {
      print('알림 권한 요청 중 오류 발생: $e');
    }

    try {
      final token = await _messaging!.getToken();
      if (token != null) print('FCM 토큰: $token');
    } catch (e) {
      print('FCM 토큰 획득 실패: $e');
    }

    try {
      await _messaging!.subscribeToTopic("default");
      print("기본 토픽 구독 완료");
    } catch (e) {
      print("기본 토픽 구독 실패: $e");
    }

    FirebaseMessaging.onMessage.listen((message) {
      print('포그라운드 메시지 수신: ${message.notification?.title}');
      NotificationService.showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('알림을 통해 앱 열림: ${message.notification?.title}');
      // 알림 클릭 시 처리 로직 추가 가능
    });
  }
}
