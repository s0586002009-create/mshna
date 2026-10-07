import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
class NotificationService {
 final plugin=FlutterLocalNotificationsPlugin();
 Future<void> init() async {tz.initializeTimeZones();const android=AndroidInitializationSettings('@mipmap/ic_launcher');const ios=DarwinInitializationSettings();await plugin.initialize(const InitializationSettings(android:android,iOS:ios));}
 Future<void> requestPermissions() async {await plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();await plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestExactAlarmsPermission();await plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert:true,badge:true,sound:true);}
 Future<void> scheduleDaily({required int hour,required int minute,required String body}) async {await plugin.cancel(1001);final now=tz.TZDateTime.now(tz.local);var scheduled=tz.TZDateTime(tz.local,now.year,now.month,now.day,hour,minute);if(!scheduled.isAfter(now))scheduled=scheduled.add(const Duration(days:1));await plugin.zonedSchedule(1001,'זמן הלימוד',body,scheduled,const NotificationDetails(android:AndroidNotificationDetails('daily_study','תזכורת לימוד',channelDescription:'תזכורת יומית ללימוד משנה',importance:Importance.high,priority:Priority.high),iOS:DarwinNotificationDetails()),androidScheduleMode:AndroidScheduleMode.exactAllowWhileIdle,matchDateTimeComponents:DateTimeComponents.time);}
 Future<void> cancel()=>plugin.cancel(1001);
}