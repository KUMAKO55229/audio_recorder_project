import 'dart:io';
import 'package:audio_recorder_project/screens/home_page.dart';
import 'package:audio_recorder_project/managers/services_manager/services_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ServicesManager>(
          create: (_) => ServicesManager(),
          lazy: false,
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // home: HomePage()
        initialRoute: '/home',
        onGenerateRoute: ((settings) {
          switch (settings.name) {
            case '/home':
            default:
              return MaterialPageRoute(builder: (_) => HomePage());
          }
        }),
      ),
    );
  }
}
