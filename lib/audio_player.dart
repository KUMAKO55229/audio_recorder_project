import 'dart:async';

import 'package:audio_recorder_project/managers/services_manager/services_manager.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' as ap;
import 'package:provider/provider.dart';

class AudioPlayer extends StatefulWidget {
  const AudioPlayer({
    required this.source,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  /// Path from where to play recorded audio
  final ap.AudioSource source;

  /// Callback when audio file should be removed
  /// Setting this to null hides the delete button
  final VoidCallback onDelete;

  @override
  AudioPlayerState createState() => AudioPlayerState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ap.AudioSource>('source', source));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onDelete', onDelete));
  }
}

class AudioPlayerState extends State<AudioPlayer> {
  static const double _controlSize = 56;
  static const double _deleteBtnSize = 24;

  final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();
  late StreamSubscription<ap.PlayerState> _playerStateChangedSubscription;
  late StreamSubscription<Duration?> _durationChangedSubscription;
  late StreamSubscription<Duration> _positionChangedSubscription;

  @override
  void initState() {
    _playerStateChangedSubscription =
        _audioPlayer.playerStateStream.listen((ap.PlayerState state) async {
      if (state.processingState == ap.ProcessingState.completed) {
        await stop();
      }
      setState(() {});
    });
    _positionChangedSubscription = _audioPlayer.positionStream
        .listen((Duration position) => setState(() {}));
    _durationChangedSubscription = _audioPlayer.durationStream
        .listen((Duration? duration) => setState(() {}));
    _init();

    super.initState();
  }

  Future<void> _init() async {
    await _audioPlayer.setAudioSource(widget.source);
  }

  @override
  void dispose() {
    _playerStateChangedSubscription.cancel();
    _positionChangedSubscription.cancel();
    _durationChangedSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicesManager>(builder: (_, servicesManager, __) {
      return Scaffold(
        backgroundColor: Color(0xFF042442),
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              // margin: EdgeInsets.only(top: 200.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildControl(),
                  _buildSlider(context),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Color(0xFF73748D),
                      size: _deleteBtnSize,
                    ),
                    onPressed: () {
                      // ignore: always_specify_types
                      _audioPlayer.stop().then((value) => widget.onDelete());
                    },
                  ),
                  // IconButton(
                  //   icon: const Icon(
                  //     Icons.upload,
                  //     color: Color(0xFF73748D),
                  //     size: _deleteBtnSize,
                  //   ),
                  //   onPressed: () {
                  //     // ignore: always_specify_types
                  //     // _audioPlayer.stop().then((value) => widget.onDelete());
                  //     //  UPLOAD
                  //   },
                  // )
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            AvatarGlow(
              endRadius: 200.0,
              animate: false,
              child: GestureDetector(
                onTap: () {
                  servicesManager.uploadAudio('hdfbfbfn');
                },
                child: Material(
                  shape: CircleBorder(),
                  elevation: 8,
                  child: Container(
                      padding: EdgeInsets.all(40),
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Color(0xFF089af8)),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.upload,
                              size: 70,
                            ),
                            Text(
                              "Fazer upload ",
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildControl() {
    Icon icon;
    Color color;

    if (_audioPlayer.playerState.playing) {
      icon = const Icon(Icons.pause, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      final ThemeData theme = Theme.of(context);
      icon = Icon(Icons.play_arrow, color: theme.primaryColor, size: 30);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child:
              SizedBox(width: _controlSize, height: _controlSize, child: icon),
          onTap: () {
            if (_audioPlayer.playerState.playing) {
              pause();
            } else {
              play();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSlider(BuildContext context) {
    final constraints = MediaQuery.of(context).size;
    final Duration position = _audioPlayer.position;
    final Duration? duration = _audioPlayer.duration;
    bool canSetValue = false;
    if (duration != null) {
      canSetValue = position.inMilliseconds > 0;
      canSetValue &= position.inMilliseconds < duration.inMilliseconds;
    }

    double width = constraints.width - _controlSize - _deleteBtnSize;
    width -= _deleteBtnSize;

    return SizedBox(
      width: width,
      child: Slider(
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Theme.of(context).colorScheme.secondary,
        onChanged: (double v) {
          if (duration != null) {
            final double position = v * duration.inMilliseconds;
            _audioPlayer.seek(Duration(milliseconds: position.round()));
          }
        },
        value: canSetValue && duration != null
            ? position.inMilliseconds / duration.inMilliseconds
            : 0.0,
      ),
    );
  }

  Future<void> play() {
    return _audioPlayer.play();
  }

  Future<void> pause() {
    return _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    return _audioPlayer.seek(Duration.zero);
  }
}
