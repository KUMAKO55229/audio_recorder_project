import 'package:audio_recorder_project/models/position.dart';
import 'package:audio_recorder_project/models/user.dart';
import 'package:audio_recorder_project/managers/services_manager/services_manager.dart';
import 'package:flutter/material.dart';
import 'package:audio_recorder_project/audio_recorder.dart';
import 'package:audio_recorder_project/screens/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' as ap;
import 'package:audio_recorder_project/audio_player.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showPlayer = false;
  ap.AudioSource? audioSource;
  // final serviceManager = ServicesManager();
  // late final user = User();
  // late User user;
  // late final User user;
  late bool recordPermission;
  @override
  void initState() {
    super.initState();

    //  / serviceManager.determinePosition();
    // user = User(); //
    // checkRecordPermission().then((result) => {
    //       setState(() {
    //         recordPermission = result;
    //       })
    //     });

    showPlayer = false;
  }

  Future<bool> checkRecordPermission() async {
    // user.position = await serviceManager.determinePosition();
    // print('user.position ${user.position}');
    final userId = 'israel';
    final latitude = 53.273;
    final longitude = -7.778;

    // final response = await serviceManager.ping(userId, latitude, longitude);

    return true;
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
