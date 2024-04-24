import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';

class AlarmPage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  DateTime? _selectedTime;
  bool _alarmRinging = false;
  @override
  void initState() {
    super.initState();
    _selectedTime = DateTime.now();
  }

  Future<void> _setAlarm() async {
    final alarmSettings = AlarmSettings(
      id: 43,
      dateTime: _selectedTime!,
      assetAudioPath: 'assets/audio/successAudio.mp3',
      loopAudio: true,
      vibrate: true,
      volume: 0.8,
      fadeDuration: 3.0,
      notificationTitle: 'musshu',
      notificationBody: 'neeru vicky',
      enableNotificationOnKill: true,
    );
    await Alarm.set(alarmSettings: alarmSettings);
    setState(() {
      _alarmRinging = true;
    });
  }

  void _stopAlarm() async {
    // Your logic to stop the alarm goes here
    setState(() {
      _alarmRinging = false;
    });
    // For example, you can cancel the alarm
    await Alarm.stop(43);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Alarm'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selected Time: ${_selectedTime.toString()}',
            ),
            ElevatedButton(
              onPressed: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_selectedTime!),
                );
                if (pickedTime != null) {
                  setState(() {
                    _selectedTime = DateTime(
                      _selectedTime!.year,
                      _selectedTime!.month,
                      _selectedTime!.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
                }
              },
              child: Text('Pick Time'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _setAlarm,
              child: Text('Set Alarm'),
            ),
            SizedBox(height: 20),
            if (_alarmRinging)
              ElevatedButton(
                onPressed: _stopAlarm,
                child: Text('Stop Alarm'),
              ),
          ],
        ),
      ),
    );
  }
}
