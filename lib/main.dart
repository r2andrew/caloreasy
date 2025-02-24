import 'package:caloreasy/helpers/noti_service.dart';
import 'package:caloreasy/pages/base_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'dart:io' show Platform;

void main() async {

  await Hive.initFlutter();

  final _foodEntriesBox = await Hive.openBox('userFoodEntries');
  final _preferencesBox = await Hive.openBox('userPreferences');
  final _exerciseEntriesBox = await Hive.openBox('userExerciseEntries');
  final _notificationsBox = await Hive.openBox('notifications');
  final _weightBox = await Hive.openBox('userWeightEntries');

  // debug
  // _foodEntriesBox.clear();
  // _preferencesBox.clear();
  // _exerciseEntriesBox.clear();

  WidgetsFlutterBinding.ensureInitialized();

  // request notification permissions if not gotten already
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  await notificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  // initialise Alarm (notif scheduler) service if on android
  // debugging on linux crashes otherwise
  if (Platform.isAndroid) await AndroidAlarmManager.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caloreasy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark
        ),
        useMaterial3: true,
      ),
      home: BasePage(),
    );
  }
}
