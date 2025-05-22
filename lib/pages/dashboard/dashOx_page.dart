import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:obdv2/pages/home_page.dart';

import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

final Color colorPrimary = Color(0xFF007AFF); // Azul principal

class DashboardOxPage extends StatefulWidget {
  final User user; // <-- Agrega esto
  const DashboardOxPage({required this.user, Key? key}) : super(key: key);

  @override
  State<DashboardOxPage> createState() => _DashboardOxPageState();
}

final List<FlSpot> _historialVoltaje = [];
final List<FlSpot> _historialAFR = [];
int _contadorDatos = 0;

class _DashboardOxPageState extends State<DashboardOxPage> {
  // Notifiers para Voltaje
  final ValueNotifier<double> _voltajeB1S1Notifier = ValueNotifier(0.0);
  final ValueNotifier<double> _voltajeB1S2Notifier = ValueNotifier(0.0);
  final ValueNotifier<double> _voltajeB2S1Notifier = ValueNotifier(0.0);
  final ValueNotifier<double> _voltajeB2S2Notifier = ValueNotifier(0.0);

  // Notifiers para AFR
  final ValueNotifier<double> _afrB1S1Notifier = ValueNotifier(0.0);
  final ValueNotifier<double> _afrB1S2Notifier = ValueNotifier(0.0);
  final ValueNotifier<double> _afrB2S1Notifier = ValueNotifier(0.0);
  final ValueNotifier<double> _afrB2S2Notifier = ValueNotifier(0.0);

  String selectedSensor = "Sensor B1S1";

