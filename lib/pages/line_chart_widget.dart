import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget {
  final String sensorName;
  final dynamic sensorValue;

  const LineChartWidget({
    Key? key,
    required this.sensorName,
    required this.sensorValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LineChart(
        mainLineData(),
      ),
    );
  }

  LineChartData mainLineData() {
    // Asegurarse de que sensorValue es un double
    double sensorValueDouble = _toDouble(sensorValue);

    return LineChartData(
      lineBarsData: [
        // Línea vertical desde (0, 0) hasta (0, sensorValue)
        LineChartBarData(
          spots: [
            FlSpot(0, sensorValueDouble),  // Punto en el origen (X=0, Y=0)
            FlSpot(0, 0), // Línea vertical hasta el valor del sensor (X=0, Y=sensorValue)
          ],
          isCurved: false, // Línea recta
          color: Colors.blue, // Color de la línea
          dotData: FlDotData(show: false), // No mostrar puntos en la línea
          belowBarData: BarAreaData(show: false), // No mostrar área debajo de la línea
        ),
      ],
      gridData: FlGridData(show: true), // Mostrar la grilla
      titlesData: FlTitlesData(show: true),
      borderData: FlBorderData(show: true), // Mostrar borde
      minX: -1,  // Establecer el rango en X para centrar la línea -1
      maxX: 1,   // Solo necesitamos 1 punto en X, que es el valor fijo 1
      minY: 0,   // Rango mínimo para el eje Y 0
      maxY: sensorValueDouble + 10,  // Ajustar este valor al máximo valor que esperas para el sensor 
    );
  }

  // Función para convertir el valor a double si es necesario
  double _toDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else {
      throw ArgumentError("El valor no es ni un int ni un double.");
    }
  }
}
