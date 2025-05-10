import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class BatteryStatus extends StatefulWidget {
  const BatteryStatus({super.key, required this.constraints});
  final BoxConstraints constraints;

  @override
  _BatteryStatusState createState() => _BatteryStatusState();
}

class _BatteryStatusState extends State<BatteryStatus> {
  String voltage = "Cargando...";

  @override
  void initState() {
    super.initState();
    _getVoltage();
  }

  void _getVoltage() {
    final dbRef = FirebaseDatabase.instance.ref('/SensoresMotor/Voltaje');
    dbRef.onValue.listen((event) {
      final data = event.snapshot.value;
      setState(() {
        voltage = data.toString() + " V";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
            "Voltaje",
          ),
        Text(
          voltage,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Text(
        //   "65%",
        //   style: TextStyle(
        //     color: Colors.white,
        //     fontSize: 25,
        //     fontWeight: FontWeight.w600,
        //   ),
        // ),
        Spacer(),
        // Text(
        //   "Charging".toUpperCase(),
        //   style: TextStyle(
        //     color: Colors.white,
        //     fontSize: 20,
        //     fontWeight: FontWeight.w500,
        //   ),
        // ),
        // Text(
        //   "25 min remaining",
        //   style: TextStyle(
        //     color: Colors.white,
        //     fontSize: 20,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        SizedBox(height: widget.constraints.maxHeight * 0.13),
        Row(
          children: [
            // Text(
            //   "25 min/hr",
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: 20,
            //     fontWeight: FontWeight.w800,
            //   ),
            // ),
            // Spacer(),
            // Text(
            //   "220 V",
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: 20,
            //     fontWeight: FontWeight.w800,
            //   ),
            // ),
          ],
        ),
        SizedBox(height: widget.constraints.maxHeight * 0.03),
      ],
    );
  }
}
