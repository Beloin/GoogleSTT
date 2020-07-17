import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DialogTesting extends StatelessWidget {
  DialogTesting({Key key}) : super(key: key);
  final FlutterTts flutterTts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
              onPressed: () {
                auth("Onde você trabalha?");
              },
              child: Text('Chamar o robô')),
        ],
      ),
    );
  }

  void auth(String message) async {
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    print("Interpretação de texto:");
    AuthGoogle authGoogle = await AuthGoogle(
            fileJson: 'assets/testproj-1594745880645-c16c51aefd87.json')
        .build();
    Dialogflow dialogflow = Dialogflow(
        authGoogle: authGoogle, language: Language.portugueseBrazilian);
    //print(await dialogflow.authGoogle.getReadJson());
    
    AIResponse response = await dialogflow.detectIntent(message);
    print("Response:");
    print(response.getMessage());
    await flutterTts.speak(response.getMessage());
  }
}
