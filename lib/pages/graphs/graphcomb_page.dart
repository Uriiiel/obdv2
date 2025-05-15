import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraphcombPage extends StatefulWidget {
  @override
  _GraphcombPageState createState() => _GraphcombPageState();
}

final Color colorPrimary = Color(0xFF007AFF); // Azul principal

class _GraphcombPageState extends State<GraphcombPage> {
  List<ChartData> chartData = [];
  late DatabaseReference _databaseRef;
  String selectedChart = '/SensoresCombustible/Consumo instantáneo de combustible'; // Opción inicial seleccionada
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
    case '/SensoresCombustible/Consumo instantáneo de combustible':
      return 50; // 50 L/h o 50 GPH
    case '/SensoresCombustible/Estado del sistema de combustible':
      return 100;
    case '/SensoresCombustible/Nivel de combustible':
      return 100; // 0% a 100%
    case '/SensoresCombustible/Porcentaje etanol en combustible':
      return 100; // 0% a 100%
    case '/SensoresCombustible/Presion Riel combustible directa':
      return 300; // 300 bar o 4350 PSI
    case '/SensoresCombustible/Presion Riel combustible relativa':
      return 10; // 10 bar o 145 PSI
    case '/SensoresCombustible/Presión de la bomba de combustible':
      return 10; // 10 bar o 145 PSI
    case '/SensoresCombustible/Tipo combustible':
      return 5; // Dependiendo de los tipos de combustible soportados
    default:
      return 0.0;
  }
}

  // Método para obtener el rango mínimo según la métrica seleccionada
  double _getYAxisMin() {
    switch (selectedChart) {
      case '/SensoresCombustible/Consumo instantáneo de combustible':
        return 0; // Rango mínimo para voltaje
      case '/SensoresCombustible/Estado del sistema de combustible':
        return 0; // Rango mínimo para RPM
      case '/SensoresCombustible/Nivel de combustible':
        return 0; // Rango mínimo para carga del motor
      case '/SensoresCombustible/Porcentaje etanol en combustible':
        return 0; // Rango mínimo para consumo de combustible
      case '/SensoresCombustible/Presion Riel combustible directa':
        return 0; // Rango mínimo para posición del acelerador
      case '/SensoresCombustible/Presion Riel combustible relativa':
        return 0; // Rango mínimo para presión del colector de admisión
      case '/SensoresCombustible/Presión de la bomba de combustible':
        return 0; // Rango mínimo para presión de combustible
      case '/SensoresCombustible/Tipo combustible':
        return 0; // Rango mínimo para sensor MAP
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
                  '/SensoresCombustible/Consumo instantáneo de combustible',
                  '/SensoresCombustible/Estado del sistema de combustible',
                  '/SensoresCombustible/Nivel de combustible',
                  '/SensoresCombustible/Porcentaje etanol en combustible',
                  '/SensoresCombustible/Presion Riel combustible directa',
                  '/SensoresCombustible/Presion Riel combustible relativa',
                  '/SensoresCombustible/Presión de la bomba de combustible',
                  '/SensoresCombustible/Tipo combustible',
                ]
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.replaceAll('/SensoresCombustible/',
                              '')),
                        ))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedChart = newValue!;
                    chartData.clear();
                    _setupDatabaseListener();
                  });
                },
                isExpanded: true,
                underline: Container(),
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
                      text: selectedChart.replaceAll('/SensoresCombustible/', '')),
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