// ring_screen.dart

import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';

class RingScreen extends StatelessWidget {
  final AlarmSettings? alarmSettings; // Updated to be nullable
  const RingScreen({super.key, required this.alarmSettings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ALARM IS RINGING!',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Stop the alarm using the ID from the payload or from Alarm.checkIfRinging()
                final ringingAlarm = await Alarm.getAlarm(alarmSettings?.id ?? 1);
                if (ringingAlarm != null) {
                  await Alarm.stop(ringingAlarm.id);
                }
                Navigator.pop(context);
              },
              child: const Text('Stop Alarm'),
            ),
          ],
        ),
      ),
    );
  }
}