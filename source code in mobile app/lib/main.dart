import 'package:flutter/material.dart';
import 'src/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:developer' as logger;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sms' as sms;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Greenhouse Monitor',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SmsService {
  static const String _functionUrl = 
    'https://us-central1-sensor-hub-91866.cloudfunctions.net/sendSmsAlert';

  static Future<void> sendAlert(String message, String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse(_functionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'phoneNumber': phoneNumber,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('SMS send failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('SMS error: $e');
    }
  }
}

class _HomePageState extends State<HomePage> {
  bool _tempAlertSent = false;
  bool _gasAlertSent = false;
  String userPhoneNumber = '+1234567890'; // Store in user profile

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Center(
        child: Column(
          children: [
            Text('Welcome!'),
            ElevatedButton(
              onPressed: () {
                // Simulate sensor data
                _simulateSensorData();
              },
              child: Text('Simulate Sensor Data'),
            ),
            ElevatedButton(
              onPressed: () {
                // Send alert
                _sendAlert();
              },
              child: Text('Send Alert'),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateSensorData() {
    // Simulate sensor data
    double temp = 25.5;
    double gas = 0.5;

    if (temp > 25.0 && !_tempAlertSent) {
      SmsService.sendAlert(
        'ALERT: Temp ${temp}°C exceeds threshold 25°C',
        userPhoneNumber,
      );
      _tempAlertSent = true;
    } else if (temp <= 25.0) {
      _tempAlertSent = false;
    }

    if (gas > 0.5 && !_gasAlertSent) {
      SmsService.sendAlert(
        'ALERT: Gas ${gas} exceeds threshold 0.5',
        userPhoneNumber,
      );
      _gasAlertSent = true;
    } else if (gas <= 0.5) {
      _gasAlertSent = false;
    }
  }

  void _sendAlert() {
    // Send alert
    _simulateSensorData();
  }
}
