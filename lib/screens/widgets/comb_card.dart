import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:obdv2/core/constants.dart';

class CombCard {
  final String nombre;
  final String valor;

  CombCard({required this.nombre, required this.valor});
}
class SensorService {
  Stream<List<CombCard>> streamSensores() {
    final ref = FirebaseDatabase.instance.ref('SensoresCombustible');
    return ref.onValue.map<List<CombCard>>((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return <CombCard>[];

      return data.entries.map<CombCard>((entry) {
        return CombCard(
          nombre: entry.key.toString(),
          valor: entry.value.toString(),
        );
      }).toList();
    }).handleError((error) {
      print("Error de Firebase: $error");
      throw error;
    });
  }
}

class SensorCard extends StatelessWidget {
  const SensorCard({
    super.key,
    required this.isBottomTwoTyres,
    required this.sensorData,
  }); 

  final bool isBottomTwoTyres;
  final CombCard sensorData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white10,
        border: Border.all(
          color: primaryColor,
          width: 2,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sensorName(),
          const Spacer(),
          sensorValue(),
        ],
      ),
    );
  }

  Widget sensorName() {
    return Text(
      sensorData.nombre.toUpperCase(),
      style: const TextStyle(fontSize: 11, color: Colors.white),
    );
  }

  Text sensorValue() {
    return Text(
      sensorData.valor,
      style: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
