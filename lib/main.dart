import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_speech/google_speech.dart';
import 'package:mic_speech/controller/flow_controller.dart';
import 'package:mic_speech/dialog.dart';
import 'package:provider/provider.dart';
import 'package:sound_stream/sound_stream.dart';

void main() => runApp(MultiProvider(
      providers: [
        Provider<Future<FlowController>>(
          create: (_) => FlowController.build(),
        )
      ],
      child: MyApp(),
    ));

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
  Future<FlowController> controller;
  @override
  void initState() {
    super.initState();
  }

  void streamingRecognize() async {
    final _ctrl = await controller;
    _ctrl.startAudioStream();
  }

  @override
  Widget build(BuildContext context) {
    controller = Provider.of<Future<FlowController>>(context);
    return Center(
      child: Column(
        children: <Widget>[
          /// Começa o reconhecimento
          FlatButton(
              onPressed: () => streamingRecognize(),
              child: Text('Começar a reconhecer')),
          DialogTesting(),
        ],
      ),
    );
  }
}
