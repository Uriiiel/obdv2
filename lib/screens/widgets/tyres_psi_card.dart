import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:obdv2/core/constants.dart';

class SensorData {
  final String nombre;
  final String valor;

  SensorData({required this.nombre, required this.valor});
}

// === Aquí se puede añadir el servicio Firebase ===
class SensorService {
  Stream<List<SensorData>> streamSensores() {
    final ref = FirebaseDatabase.instance.ref('SensoresMotor');
    return ref.onValue.map<List<SensorData>>((event) { // Especifica el tipo aquí
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return <SensorData>[]; // Lista explícitamente tipada

      return data.entries.map<SensorData>((entry) { // Tipo en el map interno
        return SensorData(
          nombre: entry.key.toString(),
          valor: entry.value.toString(), // Asumiendo que entry.value es el valor directo
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
  final SensorData sensorData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white10, // Cambié la condición de alerta a un color estático
        border: Border.all(
          color: primaryColor, // Mantengo el color primario para el borde
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
