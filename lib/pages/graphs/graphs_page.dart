import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RealTimeLineChart extends StatefulWidget {
  @override
  _RealTimeLineChartState createState() => _RealTimeLineChartState();
}

final Color colorPrimary = Color(0xFF007AFF); // Azul principal

class _RealTimeLineChartState extends State<RealTimeLineChart> {
  List<ChartData> chartData = [];
  late DatabaseReference _databaseRef;
  String selectedChart = '/SensoresMotor/Voltaje'; // Opción inicial seleccionada
  StreamSubscription<DatabaseEvent>? _databaseSubscription; // Listener de Firebase

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
    _databaseSubscription = _databaseRef.child(selectedChart).onValue.listen((event) {
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
      case '/SensoresMotor/Voltaje':
        return 16;
      case '/SensoresMotor/Avance encendido':
        return 15;
      case '/SensoresMotor/Carga del motor':
        return 100;
      case '/SensoresMotor/Consumo instantáneo combustible':
        return 50;
      case '/SensoresMotor/Flujo aire masivo':
        return 100;
      case '/SensoresMotor/Presion barometrica':
        return 20;
      case '/SensoresMotor/Presión colector admisión':
        return 100;
      case '/SensoresMotor/Presión combustible':
        return 100;
      case '/SensoresMotor/RPM':
        return 8000;
      case '/SensoresMotor/Temperatura aceite':
        return 120;
      case '/SensoresMotor/Temperatura refrigerante':
        return 120;
      case '/SensoresMotor/Tmp Funcionamiento':
        return 30;
      case '/SensoresMotor/Valvula admision':
        return 100;
      case '/SensoresMotor/Velocidad':
        return 200;
      default:
        return 0.0;
    }
  }

  // Método para obtener el rango mínimo
  double _getYAxisMin() {
    switch (selectedChart) {
      case '/SensoresMotor/Voltaje':
        return 0;
      case '/SensoresMotor/Avance encendido':
        return 0;
      case '/SensoresMotor/Carga del motor':
        return 0;
      case '/SensoresMotor/Consumo instantáneo combustible':
        return 0;
      case '/SensoresMotor/Flujo aire masivo':
        return 0;
      case '/SensoresMotor/Presion barometrica':
        return 0;
      case '/SensoresMotor/Presión colector admisión':
        return 0;
      case '/SensoresMotor/Presión combustible':
        return 0;
      case '/SensoresMotor/RPM':
        return 0;
      case '/SensoresMotor/Temperatura aceite':
        return 0;
      case '/SensoresMotor/Temperatura refrigerante':
        return 0;
      case '/SensoresMotor/Tmp Funcionamiento':
        return -10;
      case '/SensoresMotor/Valvula admision':
        return 0;
      case '/SensoresMotor/Velocidad':
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
                  '/SensoresMotor/Voltaje',
                  '/SensoresMotor/Avance encendido',
                  '/SensoresMotor/Carga del motor',
                  '/SensoresMotor/Consumo instantáneo combustible',
                  '/SensoresMotor/Flujo aire masivo',
                  '/SensoresMotor/Presion barometrica',                  
                  '/SensoresMotor/Presión colector admisión',
                  '/SensoresMotor/Presión combustible',
                  '/SensoresMotor/RPM',                  
                  '/SensoresMotor/Temperatura aceite',
                  '/SensoresMotor/Temperatura refrigerante',
                  '/SensoresMotor/Tmp Funcionamiento',
                  '/SensoresMotor/Valvula admision',
                  '/SensoresMotor/Velocidad',
                ]
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.replaceAll('/SensoresMotor/',
                              '')), // Mostrar nombre sin "/Sensores/"
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
                      text: selectedChart.replaceAll('/SensoresMotor/', '')),
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