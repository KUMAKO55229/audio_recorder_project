// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_sound_record/flutter_sound_record.dart';

// class AudioRecorderManager extends ChangeNotifier {
//   final FlutterSoundRecord _audioRecorder = FlutterSoundRecord();
//   bool isRecording = false;
//   int recordDuration = 0;
//   Future<void> _start() async {
//     try {
//       if (await _audioRecorder.hasPermission()) {
//         await _audioRecorder.start();
//         bool isRecording = await _audioRecorder.isRecording();
//         isRecording = isRecording;
//         recordDuration = 0;
//         _startTimer();
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//     }
//   }

//   Future<void> _stop() async {
//     _timer?.cancel();
//     _ampTimer?.cancel();
//     final String? path = await _audioRecorder.stop();

//     widget.onStop(path!);

//     setState(() => _isRecording = false);
//   }

//   Future<void> _pause() async {
//     _timer?.cancel();
//     _ampTimer?.cancel();
//     await _audioRecorder.pause();

//     setState(() => _isPaused = true);
//   }

//   Future<void> _resume() async {
//     _startTimer();
//     await _audioRecorder.resume();

//     setState(() => _isPaused = false);
//   }

//   void _startTimer() {
//     _timer?.cancel();
//     _ampTimer?.cancel();

//     _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
//       setState(() => _recordDuration++);
//     });

//     _ampTimer =
//         Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {
//       _amplitude = await _audioRecorder.getAmplitude();
//       setState(() {});
//     });
//   }
// }
