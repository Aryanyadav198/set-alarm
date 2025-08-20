import 'dart:async';

import 'package:file_picker/file_picker.dart';
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
  String? _customAudioPath;

  @override
  void initState() {
    super.initState();
    subscription = Alarm.ringStream.stream.listen(
      (AlarmSettings alarmSettings) => navigateToRingScreen(alarmSettings),
    );
  }

  // A function to open the file picker
  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _customAudioPath = result.files.single.path;
      });
      // Optional: show a snackbar to confirm file selection
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio selected: ${result.files.single.name}')),
      );
    } else {
      // User canceled the picker
      _customAudioPath = null;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No audio file selected')));
    }
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
    if (_customAudioPath == null) {
      // Handle case where no custom audio is selected
      // You could use a default asset audio or show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an audio file first')),
      );
      return;
    }

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
    final int uniqueId = DateTime.now().millisecondsSinceEpoch % 100000;

    final alarmSettings = AlarmSettings(
      id: uniqueId, // Unique ID for the alarm
      dateTime: scheduleDateTime,
      assetAudioPath:
          _customAudioPath!, // Make sure to add an audio file in your assets
      loopAudio: true,
      vibrate: false,
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
    setState(() {
      _customAudioPath = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alarm set for ${_selectedTime.format(context)}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Alarm Clock ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Set Your Wake-Up Call',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Colors.orange,
                            onPrimary: Colors.white,
                            surface: Colors.black,
                            onSurface: Colors.white,
                          ),
                          buttonTheme: const ButtonThemeData(
                            colorScheme: ColorScheme.dark(
                              primary: Colors.orange,
                              onPrimary: Colors.white,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    setState(() {
                      _selectedTime = time;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    _selectedTime.format(context),
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w200,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              OutlinedButton.icon(
                onPressed: _pickAudioFile,
                icon: const Icon(Icons.music_note, color: Colors.white),
                label: const Text(
                  'Select Alarm Sound',
                  style: TextStyle(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  side: const BorderSide(color: Colors.orange, width: 2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _customAudioPath != null
                    ? 'Selected: ${Uri.parse(_customAudioPath!).pathSegments.last}'
                    : 'No custom audio selected',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _setAlarm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Set Alarm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
