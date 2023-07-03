// import 'package:acr_cloud_sdk/acr_cloud_sdk.dart';
import 'package:audio_recorder_project/models/deezer_song_model.dart';
import 'package:audio_recorder_project/models/simplifieldUri.dart';
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
  // late User? user;
  late Position myPosition;
  late int newRecordDuration;
  // final AcrCloudSdk acr = AcrCloudSdk();
  // final songService = SongService();
  DeezerSongModel? currentSong;
  bool isRecognizing = false;
  bool success = false;

  ServicesManager() {
    determinePosition();
    // user = User();
    // user = User(
    //   userId: "israel",
    // );

    // initAcr();

//
  }

  /// Determine the current position of the device.

  // late User? user = User(
  //     userId: "israel",
  //     position: Position(
  //       longitude: -7.778,
  //       latitude: 53.273,
  //       timestamp: DateTime.now(),
  //       accuracy: 0,
  //       altitude: 0,
  //       heading: 0,
  //       speed: 0,
  //       speedAccuracy: 0,
  //     ));

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
    ping();
    notifyListeners();
    // if (user != null) {
    //   user!.position = position;
    //   print('user.position  | position != null ${user!.position}');

    //   ping();
    //   notifyListeners();
    // }
    // if (position != null && user != null) {
    //   user!.position = position;
    //   print('user.position  | position != null ${user!.position}');

    //   ping();
    //   notifyListeners();
    //   // return await Geolocator.getCurrentPosition(
    //   //     desiredAccuracy: LocationAccuracy.high);
    // }
    // print('position= null ${position}');
  }

  var httpClient = http.IOClient(
    HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true,
  );
  Future<void> ping() async {
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
        notifyListeners();
        print('Valor dos segundos: $newRecordDuration');
      } else {
        throw Exception('Erro durante a requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro durante a requisição: $e');
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
      // http.Response response =
      //     await http.Response.fromStream(await request.send());

      http.Response response =
          await http.Response.fromStream(await httpClient.send(request));

      if (response.statusCode == 200) {
        print("RESPONSE");
        print(response.body);

        notifyListeners();
      } else {
        throw Exception('Erro durante a requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro durante a requisição: $e');
    }
  }

  // Future<void> uploadAudio() async {
  //   var httpClient = http.IOClient(
  //     HttpClient()
  //       ..badCertificateCallback =
  //           (X509Certificate cert, String host, int port) => true,
  //   );

  //   var url = Uri.parse('https://187.94.99.126:9948/api/check');
  //   var headers = {
  //     HttpHeaders.contentTypeHeader: 'application/json',
  //   };

  //   var audioBytes = await File(audioPah).readAsBytes();
  //   var base64Audio = base64Encode(audioBytes);

  //   var params = {
  //     "userId": "israel",
  //     "latitude": myPosition.latitude,
  //     "longitude": myPosition.longitude,
  //     "audio": base64Audio,
  //   };

  //   var body = jsonEncode(params);

  //   try {
  //     http.Response response =
  //         await httpClient.post(url, headers: headers, body: body);

  //     if (response.statusCode == 200) {
  //       print("RESPONSE uploadAudio");
  //       print(response.body);

  //       // Processar a resposta JSON, se necessário
  //       var jsonResponse = jsonDecode(response.body);
  //       print("jsonResponse ${jsonResponse}");
  //       // ...
  //     } else {
  //       throw Exception('Erro durante a requisição: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Erro durante a requisição: $e');
  //   }
  // }

  // Future<void> uploadAudio(String path) async {
  //   final url =
  //       'https://187.94.99.126:9948/api/check'; // Substitua pelo URL do serviço de upload
  //   final file = File(path);

  //   try {
  //     final request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.files.add(await http.MultipartFile.fromPath('audio', file.path));

  //     final response = await request.send();

  //     if (response.statusCode == 200) {
  //       print('Upload de áudio concluído com sucesso.');
  //     } else {
  //       print(
  //           'Falha no upload de áudio. Código de status: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Erro durante o upload de áudio: $e');
  //   }
  // }

// -----------------------------------------------------------
  // SongService() {
  //   BaseOptions options = BaseOptions(
  //       receiveTimeout: Duration(milliseconds: 100000),
  //       connectTimeout: Duration(milliseconds: 100000),
  //       baseUrl: 'https://api.deezer.com/track/');
  //   _dio = Dio(options);
  // }

  // Future<DeezerSongModel> getTrack(id) async {
  //   final response = await _dio!.get('$id',
  //       options: Options(headers: {
  //         'Content-type': 'application/json;charset=UTF-8',
  //         'Accept': 'application/json;charset=UTF-8',
  //       }));
  //   DeezerSongModel result = DeezerSongModel.fromJson(response.data);
  //   return result;
  // }

  // Future<void> initAcr() async {
  //   try {
  //     acr
  //       ..init(
  //         host: 'identify-eu-west-1.acrcloud.com', // https://www.acrcloud.com/
  //         accessKey: '7c4806d231525515bce0b7b70f38e63b',
  //         accessSecret: 'DNeXRGNWjy6Cp0xcjwHgJ5ygSFHwzo0QGihknsvs',
  //         setLog: true,
  //       )
  //       ..songModelStream.listen(searchSong);
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  // void searchSong(SongModel song) async {
  //   print(song);
  //   final metaData = song?.metadata;
  //   if (metaData != null && metaData.music!.length > 0) {
  //     final trackId = metaData!.music![0]?.externalMetadata?.deezer?.track?.id;
  //     try {
  //       final res = await getTrack(trackId);
  //       currentSong = res;
  //       success = true;
  //       notifyListeners();
  //     } catch (e) {
  //       isRecognizing = false;
  //       success = false;
  //       notifyListeners();
  //     }
  //   }
  // }

  // Future<void> startRecognizing() async {
  //   isRecognizing = true;
  //   success = false;
  //   notifyListeners();
  //   try {
  //     await acr.start();
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  // Future<void> stopRecognizing() async {
  //   isRecognizing = false;
  //   success = false;
  //   notifyListeners();
  //   try {
  //     await acr.stop();
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }
}
