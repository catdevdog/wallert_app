import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // .env에서 API URL 가져오기
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  // 기타 상수 (직접 정의)
  static const int days = 31;

  static const String staticImage = 'https://catdevdog.i234.me:12222';

  // Notification 설정
  static const String notificationChannelId = 'high_importance_channel';
  static const String notificationChannelName = 'High Importance Notifications';
  static const String notificationChannelDesc = 'This channel is used for important notifications.';

  static String get webViewUrl => dotenv.env['WEB_VIEW_URL'] ?? 'https://default-url.com';
}
