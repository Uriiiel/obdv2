import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class BatteryStatus extends StatefulWidget {
  const BatteryStatus({super.key, required this.constraints});
  final BoxConstraints constraints;

  @override
  _BatteryStatusState createState() => _BatteryStatusState();
}

class _BatteryStatusState extends State<BatteryStatus> {
  String voltage = "...";
  final Map<String, String> oxygenValues = {
    'Sensor oxigeno-B1S1': '...',
    'Sensor oxigeno-B1S2': '...',
    'Sensor oxigeno-B1S3': '...',
    'Sensor oxigeno-B1S4': '...',
    'Sensor oxigeno-B2S1': '...',
    'Sensor oxigeno-B2S2': '...',
    'Sensor oxigeno-B2S3': '...',
    'Sensor oxigeno-B2S4': '...',
  };

  @override
  void initState() {
    super.initState();
    _getVoltage();
    _listenOxygen();
  }

  void _getVoltage() {
    FirebaseDatabase.instance
        .ref('/SensoresMotor/Voltaje')
        .onValue
        .listen((event) {
      setState(() {
        voltage = event.snapshot.value.toString();
      });
    });
  }

  void _listenOxygen() {
    final db = FirebaseDatabase.instance.ref('SensoresOxigeno');
    for (var key in oxygenValues.keys) {
      db.child(key).onValue.listen((event) {
        setState(() {
          oxygenValues[key] = event.snapshot.value.toString();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildDetail('Voltaje', '$voltage V', big: true),
          const SizedBox(height: 20),
          // luego todos los sensores de oxígeno
          ...oxygenValues.entries.map((e) {
            return _buildDetail(e.key, e.value +' V', big: false);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDetail(String label, String value, {bool big = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontSize: big ? 70 : 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
