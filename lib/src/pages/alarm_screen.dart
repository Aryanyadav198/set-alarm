import 'dart:async';

import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:set_alarm/main.dart';
import 'package:set_alarm/src/pages/ring_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  late StreamSubscription<AlarmSettings> subscription;

  @override
  void initState() {
    super.initState();
    subscription = Alarm.ringStream.stream.listen(
      (AlarmSettings alarmSettings) => navigateToRingScreen(alarmSettings),
    );
  }

  // A function to handle navigation to the "ringing" screen
  void navigateToRingScreen(AlarmSettings alarmSettings) {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RingScreen(alarmSettings: alarmSettings),
        ),
      );
    }
  }

  @override
  void dispose() {
    subscription.cancel(); // Don't forget to cancel the subscription
    super.dispose();
  }

  Future<void> _setAlarm() async {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // If the selected time is in the past, set it for the next day.
    final scheduleDateTime = dateTime.isAfter(now)
        ? dateTime
        : dateTime.add(const Duration(days: 1));

    final alarmSettings = AlarmSettings(
      id: 1, // Unique ID for the alarm
      dateTime: scheduleDateTime,
      assetAudioPath:
          'assets/Aashiqui_2_Mashup__Remix_By_Kiran_Kamath_(128k).m4a', // Make sure to add an audio file in your assets
      loopAudio: true,
      vibrate: true,
      notificationSettings: NotificationSettings(
        title: 'Alarm',
        body: 'Tap to Stop',
      ),
      volumeSettings: VolumeSettings.fade(fadeDuration: Duration(seconds: 3)),
      iOSBackgroundAudio: true,
      androidStopAlarmOnTermination: false,
      warningNotificationOnKill: true,
    );

    await Alarm.set(alarmSettings: alarmSettings);

    // Initialize the timezone package

    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(
      scheduleDateTime,
      tz.local,
    );

    // Now, schedule a local notification using flutter_local_notifications
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'alarm_channel_id',
          'Alarm Notifications',
          channelDescription: 'Channel for alarm notifications',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          fullScreenIntent: true,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Alarm',
      'Your alarm is ringing!',
      scheduledTime,
      platformChannelSpecifics,
      payload: 'alarm_1',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alarm set for ${_selectedTime.format(context)}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Alarm App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) {
                  setState(() {
                    _selectedTime = time;
                  });
                }
              },
              child: const Text('Select Time'),
            ),
            const SizedBox(height: 20),
            Text(
              'Selected Time: ${_selectedTime.format(context)}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _setAlarm,
              child: const Text('Set Alarm'),
            ),
          ],
        ),
      ),
    );
  }
}
