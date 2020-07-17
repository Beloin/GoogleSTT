import 'package:flutter/services.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_speech/google_speech.dart';
import 'package:sound_stream/sound_stream.dart';

class FlowController {
  final FlutterTts flutterTts = FlutterTts();
  Dialogflow dialogflow;
  SpeechToText speechToText;
  ServiceAccount serviceAccount;
  RecognitionConfig _config;
  RecorderStream _recorder = RecorderStream();

  FlowController._constructor();

  Future<void> _flutterTtsConfig() async {
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _googleAuth() async {
    AuthGoogle authGoogle = await AuthGoogle(
            fileJson: 'assets/testproj-1594745880645-c16c51aefd87.json')
        .build();
    dialogflow = Dialogflow(
        authGoogle: authGoogle, language: Language.portugueseBrazilian);
  }

  /// Builda o controller para poder ser usado
  static Future<FlowController> build() async {
    final controller = new FlowController._constructor();

    await controller._recognitionConfig();
    await controller._flutterTtsConfig();
    await controller._googleAuth();
    await controller._recorder.initialize();

    return controller;
  }

  Future<String> _getResponse(String message) async {
    AIResponse response = await dialogflow.detectIntent(message);
    print("Response:");
    print(response.getMessage());
    return response.getMessage();
  }

  Future<void> talkToRobot(String message) async {
    final String toSpeak = await _getResponse(message);
    await flutterTts.speak(toSpeak);
  }

  Future<void> _recognitionConfig() async {
    serviceAccount = ServiceAccount.fromString(
        '${(await rootBundle.loadString('assets/TESTProj.json'))}');
    speechToText = SpeechToText.viaServiceAccount(serviceAccount);
    _config = _getConfig();
  }

  RecognitionConfig _getConfig() => RecognitionConfig(
        encoding: AudioEncoding.LINEAR16,
        languageCode: 'pt-BR',
        sampleRateHertz: 16000,
        model: RecognitionModel.basic,
        enableAutomaticPunctuation: true,
      );

  /// Começa a receber a streaming do Mic
  startAudioStream() async {
    await _recorder.start();

    final stream = speechToText.streamingRecognize(
        StreamingRecognitionConfig(config: _config, interimResults: false),
        _recorder.audioStream);

    String finalResponse = '';
    bool listen = false;

    stream.listen((event) async {
      var res = event.results.map((e) => e.alternatives.first.transcript);
      print(res);
      finalResponse = event.results.first.alternatives.first.transcript;
      if (listen) {
        String finalRes = finalResponse.substring(0, finalResponse.length);
        print('Mandou: ' + finalRes);
        await talkToRobot(finalRes);
        listen = false;
      }
      if (res.toString().toLowerCase().trim() == "( olá sou)") {
        print('Me chamou?');
        String finalRes = finalResponse.substring(0, finalResponse.length);
        listen = true;
      }
    });
  }
}
