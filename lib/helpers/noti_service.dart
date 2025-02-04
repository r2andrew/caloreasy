// credit: mitch koko
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialised => _isInitialized;

  Future<void> initNotification() async {
    if (_isInitialized) return;

    //init timezone
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // TODO: add custom icon
    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    // linux configured for debug purposes
    const initSettingsLinux = LinuxInitializationSettings(defaultActionName: 'Log Food');

    await notificationsPlugin.initialize(InitializationSettings(android: initSettingsAndroid, linux: initSettingsLinux));

    // request notification permissions
    await notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
          'reminder_channel_id',
          'Reminders',
          channelDescription: 'Reminder Notification Channel',
          importance: Importance.max,
          priority: Priority.high
      ),
      linux: LinuxNotificationDetails()
    );
  }
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body
  }) async {
    return notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails()
    );
  }

  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required int hour,
    required int minute
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute
    );
    await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode:
            AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllNotification() async {
    await notificationsPlugin.cancelAll();
  }
}