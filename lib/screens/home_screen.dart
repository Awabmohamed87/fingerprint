import 'dart:async';

import 'package:fingerprint/screens/alarm_screen.dart';
import 'package:fingerprint/screens/sign_history_screen.dart';
import 'package:fingerprint/storage_manager.dart';
import 'package:fingerprint/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_alarm_background_trigger/flutter_alarm_background_trigger.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StorageManager sm = StorageManager();
  bool? _isSignedToday;
  Timer? _timer;
  String _timeRemaining = '';
  DateTime? _signTime;
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    setIsSigned();
    super.initState();
  }

  Future<void> setIsSigned() async {
    if (_isSignedToday == null) {
      _isSignedToday = await sm.init();
    }
    if (_isSignedToday!) {
      var tempDate = await sm.getSignTime();
      _signTime = DateTime.parse(tempDate);
      _endDate = _signTime!.add(Duration(hours: 8));
    }
  }

  Future<void> sign() async {
    await sm.sign();
    await setIsSigned();
  }

  @override
  Widget build(BuildContext context) {
    _timer = Timer(const Duration(seconds: 1), () {
      setState(() {
        _timeRemaining =
            _endDate.difference(DateTime.now()).toString().split('.')[0];
      });
    });

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(
            ThemeServices().theme == ThemeMode.dark
                ? Icons.wb_sunny_rounded
                : Icons.nightlight_round_rounded,
            color: ThemeServices().theme == ThemeMode.dark
                ? Colors.white
                : Colors.black,
          ),
          onPressed: () {
            ThemeServices().switchTheme();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.history_rounded,
              size: 30,
              color: ThemeServices().theme == ThemeMode.dark
                  ? Colors.white
                  : Colors.black,
            ),
            onPressed: () => Get.to(() => SignHistoryScreen()),
          ),
        ],
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
              'Fingerprint',
              style: TextStyle(
                  color: ThemeServices().theme == ThemeMode.dark
                      ? Colors.white
                      : Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat.yMMMd().format(DateTime.now()),
              style: TextStyle(
                  color: ThemeServices().theme == ThemeMode.dark
                      ? Colors.white
                      : Colors.black,
                  fontSize: 30),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.20),
            Container(
              margin: EdgeInsets.symmetric(vertical: 30),
              height: MediaQuery.of(context).size.width * 0.4,
              child: InkWell(
                onLongPress: () async {
                  if (!_isSignedToday!) {
                    setState(() {
                      _isSignedToday = true;
                    });
                    await sign();
                    setState(() {});
                    var alarmPlugin = FlutterAlarmBackgroundTrigger();
                    alarmPlugin.addAlarm(
                        // Required
                        _endDate,
                        //Optional
                        uid: "fingerprint_end_date_alarm",
                        payload: {"YOUR_EXTRA_DATA": "FOR_ALARM"},
                        screenWakeDuration: Duration(seconds: 90));
                    alarmPlugin.requestPermission().then((isGranted) {
                      if (isGranted) {
                        alarmPlugin.onForegroundAlarmEventHandler((alarm) {
                          Get.to(() => AlarmScreen())!.then((value) async {
                            _isSignedToday = await sm.init();
                            setState(() {});
                          });
                        });
                      }
                    });
                  }
                },
                child: Image.asset(
                  'assets/icons/fingerprint-scan.png',
                  color: ThemeServices().theme == ThemeMode.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
            _isSignedToday == null || !_isSignedToday!
                ? Text('Press and hold to sign in',
                    style: TextStyle(color: Colors.grey[400]))
                : Column(
                    children: [
                      if (_signTime != null)
                        Text(
                          'Signed at: ${DateFormat.jm().format(_signTime!)}',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      if (_signTime != null)
                        Text(
                          'Ends at: ${DateFormat.jm().format(_endDate)}',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      if (_signTime != null)
                        Text('Time Remaining: $_timeRemaining ',
                            style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isSignedToday != null && _isSignedToday!) {
            showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: Text(
                        'Sign Out?',
                        style: TextStyle(
                            color: ThemeServices().theme == ThemeMode.dark
                                ? Colors.white
                                : Colors.black,
                            fontSize: 25),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            sm.leave();
                            if (_timer != null) _timer!.cancel();
                            setState(() {
                              _isSignedToday = false;
                            });
                            Navigator.of(ctx).pop();
                          },
                          child: Text(
                            'Yes',
                            style: TextStyle(
                                color: ThemeServices().theme == ThemeMode.dark
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: Text(
                              'No',
                              style: TextStyle(
                                  color: ThemeServices().theme == ThemeMode.dark
                                      ? Colors.white
                                      : Colors.black),
                            )),
                      ],
                    ));
          } else {
            Fluttertoast.showToast(
                msg: "You have to be signed in first",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        },
        child: const Icon(Icons.exit_to_app),
      ),
    );
  }
}
