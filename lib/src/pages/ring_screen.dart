// ring_screen.dart

import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:set_alarm/src/pages/alarm_screen.dart'; // Make sure this path is correct

class RingScreen extends StatelessWidget {
  final AlarmSettings? alarmSettings;
  const RingScreen({super.key, required this.alarmSettings});

  void _snoozeAlarm(BuildContext context) async {
    if (alarmSettings == null) {
      // Handle the case where alarmSettings is null
      return;
    }

    final now = DateTime.now();
    // Snooze for 9 minutes
    final snoozeDateTime = now.add(const Duration(minutes: 9)); 

    final snoozeSettings = alarmSettings!.copyWith(
      dateTime: snoozeDateTime,
      assetAudioPath: alarmSettings!.assetAudioPath,
      loopAudio: alarmSettings!.loopAudio,
      vibrate: alarmSettings!.vibrate,
      notificationTitle: "Snooze",
      notificationBody: "Alarm snoozed for 9 minutes",
    );

    // Stop the current alarm
    await Alarm.stop(alarmSettings!.id);
    
    // Set a new alarm for the snooze time
    await Alarm.set(alarmSettings: snoozeSettings);

    // Navigate back to the main screen
    Navigator.pop(context);

    // Show a confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alarm snoozed for 9 minutes'),
      ),
    );
  }

  void _stopAlarm(BuildContext context) async {
    if (alarmSettings != null) {
      await Alarm.stop(alarmSettings!.id);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.alarm_on,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'ALARM IS RINGING!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Time to wake up',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 60),
              Dismissible(
                key: Key(alarmSettings?.id.toString() ?? 'alarm_key'),
                onDismissed: (direction) {
                  _stopAlarm(context);
                },
                direction: DismissDirection.horizontal, // Only allow horizontal swipes
                background: Container(
                  color: Colors.transparent,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.transparent,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                child: ElevatedButton(
                  onPressed: () {}, // Make onPressed an empty function so the button doesn't do anything on press
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'SWIPE TO STOP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => _snoozeAlarm(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'SNOOZE',
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