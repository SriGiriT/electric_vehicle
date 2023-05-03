import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:electric_vehicle/screens/bluetooth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:electric_vehicle/constant.dart';
Future main() async{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Electric Vehicle',
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF0A0E21),
        scaffoldBackgroundColor: Color(0xFF0A0E21),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BluetoothScreen(),
    );
  }
}

Future<SharedPreferences> _initialize() async {
  return SharedPreferences.getInstance();
}
