import 'dart:async';
import 'package:ecade_mvp/audio_player.dart';
import 'package:ecade_mvp/managers/services_manager/services_manager.dart';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:just_audio/just_audio.dart' as ap;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:provider/provider.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({required this.onStop, Key? key}) : super(key: key);

  final void Function(String path) onStop;

  @override
  _AudioRecorderState createState() => _AudioRecorderState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        ObjectFlagProperty<void Function(String path)>.has('onStop', onStop));
  }
}

class _AudioRecorderState extends State<AudioRecorder>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _isPaused = false;
  int _recordDuration = 0;
  Timer? _timer;
  Timer? _ampTimer;
  final FlutterSoundRecord _audioRecorder = FlutterSoundRecord();
  Amplitude? _amplitude;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _isRecording = false;

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    // final servicesManager =
    //     Provider.of<ServicesManager>(context, listen: false);
    _timer?.cancel();
    _ampTimer?.cancel();
    _audioRecorder.dispose();
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicesManager>(builder: (_, servicesManager, __) {
      return Scaffold(
        backgroundColor: Color(0xFF042442),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _isRecording
                    ? Text(
                        'Aguarde o fim da gravação',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      )
                    : Text(
                        'Toque para gravar',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                SizedBox(
                  height: 40,
                ),
                AvatarGlow(
                  endRadius: 200.0,
                  animate: _isRecording,
                  child: GestureDetector(
                    onTap: () => _isRecording ? null : _start(),
                    child: Material(
                      shape: CircleBorder(),
                      elevation: 8,
                      child: Container(
                        padding: EdgeInsets.all(40),
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xFF089af8)),
                        child: Image.asset(
                          'assets/images/mic.png',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
      );
    });
  }

  Widget _buildRecordStopControl() {
    late Icon icon;
    late Color color;

    if (_isRecording || _isPaused) {
      icon = const Icon(Icons.stop, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      final ThemeData theme = Theme.of(context);
      icon = Icon(Icons.mic, color: theme.primaryColor, size: 30);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: () {
            _isRecording ? _stop() : _start();
          },
        ),
      ),
    );
  }

  Widget _buildPauseResumeControl() {
    if (!_isRecording && !_isPaused) {
      return const SizedBox.shrink();
    }

    late Icon icon;
    late Color color;

    if (!_isPaused) {
      icon = const Icon(Icons.pause, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      final ThemeData theme = Theme.of(context);
      icon = const Icon(Icons.play_arrow, color: Colors.red, size: 30);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: () {
            _isPaused ? _resume() : _pause();
          },
        ),
      ),
    );
  }

  //E
  Widget _buildText() {
    if (_isRecording || _isPaused) {
      return _buildTimer();
    }

    return const Text('Waiting to record');
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: const TextStyle(color: Colors.red),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }

  Future<void> _start() async {
    const snackBar = SnackBar(
      content: Text('Você não tem permissão para gravar audio deste local',
          style: TextStyle(color: Colors.white, fontSize: 18),
          overflow: TextOverflow.ellipsis,
          maxLines: 3),
      duration: Duration(seconds: 4),
      backgroundColor: Colors.red,
    );
    final servicesManager =
        Provider.of<ServicesManager>(context, listen: false);

    try {
      if (await _audioRecorder.hasPermission() &&
          await servicesManager.ping()) {
        await _audioRecorder.start();

        bool isRecording = await _audioRecorder.isRecording();
        setState(() {
          _isRecording = isRecording;
          _recordDuration = 0;
        });

        _startTimer();
        await Future.delayed(
            Duration(seconds: servicesManager.newRecordDuration));
        _stop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _stop() async {
    final servicesManager =
        Provider.of<ServicesManager>(context, listen: false);
    _timer?.cancel();
    _ampTimer?.cancel();
    final String? path = await _audioRecorder.stop();
    // audioPah = path;

    servicesManager.audioPah = path!;
    widget.onStop(path!);

    setState(() => _isRecording = false);
  }

  Future<void> _pause() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    await _audioRecorder.pause();

    setState(() => _isPaused = true);
  }

  Future<void> _resume() async {
    _startTimer();
    await _audioRecorder.resume();

    setState(() => _isPaused = false);
  }

  void _startTimer() {
    _timer?.cancel();
    _ampTimer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });

    _ampTimer =
        Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {
      _amplitude = await _audioRecorder.getAmplitude();
      setState(() {});
    });
  }
}
