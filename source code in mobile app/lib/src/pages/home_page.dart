import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../pages/charts_page.dart'; // ChartsPage import
import 'greenhouse_news_page.dart';
import 'add_news_page.dart';
import 'login_page.dart'; // adjust the path based on your folder structure

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = FirebaseDatabase.instance.ref();

  double temp = 0;
  double hum = 0;
  int soil = 0;
  int gas = 0;
  double light = 0;
  int water = 0;

  bool autoMode = true;
  bool fanOn = false;
  bool bulbOn = false;

  int tempThreshold = 30;
  int lightThreshold = 50;
  int gasThreshold = 300;

  // For charts: keep last 20 readings
  final List<double> tempHistory = [];
  final List<double> humHistory = [];
  final List<double> lightHistory = [];
  final List<double> gasHistory = [];

  @override
  void initState() {
    super.initState();

    db.child('sensors').onValue.listen((event) {
      final val = event.snapshot.value;
      if (val != null && val is Map) {
        setState(() {
          temp = _toDouble(val['temp']);
          hum = _toDouble(val['hum']);
          soil = _toInt(val['soil']);
          gas = _toInt(val['gas']);
          light = _toDouble(val['light']);
          water = _toInt(val['waterLevel']);

          // Update history lists
          _addToHistory(tempHistory, temp);
          _addToHistory(humHistory, hum);
          _addToHistory(lightHistory, light);
          _addToHistory(gasHistory, gas.toDouble());
        });
      }
    });

    db.child('control').onValue.listen((event) {
      final val = event.snapshot.value;
      if (val != null && val is Map) {
        setState(() {
          autoMode = val['autoMode'] ?? true;
          fanOn = val['fanOn'] ?? false;
          bulbOn = val['bulbOn'] ?? false;

          tempThreshold = _toInt(
            val['tempThreshold'],
            fallback: tempThreshold,
          ).clamp(15, 50);
          lightThreshold = _toInt(
            val['lightThreshold'],
            fallback: lightThreshold,
          ).clamp(0, 1000);
          gasThreshold = _toInt(
            val['gasThreshold'],
            fallback: gasThreshold,
          ).clamp(0, 4095);
        });
      }
    });
  }

  void _addToHistory(List<double> list, double value) {
    list.add(value);
    if (list.length > 20) list.removeAt(0);
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  Future<void> setControlBool(String key, bool value) async {
    await db.child('control/$key').set(value);
  }

  Future<void> setControlInt(String key, int value) async {
    await db.child('control/$key').set(value);
  }

  Widget sensorTile(String name, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withAlpha((0.9 * 255).round()),
            color.withAlpha((0.6 * 255).round()),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 34, color: Colors.white),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget controlButton(
    String label,
    bool state,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: autoMode ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: state ? color : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: state ? Colors.white : Colors.black54,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Greenhouse Monitor'),
        actions: [
          // Inside AppBar actions
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();

                // Ensure widget is still mounted
                if (!mounted) return;

                // Navigate safely after sign-out
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
              } catch (e) {
                debugPrint('Logout error: $e');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            sensorTile(
              'Temperature',
              '${temp.toStringAsFixed(1)} °C',
              Icons.thermostat,
              Colors.orange,
            ),
            sensorTile(
              'Humidity',
              '${hum.toStringAsFixed(1)} %',
              Icons.water_drop,
              Colors.blue,
            ),
            sensorTile('Soil (ADC)', '$soil', Icons.grass, Colors.brown),
            sensorTile('Gas (ADC)', '$gas', Icons.cloud, Colors.grey),
            sensorTile(
              'Light',
              '${light.toStringAsFixed(1)} lx',
              Icons.wb_sunny,
              Colors.yellow.shade700,
            ),
            sensorTile(
              'Water',
              water == 1 ? 'OK' : 'LOW',
              Icons.water,
              water == 1 ? Colors.blue : Colors.redAccent,
            ),
            const SizedBox(height: 12),

            // Charts Button
            ElevatedButton.icon(
              icon: const Icon(Icons.show_chart),
              label: const Text("View Charts"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChartsPage(
                      tempData: tempHistory,
                      humData: humHistory,
                      lightData: lightHistory,
                      gasData: gasHistory,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
            const SizedBox(height: 12),
            // Add News (Admin Only)
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add News (Admin)"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddNewsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
                backgroundColor: Colors.green,
              ),
            ),

            //Greenhouse News Button
            ElevatedButton.icon(
              icon: const Icon(Icons.article),
              label: const Text("Greenhouse News"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GreenhouseNewsPage(), // ඔබේ news page
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
            // Auto Mode Switch
            SwitchListTile(
              title: const Text('Auto Mode'),
              value: autoMode,
              onChanged: (v) => setControlBool('autoMode', v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                controlButton(
                  "Fan",
                  fanOn,
                  Icons.air,
                  Colors.teal,
                  () => setControlBool('fanOn', !fanOn),
                ),
                controlButton(
                  "Bulb",
                  bulbOn,
                  Icons.lightbulb,
                  Colors.amber,
                  () => setControlBool('bulbOn', !bulbOn),
                ),
              ],
            ),

            // Threshold sliders
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text('Temp Threshold: $tempThreshold °C'),
                    Slider(
                      min: 15,
                      max: 50,
                      value: tempThreshold.toDouble(),
                      onChanged: (v) =>
                          setState(() => tempThreshold = v.toInt()),
                      onChangeEnd: (v) =>
                          setControlInt('tempThreshold', v.toInt()),
                    ),
                    Text('Light Threshold: $lightThreshold lx'),
                    Slider(
                      min: 0,
                      max: 1000,
                      value: lightThreshold.toDouble(),
                      onChanged: (v) =>
                          setState(() => lightThreshold = v.toInt()),
                      onChangeEnd: (v) =>
                          setControlInt('lightThreshold', v.toInt()),
                    ),
                    Text('Gas Threshold: $gasThreshold'),
                    Slider(
                      min: 0,
                      max: 4095,
                      value: gasThreshold.toDouble(),
                      onChanged: (v) =>
                          setState(() => gasThreshold = v.toInt()),
                      onChangeEnd: (v) =>
                          setControlInt('gasThreshold', v.toInt()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
