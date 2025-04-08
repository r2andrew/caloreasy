import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../database/local_database.dart';

// credit: mitch koko
// https://www.youtube.com/watch?v=uKz8tWbMuUw&feature=youtu.be

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialised => _isInitialized;

  Future<void> initNotification() async {
    if (_isInitialized) return;

    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/caloreasy_launcher');

    // linux configured for debug purposes
    const initSettingsLinux = LinuxInitializationSettings(defaultActionName: 'Log Food');

    await notificationsPlugin.initialize(InitializationSettings(android: initSettingsAndroid, linux: initSettingsLinux));

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

  //credit: student
  static void scheduledNotification() async {

    print('got here');
    await NotiService().initNotification();

    // init hive for this isolate service
    await Hive.initFlutter();
    final _foodEntriesBox = await Hive.openBox('userFoodEntries');
    final _preferencesBox = await Hive.openBox('userPreferences');
    final _exerciseEntriesBox = await Hive.openBox('userExerciseEntries');
    final _notificationsBox = await Hive.openBox('notifications');
    final _weightBox = await Hive.openBox('userWeightEntries');

    LocalDatabase db = LocalDatabase();

    // if no entries for todays date (checked at 5pm), send notification
    if (!db.foodEntriesToday(DateTime.now().toString())) {
      NotiService().showNotification(title: 'Add Foods!', body: "Don't forget to track your calories today!");
    }
  }
}