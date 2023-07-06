import 'package:ecade_mvp/models/position.dart';
import 'package:ecade_mvp/models/user.dart';
import 'package:ecade_mvp/managers/services_manager/services_manager.dart';
import 'package:flutter/material.dart';
import 'package:ecade_mvp/audio_recorder.dart';
import 'package:ecade_mvp/screens/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' as ap;
import 'package:ecade_mvp/audio_player.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showPlayer = false;
  ap.AudioSource? audioSource;

  late bool recordPermission;
  @override
  void initState() {
    super.initState();

    showPlayer = false;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: showPlayer
            ? AudioPlayer(
                source: audioSource!,
                onDelete: () {
                  setState(() => showPlayer = false);
                },
              )
            : AudioRecorder(
                onStop: (String path) {
                  setState(() {
                    audioSource = ap.AudioSource.uri(Uri.parse(path));
                    showPlayer = true;
                  });
                },
              ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('showPlayer', showPlayer));
    properties
        .add(DiagnosticsProperty<ap.AudioSource?>('audioSource', audioSource));
  }
}