  final DatabaseReference _databaseRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://automotrizapp-default-rtdb.firebaseio.com',
  ).ref();

  @override
  void initState() {
    super.initState();
    _setupDatabaseListeners();
  }

  void _setupDatabaseListeners() {
    // Listeners para Voltaje
    _databaseRef.child('SensoresOxigeno/voltajeOxi1').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _voltajeB1S1Notifier.value = -1;
        } else {
          final value = double.tryParse(data.toString()) ?? 0.0;
          _voltajeB1S1Notifier.value = value;
        }
      }
    });

    _databaseRef.child('SensoresOxigeno/voltajeOxi2').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _voltajeB1S2Notifier.value = -1;
        } else {
          final value = double.tryParse(data.toString()) ?? 0.0;
          _voltajeB1S2Notifier.value = value;
        }
      }
    });

    _databaseRef.child('SensoresOxigeno/voltajeOxi3').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _voltajeB2S1Notifier.value = -1;
        } else {
          final value = double.tryParse(data.toString()) ?? 0.0;
          _voltajeB2S1Notifier.value = value;
        }
      }
    });

    _databaseRef.child('SensoresOxigeno/voltajeOxi4').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _voltajeB2S2Notifier.value = -1;
        } else {
          final value = double.tryParse(data.toString()) ?? 0.0;
          _voltajeB2S2Notifier.value = value;
        }
      }
    });

    // Listeners para AFR
    _databaseRef.child('SensoresOxigeno/AFROxi1').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _afrB1S1Notifier.value = -1;
        } else {
          final value = double.tryParse(data.toString()) ?? 0.0;
          _afrB1S1Notifier.value = value;
        }
      }
    });

    _databaseRef.child('SensoresOxigeno/AFROxi2').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _afrB1S2Notifier.value = -1;
        } else {
          final value = double.tryParse(data.toString()) ?? 0.0;
          _afrB1S2Notifier.value = value;
        }
      }
    });

    _databaseRef.child('SensoresOxigeno/AFROxi3').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _afrB2S1Notifier.value = -1;
        } else {
          final value = double.tryParse(data.toString()) ?? 0.0;
          _afrB2S1Notifier.value = value;
        }
      }
    });

    _databaseRef.child('SensoresOxigeno/AFROxi4').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _afrB2S2Notifier.value = -1;
        } else {
          final value = double.tryParse(data.toString()) ?? 0.0;
          _afrB2S2Notifier.value = value;
        }
      }
    });
  }

  Widget buildVoltajeGauge(double value, String title) {
    if (value == -1) {
      return Center(
        child: Text(
          "No soportado",
          style: TextStyle(
            fontSize: 40,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return gauges.SfRadialGauge(
      axes: <gauges.RadialAxis>[
        gauges.RadialAxis(
          startAngle: 140,
          endAngle: 40,
          minimum: 0,
          maximum: 1,
          radiusFactor: 0.7,
          majorTickStyle: const gauges.MajorTickStyle(
            length: 12,
            thickness: 2,
            color: Colors.white,
          ),
          minorTicksPerInterval: 4,
          minorTickStyle: const gauges.MinorTickStyle(
            length: 6,
            thickness: 1,
            color: Colors.grey,
          ),
          axisLineStyle: const gauges.AxisLineStyle(
            thickness: 15,
            gradient: SweepGradient(
              colors: [Colors.red, Colors.green, Colors.red],
              stops: [0, 0.4, 0.6],
            ),
          ),
          axisLabelStyle: const gauges.GaugeTextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          pointers: <gauges.GaugePointer>[
            gauges.NeedlePointer(
              value: value,
              enableAnimation: true,
              animationType: gauges.AnimationType.easeOutBack,
              needleColor: Colors.red,
              needleStartWidth: 1,
              needleEndWidth: 5,
              needleLength: 0.75,
              animationDuration: 2000,
              gradient: const LinearGradient(
                colors: [Colors.white, Colors.red],
              ),
              knobStyle: gauges.KnobStyle(
                color: Color(0xFF3F3F3F),
                borderColor: Color(0xFF3F3F3F).withAlpha(150),
                borderWidth: 2,
              ),
            ),
          ],
          annotations: [
            gauges.GaugeAnnotation(
              widget: Column(
                children: [
                  SizedBox(height: 180),
                  Text(
                    "${value.toStringAsFixed(2)} V",
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              angle: 90,
              positionFactor: 0.75,
            )
          ],
        ),
      ],
    );
  }

  Widget buildAFRGauge(double value, String title) {
    if (value == -1) {
      return const Center(
        child: Text(
          "No soportado",
          style: TextStyle(
            fontSize: 40,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return gauges.SfRadialGauge(
      axes: <gauges.RadialAxis>[
        gauges.RadialAxis(
          startAngle: 140,
          endAngle: 40,
          minimum: 10,
          maximum: 20,
          radiusFactor: 0.7,
          majorTickStyle: const gauges.MajorTickStyle(
            length: 12,
            thickness: 2,
            color: Colors.white,
          ),
          minorTicksPerInterval: 4,
          minorTickStyle: const gauges.MinorTickStyle(
            length: 6,
            thickness: 1,
            color: Colors.grey,
          ),
          axisLineStyle: const gauges.AxisLineStyle(
            thickness: 15,
            gradient: SweepGradient(
              colors: [
                Colors.red,
                Colors.yellow,
                Colors.green,
                Colors.yellow,
                Colors.red
              ],
              stops: [0, 0.25, 0.35, 0.6, 0.85],
            ),
          ),
          axisLabelStyle: const gauges.GaugeTextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          pointers: <gauges.GaugePointer>[
            gauges.NeedlePointer(
              value: value,
              enableAnimation: true,
              animationType: gauges.AnimationType.easeOutBack,
              needleColor: Colors.red,
              needleStartWidth: 1,
              needleEndWidth: 5,
              needleLength: 0.75,
              animationDuration: 2000,
              gradient: LinearGradient(
                colors: [Colors.white, Colors.red],
              ),
              knobStyle: gauges.KnobStyle(
                color: Color(0xFF3F3F3F),
                borderColor: Color(0xFF3F3F3F).withAlpha(150),
                borderWidth: 2,
              ),
            ),
          ],
          annotations: [
            gauges.GaugeAnnotation(
              widget: Column(
                children: [
                  SizedBox(height: 180),
                  Text(
                    "${value.toStringAsFixed(2)} AFR",
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              angle: 90,
              positionFactor: 0.75,
            )
          ],
        ),
      ],
    );
  }

  Widget buildGaugePair() {
    return Row(
      children: [
        // Medidor de Voltaje
        Expanded(
          child: ValueListenableBuilder<double>(
            valueListenable: _getVoltajeNotifier(),
            builder: (context, value, child) {
              return buildVoltajeGauge(
                  value, "Voltaje ${selectedSensor.substring(7)}");
            },
          ),
        ),

        // Panel central con información y botones
        Container(
          width: 300,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF202020),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Información Técnica',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Sensor: $selectedSensor\n\n'
                      'Voltaje normal: 0.1-0.9V\n'
                      'AFR ideal: 14.7 (gasolina)\n'
                      'Rango AFR: 12-18\n\n'
                      'B1: Banco 1 (antes del catalizador)\n'
                      'B2: Banco 2 (después del catalizador)',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _mostrarGraficoVoltaje(context),
                      icon: Icon(Icons.show_chart, color: Colors.white),
                      label: Text(
                        'Gráfico Voltaje',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _mostrarGraficoAFR(context),
                      icon: Icon(Icons.show_chart, color: Colors.white),
                      label: Text(
                        'Gráfico AFR',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),

        // Medidor de AFR
        Expanded(
          child: ValueListenableBuilder<double>(
            valueListenable: _getAFRNotifier(),
            builder: (context, value, child) {
              return buildAFRGauge(value, "AFR ${selectedSensor.substring(7)}");
            },
          ),
        ),
      ],
    );
  }

// Métodos auxiliares para obtener el notifier correcto
  ValueNotifier<double> _getVoltajeNotifier() {
    switch (selectedSensor) {
      case 'Sensor B1S1':
        return _voltajeB1S1Notifier;
      case 'Sensor B1S2':
        return _voltajeB1S2Notifier;
      case 'Sensor B2S1':
        return _voltajeB2S1Notifier;
      case 'Sensor B2S2':
        return _voltajeB2S2Notifier;
      default:
        return _voltajeB1S1Notifier;
    }
  }

  ValueNotifier<double> _getAFRNotifier() {
    switch (selectedSensor) {
      case 'Sensor B1S1':
        return _afrB1S1Notifier;
      case 'Sensor B1S2':
        return _afrB1S2Notifier;
      case 'Sensor B2S1':
        return _afrB2S1Notifier;
      case 'Sensor B2S2':
        return _afrB2S2Notifier;
      default:
        return _afrB1S1Notifier;
    }
  }

// Métodos para mostrar los gráficos
  void _mostrarGraficoVoltaje(BuildContext context) {
    _actualizarHistorial();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Escucha cambios en tiempo real al notifier
            _getVoltajeNotifier().addListener(() {
              setState(() {
                _actualizarHistorial();
              });
            });

            return AlertDialog(
              title: Text('Historial de Voltaje - $selectedSensor'),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 300,
                child: charts.SfCartesianChart(
                  primaryXAxis: charts.NumericAxis(
                    title: charts.AxisTitle(text: 'Tiempo'),
                  ),
                  primaryYAxis: charts.NumericAxis(
                    title: charts.AxisTitle(text: 'Voltaje (V)'),
                    minimum: 0,
                    maximum: 1,
                    labelFormat: '{value}V',
                  ),
                  series: <charts.LineSeries<FlSpot, double>>[
                    charts.LineSeries<FlSpot, double>(
                      dataSource: _historialVoltaje,
                      xValueMapper: (FlSpot spot, _) => spot.x,
                      yValueMapper: (FlSpot spot, _) => spot.y,
                      color: Colors.blueAccent,
                      width: 3,
                      markerSettings: const charts.MarkerSettings(
                        isVisible: true,
                        shape: charts.DataMarkerType.circle,
                        color: Colors.blue,
                      ),
                      dataLabelSettings:
                          const charts.DataLabelSettings(isVisible: false),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cerrar'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarGraficoAFR(BuildContext context) {
    _actualizarHistorial();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Escucha cambios del notifier AFR
            _getAFRNotifier().addListener(() {
              setState(() {
                _actualizarHistorial();
              });
            });

            return AlertDialog(
              title: Text('Historial AFR - $selectedSensor'),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 300,
                child: charts.SfCartesianChart(
                  primaryXAxis: charts.NumericAxis(
                    title: charts.AxisTitle(text: 'Tiempo'),
                  ),
                  primaryYAxis: charts.NumericAxis(
                    title: charts.AxisTitle(text: 'AFR'),
                    minimum: 10,
                    maximum: 20,
                    labelFormat: '{value}',
                  ),
                  series: <charts.LineSeries<FlSpot, double>>[
                    charts.LineSeries<FlSpot, double>(
                      dataSource: _historialAFR,
                      xValueMapper: (FlSpot spot, _) => spot.x,
                      yValueMapper: (FlSpot spot, _) => spot.y,
                      color: const Color.fromARGB(255, 17, 255, 0),
                      width: 3,
                      markerSettings: const charts.MarkerSettings(
                        isVisible: true,
                        shape: charts.DataMarkerType.circle,
                        color: Colors.blue,
                      ),
                      dataLabelSettings:
                          const charts.DataLabelSettings(isVisible: false),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cerrar'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _actualizarHistorial() {
    _contadorDatos++;
    final voltaje = _getVoltajeNotifier().value;
    final afr = _getAFRNotifier().value;

    if (voltaje != -1)
      _historialVoltaje.add(FlSpot(_contadorDatos.toDouble(), voltaje));
    if (afr != -1) _historialAFR.add(FlSpot(_contadorDatos.toDouble(), afr));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7E7E7E),
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Dashboard - Oxígeno",
          style: TextStyle(
            fontSize: 24,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(user: widget.user)),
              (route) => false,
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // DropdownButton para seleccionar sensor
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color.fromARGB(255, 1, 23, 61), width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: selectedSensor,
                  items: <String>[
                    'Sensor B1S1',
                    'Sensor B1S2',
                    'Sensor B2S1',
                    'Sensor B2S2',
                  ]
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSensor = newValue!;
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
            Expanded(
              child: Center(
                child: buildGaugePair(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
