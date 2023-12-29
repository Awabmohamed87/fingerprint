import 'dart:async';

import 'package:fingerprint/storage_manager.dart';
import 'package:fingerprint/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  AudioPlayer player = new AudioPlayer();
  String alarmAudioPath = "sounds/tik_tok_alarm.wav";
  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    await player.play(AssetSource(alarmAudioPath), volume: 15);
    player.setReleaseMode(ReleaseMode.loop);
    Timer(Duration(seconds: 90), () async {
      await player.stop();
      Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            children: [
              Text(
                'Time to go Home',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: ThemeServices().theme == ThemeMode.dark
                        ? Colors.white
                        : Colors.black),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Icon(
                Icons.alarm_rounded,
                size: MediaQuery.of(context).size.height * 0.3,
                color: ThemeServices().theme == ThemeMode.dark
                    ? Color.fromRGBO(239, 239, 240, 0.3)
                    : Color.fromRGBO(0, 0, 0, 0.4),
              ),
              TextButton(
                  onPressed: () async {
                    await StorageManager().leave();
                    player.stop();
                    Get.back();
                    setState(() {});
                  },
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: ThemeServices().theme == ThemeMode.dark
                            ? Colors.white
                            : Colors.black),
                  )),
              TextButton(
                  onPressed: () {
                    player.stop();
                    Get.back();
                  },
                  child: Text('Cancel',
                      style: TextStyle(
                          fontSize: 18,
                          decoration: TextDecoration.underline,
                          color: ThemeServices().theme == ThemeMode.dark
                              ? Colors.white
                              : Colors.black)))
            ],
          ),
        ));
  }
}
