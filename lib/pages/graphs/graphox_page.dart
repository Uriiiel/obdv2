import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraphoxPage extends StatefulWidget {
  @override
  _GraphoxPageState createState() => _GraphoxPageState();
}

final Color colorPrimary = Color(0xFF007AFF); // Azul principal

class _GraphoxPageState extends State<GraphoxPage> {
  List<ChartData> chartData = [];
  late DatabaseReference _databaseRef;
  String selectedChart = '/SensoresOxigeno/Sensor oxigeno-B1S1'; // Opción inicial seleccionada
  StreamSubscription<DatabaseEvent>?
      _databaseSubscription; // Listener de Firebase

  @override
  void initState() {
    super.initState();
    _databaseRef = FirebaseDatabase.instance.ref();
    _setupDatabaseListener();
  }

  // Método para configurar el listener de Firebase
  void _setupDatabaseListener() {
    // Cancelar el listener anterior si existe
    _databaseSubscription?.cancel();

    // Configurar un nuevo listener para la métrica seleccionada
    _databaseSubscription =
        _databaseRef.child(selectedChart).onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        final double newValue = double.tryParse(data.toString()) ?? 0.0;
        setState(() {
          chartData.add(ChartData(chartData.length, newValue));
          if (chartData.length > 5000) {
            chartData.removeAt(0); // Limitar el número de puntos en el gráfico
          }
        });
      }
    });
  }

  // Método para obtener el rango máximo según la métrica seleccionada
  double _getYAxisMax() {
  switch (selectedChart) {
    case '/SensoresOxigeno/Sensor oxigeno-B1S1':
      return 1.0; // Voltaje máximo de 1.0 V
    case '/SensoresOxigeno/Sensor oxigeno-B1S2':
      return 1.0; // Voltaje máximo de 1.0 V
    case '/SensoresOxigeno/Sensor oxigeno-B1S3':
      return 1.0; // Voltaje máximo de 1.0 V
    case '/SensoresOxigeno/Sensor oxigeno-B1S4':
      return 1.0; // Voltaje máximo de 1.0 V
    case '/SensoresOxigeno/Sensor oxigeno-B2S1':
      return 1.0; // Voltaje máximo de 1.0 V
    case '/SensoresOxigeno/Sensor oxigeno-B2S2':
      return 1.0; // Voltaje máximo de 1.0 V
    case '/SensoresOxigeno/Sensor oxigeno-B2S3':
      return 1.0; // Voltaje máximo de 1.0 V
    case '/SensoresOxigeno/Sensor oxigeno-B2S4':
      return 1.0; // Voltaje máximo de 1.0 V
    case '/SensoresOxigeno/Temp catalizador-B1S1':
      return 1200; // Temperatura máxima de 1200°C
    case '/SensoresOxigeno/Temp catalizador-B1S2':
      return 1200; // Temperatura máxima de 1200°C
    case '/SensoresOxigeno/Temp catalizador-B2S1':
      return 1200; // Temperatura máxima de 1200°C
    case '/SensoresOxigeno/Temp catalizador-B2S2':
      return 1200; // Temperatura máxima de 1200°C
    default:
      return 0.0;
  }
}

  // Método para obtener el rango mínimo según la métrica seleccionada
  double _getYAxisMin() {
  switch (selectedChart) {
    case '/SensoresOxigeno/Sensor oxigeno-B1S1':
      return 0;
    case '/SensoresOxigeno/Sensor oxigeno-B1S2':
      return 0;
    case '/SensoresOxigeno/Sensor oxigeno-B1S3':
      return 0;
    case '/SensoresOxigeno/Sensor oxigeno-B1S4':
      return 0;
    case '/SensoresOxigeno/Sensor oxigeno-B2S1':
      return 0;
    case '/SensoresOxigeno/Sensor oxigeno-B2S2':
      return 0;
    case '/SensoresOxigeno/Sensor oxigeno-B2S3':
      return 0;
    case '/SensoresOxigeno/Sensor oxigeno-B2S4':
      return 0;
    case '/SensoresOxigeno/Temp catalizador-B1S1':
      return 0;
    case '/SensoresOxigeno/Temp catalizador-B1S2':
      return 0;
    case '/SensoresOxigeno/Temp catalizador-B2S1':
      return 0;
    case '/SensoresOxigeno/Temp catalizador-B2S2':
      return 0;
    default:
      return 0.0;
  }
}

  @override
  void dispose() {
    // Cancelar el listener cuando el widget se destruye
    _databaseSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 188, 188, 188),
      appBar: AppBar(
        backgroundColor: colorPrimary,
        title: const Text(
          "Gráfica en tiempo real",
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Dropdown para seleccionar métrica
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.blueAccent, width: 2), // Borde azul
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2), // Sombra ligera
                  ),
                ],
              ),
              child: DropdownButton<String>(
                value: selectedChart,
                items: <String>[
                  '/SensoresOxigeno/Sensor oxigeno-B1S1',
                  '/SensoresOxigeno/Sensor oxigeno-B1S2',
                  '/SensoresOxigeno/Sensor oxigeno-B1S3',
                  '/SensoresOxigeno/Sensor oxigeno-B1S4',
                  '/SensoresOxigeno/Sensor oxigeno-B2S1',
                  '/SensoresOxigeno/Sensor oxigeno-B2S2',
                  '/SensoresOxigeno/Sensor oxigeno-B2S3',
                  '/SensoresOxigeno/Sensor oxigeno-B2S4',
                  '/SensoresOxigeno/Temp catalizador-B1S1',
                  '/SensoresOxigeno/Temp catalizador-B1S2',
                  '/SensoresOxigeno/Temp catalizador-B2S1',
                  '/SensoresOxigeno/Temp catalizador-B2S2',
                ]
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.replaceAll('/SensoresOxigeno/',
                              '')),
                        ))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedChart = newValue!;
                    chartData.clear(); // Reiniciar datos al cambiar métrica
                    _setupDatabaseListener(); // Configurar listener para la nueva métrica
                  });
                },
                isExpanded: true,
                underline: Container(), // Quita la línea por defecto
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.blueAccent,
                  size: 28,
                ),
                dropdownColor: Colors.white,
              ),
            ),
          ),
          // Contenedor para la gráfica
          Expanded(
            child: Center(
              child: SfCartesianChart(
                primaryXAxis: NumericAxis(
                  title: AxisTitle(text: 'Tiempo (s)'),
                  autoScrollingMode: AutoScrollingMode.end,
                  autoScrollingDelta: 10,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(
                      text: selectedChart.replaceAll('/SensoresOxigeno/', '')),
                  minimum: _getYAxisMin(),
                  maximum: _getYAxisMax(),
                ),
                series: <LineSeries<ChartData, int>>[
                  LineSeries<ChartData, int>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    color: Colors.blue,
                    width: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final int x;
  final double y;

  ChartData(this.x, this.y);
}