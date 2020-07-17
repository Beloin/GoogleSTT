import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_speech/google_speech.dart';
import 'package:mic_speech/dialog.dart';
import 'package:sound_stream/sound_stream.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mic Speech',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Testing Mic Speech'),
        ),
        body: MainWidgetClass(),
      ),
    );
  }
}

class MainWidgetClass extends StatefulWidget {
  MainWidgetClass({
    Key key,
  }) : super(key: key);

  @override
  _MainWidgetClassState createState() => _MainWidgetClassState();
}

class _MainWidgetClassState extends State<MainWidgetClass> {
  final RecorderStream recorder = RecorderStream();

  @override
  void initState() {
    super.initState();
    recorder.initialize();
  }

  StreamSubscription<dynamic> stream;

  void streamingRecognize() async {
    await recorder.start();

    final serviceAccount = ServiceAccount.fromString(
        '${(await rootBundle.loadString('assets/TESTProj.json'))}');
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);

    final config = _getConfig();

    final responseStream = speechToText.streamingRecognize(
        StreamingRecognitionConfig(config: config, interimResults: false),
        recorder.audioStream);

    String finalResponse;
    responseStream.listen((event) {
      var res = event.results.map((e) => e.alternatives.first.transcript);
      print(res);
      finalResponse = event.results.first.alternatives.first.transcript;
    }, onDone: () {
      print("Resposta final: " +
          finalResponse.substring(0, finalResponse.length));
      DialogTesting().auth(finalResponse.substring(0, finalResponse.length));
    });
  }

  Future<void> stopRecording() async {
    await recorder.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Container(
            child: Text('Hello World'),
          ),
          FlatButton(
              onPressed: () => streamingRecognize(),
              child: Text('Começar a reconhecer')),
          FlatButton(onPressed: () => stopRecording(), child: Text('Parar')),
          DialogTesting(),
        ],
      ),
    );
  }

  _getConfig() => RecognitionConfig(
        encoding: AudioEncoding.LINEAR16,
        languageCode: 'pt-BR',
        sampleRateHertz: 16000,
        model: RecognitionModel.basic,
        enableAutomaticPunctuation: true,
      );
}
