import 'package:acr_cloud_sdk/acr_cloud_sdk.dart';
import 'package:audio_recorder_project/models/deezer_song_model.dart';
import 'package:audio_recorder_project/models/simplifieldUri.dart';
import 'package:audio_recorder_project/models/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ServicesManager extends ChangeNotifier {
  Dio? _dio;
  final AcrCloudSdk acr = AcrCloudSdk();
  // final songService = SongService();
  DeezerSongModel? currentSong;
  bool isRecognizing = false;
  bool success = false;

  ServicesManager() {
    determinePosition();
    initAcr();
//
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  //User? user;
  User user = User(id: 'israel');
  Future<void> determinePosition({User? newUser}) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    final position = await Geolocator.getCurrentPosition();
    if (position != null && user != null) {
      user!.position = position;
      print('user.position ${user!.position}');
    }
    // user!.position = await Geolocator.getCurrentPosition();
    // print('user.position ${user!.position}');
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    // return await Geolocator.getCurrentPosition();
  }
  // Future<Position> getCurrentLocation() async {
  //   try {
  //     final position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );
  //     return position;
  //   } catch (e) {
  //     throw Exception('Erro ao obter a localização: $e');
  //   }
  // }

  Future<Map<String, dynamic>> ping(
      String userId, double latitude, double longitude) async {
    final params = {
      'name': 'John',
      'columns': ['firstName', 'lastName'],
      'ageRange': {
        'from': 12,
        'to': 60,
      },
      'someInnerArray': [1, 2, 3, 5]
    };
    final Uri uri = SimplifiedUri.uri('http://api.mysite.com/users', params);
    String url = "https://187.94.99.126:9948/api/ping";

    Map<String, dynamic> payload = {
      "userId": "israel",
      "latitude": 53.273,
      "longitude": -7.778
    };

    Map<String, String> headers = {'Content-Type': 'application/json'};

    try {
      // final response = await http.get(Uri.parse(url), headers: headers);
      http.Response response = await http.get(
        Uri.parse(url),
        headers: headers,
        // body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        throw Exception('Erro durante a requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro durante a requisição: $e');
    }
  }

  Future<void> uploadAudio(String path) async {
    final url =
        'https://example.com/upload'; // Substitua pelo URL do serviço de upload
    final file = File(path);

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('audio', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        print('Upload de áudio concluído com sucesso.');
      } else {
        print(
            'Falha no upload de áudio. Código de status: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro durante o upload de áudio: $e');
    }
  }

// -----------------------------------------------------------
  SongService() {
    BaseOptions options = BaseOptions(
        receiveTimeout: Duration(milliseconds: 100000),
        connectTimeout: Duration(milliseconds: 100000),
        baseUrl: 'https://api.deezer.com/track/');
    _dio = Dio(options);
  }

  Future<DeezerSongModel> getTrack(id) async {
    final response = await _dio!.get('$id',
        options: Options(headers: {
          'Content-type': 'application/json;charset=UTF-8',
          'Accept': 'application/json;charset=UTF-8',
        }));
    DeezerSongModel result = DeezerSongModel.fromJson(response.data);
    return result;
  }

  Future<void> initAcr() async {
    try {
      acr
        ..init(
          host: 'identify-eu-west-1.acrcloud.com', // https://www.acrcloud.com/
          accessKey: '7c4806d231525515bce0b7b70f38e63b',
          accessSecret: 'DNeXRGNWjy6Cp0xcjwHgJ5ygSFHwzo0QGihknsvs',
          setLog: true,
        )
        ..songModelStream.listen(searchSong);
    } catch (e) {
      print(e.toString());
    }
  }

  void searchSong(SongModel song) async {
    print(song);
    final metaData = song?.metadata;
    if (metaData != null && metaData.music!.length > 0) {
      final trackId = metaData!.music![0]?.externalMetadata?.deezer?.track?.id;
      try {
        final res = await getTrack(trackId);
        currentSong = res;
        success = true;
        notifyListeners();
      } catch (e) {
        isRecognizing = false;
        success = false;
        notifyListeners();
      }
    }
  }

  Future<void> startRecognizing() async {
    isRecognizing = true;
    success = false;
    notifyListeners();
    try {
      await acr.start();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> stopRecognizing() async {
    isRecognizing = false;
    success = false;
    notifyListeners();
    try {
      await acr.stop();
    } catch (e) {
      print(e.toString());
    }
  }
}
