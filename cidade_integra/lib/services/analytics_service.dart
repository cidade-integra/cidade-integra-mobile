import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final instance = FirebaseAnalytics.instance;
  static final observer = FirebaseAnalyticsObserver(analytics: instance);

  static Future<void> logLogin(String method) async {
    await instance.logLogin(loginMethod: method);
  }

  static Future<void> logRegister() async {
    await instance.logSignUp(signUpMethod: 'email');
  }

  static Future<void> logCreateReport(String category) async {
    await instance.logEvent(
      name: 'create_report',
      parameters: {'category': category},
    );
  }

  static Future<void> logAddComment(String reportId) async {
    await instance.logEvent(
      name: 'add_comment',
      parameters: {'report_id': reportId},
    );
  }

  static Future<void> logSaveReport(String reportId) async {
    await instance.logEvent(
      name: 'save_report',
      parameters: {'report_id': reportId},
    );
  }
}
