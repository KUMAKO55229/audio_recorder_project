// import 'package:acr_cloud_sdk/acr_cloud_sdk.dart';
import 'package:audio_recorder_project/models/deezer_song_model.dart';
import 'package:audio_recorder_project/models/music.dart';
import 'package:audio_recorder_project/models/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';

class ServicesManager extends ChangeNotifier {
  Dio? _dio;
  late String audioPah;

  late Position myPosition;
  late int newRecordDuration;

  DeezerSongModel? currentSong;
  bool isRecognizing = false;
  bool success = false;
  bool isNewUpload = false;
  Music? music;
  ServicesManager() {
    determinePosition();
  }

  Future<void> determinePosition({User? newUser}) async {
    bool serviceEnabled;
    LocationPermission permission;

    print("Inicicou determinePosition ");

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      print("'Location services are disabled.'");
      // return Future.error('Location services are disabled.');
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
        print('Location permissions are denied');
        // return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print(
          'Location permissions are permanently denied, we cannot request permissions.');
      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
    }
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    myPosition = position;
    print('MYPOSITION ${myPosition}');

    notifyListeners();
  }

  var httpClient = http.IOClient(
    HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true,
  );
  Future<bool> ping() async {
    var request =
        http.Request('GET', Uri.parse('https://187.94.99.126:9948/api/ping'))
          ..headers.addAll({
            HttpHeaders.contentTypeHeader: 'application/json',
          });
    var params = {
      "userId": "israel",
      // "latitude": 53.273,
      // "longitude": -7.778
      "latitude": myPosition.latitude,
      "longitude": myPosition.longitude,

      // "userId": user!.userId,
      // "latitude": user!.position!.latitude,
      // "longitude": user!.position!.longitude,
    };
    request.body = jsonEncode(params);

    try {
      http.StreamedResponse response = await httpClient.send(request);

      if (response.statusCode == 200) {
        print("RESPONSE");

        String responseString = await response.stream.bytesToString();

        print(responseString);

        Map<String, dynamic> json = jsonDecode(responseString);
        newRecordDuration = json['seconds'];
        bool canRecord = json['check'];
        notifyListeners();
        print('Valor dos segundos: $newRecordDuration');
        if (canRecord) {
          return true;
        } else {
          return false;
        }
        // return false;
      } else {
        return false;
        // throw Exception('Erro durante a requisição: ${response.statusCode}');
      }
    } catch (e) {
      return false;
      // throw Exception('Erro durante a requisição: $e');
    }
  }

  Future<void> uploadAudio() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://187.94.99.126:9948/api/check'),
    );

    request.headers['Content-Type'] =
        'multipart/form-data'; // Definir o cabeçalho Content-Type corretamente

    var params = {
      "userId": "israel",
      "latitude": myPosition.latitude.toString(),
      "longitude": myPosition.longitude.toString(),
    };

    // Converter os valores do mapa para String
    var stringParams =
        params.map((key, value) => MapEntry(key, value.toString()));

    request.fields.addAll(stringParams);

    // Adicionar o arquivo de áudio ao corpo da solicitação
    request.files.add(
      await http.MultipartFile.fromPath(
        'audio',
        audioPah,
        contentType: MediaType('audio', 'wav'),
      ),
    );

    try {
      http.Response response =
          await http.Response.fromStream(await httpClient.send(request));

      if (response.statusCode == 200) {
        print("RESPONSE");
        print(response.body);
        Map<String, dynamic> jsonData = json.decode(response.body);
        Music newMusic = Music.fromJson(jsonData);

        if (music == null || newMusic != null) {
          music = newMusic;
          isNewUpload = true;
        } else {
          isNewUpload = false;
        }

        notifyListeners();
      } else {
        throw Exception('Erro durante a requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro durante a requisição: $e');
    }
  }

  void deleteMusic({Music? music}) {
    music = null;
    isNewUpload = false;
    notifyListeners();
  }
}
