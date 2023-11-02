import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:Gitaratono/utils/colors.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pitch_detector_dart_update_test/pitch_detector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gitaratono',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: appBg),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Gitaratono'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _audioRecorder = FlutterAudioCapture();
  final pitchDetector = PitchDetector(44100, 2000);
  String currentNote = "";
  String pitchStatus = "Play any string to start.";
  String newPitchStatus = "";
  Color color = neonGreen;
  Color newColor = Colors.red;

  Future<void> _startCapture() async {
    await _audioRecorder.start(listener, onError,
        sampleRate: 44100, bufferSize: 2000);
  }

  void listener(dynamic obj) {
    var buffer = Float64List.fromList(obj.cast<double>());
    final List<double> audioSample = buffer.toList();

    final result = pitchDetector.getPitch(audioSample);

    if (result.pitched) {
      setState(() {
        currentNote = processPitch(result.pitch);
        pitchStatus = newPitchStatus;
        color = newColor;
      });
    }
  }
  
  void statusAndColorChanger(exactPitchInHz, pitchInHz){
    if(pitchInHz < exactPitchInHz-1){

      newColor = Colors.yellow;
    }else if (pitchInHz >= exactPitchInHz-1 && pitchInHz <= exactPitchInHz+1){

      newColor = neonGreen;
    }else{
      newColor = Colors.red;
    }
    double exact = (pitchInHz - exactPitchInHz);
    newPitchStatus = exact.round().toString();
}

  String processPitch(double pitchInHz){
    String note = "";

    if(pitchInHz >= 77.78 && pitchInHz <= 103.83){

      statusAndColorChanger(82.41, pitchInHz);

      note = "E";

    }else if(pitchInHz >= 103.83 && pitchInHz <= 138.59){

      statusAndColorChanger(110.00, pitchInHz);

      note = "A";

    }else if(pitchInHz >= 138.59 && pitchInHz <= 185.00){

      statusAndColorChanger(146.83, pitchInHz);

      note = "D";

    }else if(pitchInHz >= 185.00 && pitchInHz <= 233.08){

      statusAndColorChanger(196.00, pitchInHz);

      note = "G";

    }else if(pitchInHz >= 233.08 && pitchInHz <= 311.13){

      statusAndColorChanger(246.94, pitchInHz);

      note = "B";

    }else if(pitchInHz > 311.13){

      statusAndColorChanger(329.63, pitchInHz);

      note = "e";

    }
    return note;
  }

  void onError(Object e) {
    print(e);
  }

  Future checkPermission() async{
    if (await Permission.microphone.request().isGranted) {
      _startCapture();
    }

    if (await Permission.microphone.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  void initState() {
    // Keep the screen on.
    KeepScreenOn.turnOn();
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    checkPermission();
    return Scaffold(
      backgroundColor: appBg,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              color: appBarColor,
              width: MediaQuery.of(context).size.width,
              child: Text(widget.title,style: TextStyle(fontWeight: FontWeight.w500, color: neonGreen,fontSize: 25),),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(currentNote,style: TextStyle(color: color.withAlpha(255),fontWeight: FontWeight.w500,fontSize: 200),),
                  Text(pitchStatus,style: TextStyle(color: color.withAlpha(255),fontWeight: FontWeight.w500,fontSize: 30),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
