import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:obdv2/pages/home_page.dart';
//import 'package:obdv2/pages/dashboard/home_dash.dart';

import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

final Color colorPrimary = Color(0xFF007AFF); // Azul principal

class DashboardCombPage extends StatefulWidget {
  final User user; // <-- Agrega esto
  const DashboardCombPage({required this.user, Key? key}) : super(key: key);

  @override
  State<DashboardCombPage> createState() => _DashboardCombPageState();
}

final List<FlSpot> _historialCombustible = [];
int _contadorCombustible = 0;

final List<FlSpot> _historialPresionCombustible = [];
int _contadorPresionComb = 0;

final List<FlSpot> _historialPresionRiel = [];
int _contadorPresionRiel = 0;

final List<FlSpot> _historialTasaCombustible = [];
int _contadorTasaCombustible = 0;

final List<FlSpot> _historialPresRielDir = [];
int _contadorPresRielDir = 0;

final List<FlSpot> _historialPresRielRel = [];
int _contadorPresRielRel = 0;

final List<FlSpot> _historialPresBomCom = [];
int _contadorPresBomCom = 0;

final List<FlSpot> _historialTipoCom = [];
int _contadorTipoCom = 0;

class _DashboardCombPageState extends State<DashboardCombPage> {
  final ValueNotifier<double> _nivComNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _presRielComNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _presComNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _tasComNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _ban1CComNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _ban1LComNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _ban2CComNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _ban2LComNotifier = ValueNotifier(0.0);
  String selectedMetric = "Nivel de combustible";
  //final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
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
    _databaseRef
        .child('SensoresCombustible/Nivel de combustible')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _nivComNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final conInsCom = double.tryParse(data.toString()) ?? 0.0;
          _nivComNotifier.value = conInsCom;
        }
      }
    });
    _databaseRef
        .child('SensoresCombustible/Presion combustible')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _presComNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final estSisCom = double.tryParse(data.toString()) ?? 0.0;
          _presComNotifier.value = estSisCom;
        }
      }
    });
    _databaseRef
        .child('SensoresCombustible/Presion riel')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _presRielComNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final nivCom = double.tryParse(data.toString()) ?? 0.0;
          _presRielComNotifier.value = nivCom;
        }
      }
    });
    _databaseRef
        .child('SensoresCombustible/Tasa combustible')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _tasComNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final porEtaCom = double.tryParse(data.toString()) ?? 0.0;
          _tasComNotifier.value = porEtaCom;
        }
      }
    });
    _databaseRef
        .child('SensoresCombustible/Banco 1 corto')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _ban1CComNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final presRielDir = double.tryParse(data.toString()) ?? 0.0;
          _ban1CComNotifier.value = presRielDir;
        }
      }
    });
    _databaseRef
        .child('SensoresCombustible/Banco 1 largo')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _ban1LComNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final presRielRel = double.tryParse(data.toString()) ?? 0.0;
          _ban1LComNotifier.value = presRielRel;
        }
      }
    });
    _databaseRef
        .child('SensoresCombustible/Banco 2 corto')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _ban2CComNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final presBomCom = double.tryParse(data.toString()) ?? 0.0;
          _ban2CComNotifier.value = presBomCom;
        }
      }
    });
    _databaseRef
        .child('SensoresCombustible/Banco 2 largo')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _ban2LComNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final tipoCom = double.tryParse(data.toString()) ?? 0.0;
          _ban2LComNotifier.value = tipoCom;
        }
      }
    });
  }

  Widget buildGauge() {
    switch (selectedMetric) {
      case 'Presión combustible': //Estado del sistema de combustible
        return buildEstSisComGauge();
      case 'Presión riel': //Nivel de combustible
        return buildNivComGauge();
      case 'Tasa combustible': //Porcentaje etanol en combustible
        return buildPorEtaComGauge();
      case 'Banco 1 - Corto': //Presion Riel combustible directa
        return buildPresRielDirGauge();
      case 'Banco 1 - Largo': //Presion Riel combustible relativa
        return buildPresRielRelGauge();
      case 'Banco 2 - Corto': //Presión de la bomba de combustible
        return buildPresBomComGauge();
      case 'Banco 2 - Largo': //Tipo combustible
        return buildTipoComGauge();
      default:
        return buildConInsComGauge();
    }
  }

  Widget buildConInsComGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _nivComNotifier,
      builder: (context, conInsCom, child) {
        if (conInsCom == -1) {
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

        // Actualizar historial
        _historialCombustible
            .add(FlSpot(_contadorCombustible.toDouble(), conInsCom));
        _contadorCombustible++;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gauge
            Expanded(
              flex: 2,
              child: gauges.SfRadialGauge(
                axes: <gauges.RadialAxis>[
                  gauges.RadialAxis(
                    startAngle: 140,
                    endAngle: 40,
                    minimum: 0,
                    maximum: 100,
                    radiusFactor: 0.9,
                    majorTickStyle: const gauges.MajorTickStyle(
                      length: 12,
                      thickness: 2,
                      color: Colors.black,
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
                        colors: [Colors.red, Colors.yellow, Colors.green],
                        stops: [0.3, 0.7, 1],
                      ),
                    ),
                    axisLabelStyle: const gauges.GaugeTextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    pointers: <gauges.GaugePointer>[
                      gauges.NeedlePointer(
                        value: conInsCom.clamp(0, 100),
                        enableAnimation: true,
                        animationType: gauges.AnimationType.easeOutBack,
                        needleColor: Colors.red,
                        needleStartWidth: 1,
                        needleEndWidth: 5,
                        needleLength: 0.75,
                        animationDuration: 2000,
                        gradient: const LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.red,
                          ],
                        ),
                        knobStyle: gauges.KnobStyle(
                          color: const Color(0xFF0166B3),
                          borderColor: const Color(0xFF709DCE).withAlpha(150),
                          borderWidth: 2,
                        ),
                      ),
                    ],
                    annotations: [
                      gauges.GaugeAnnotation(
                        widget: Column(
                          children: [
                            const SizedBox(height: 180),
                            Text(
                              "${conInsCom.toStringAsFixed(1)} %",
                              style: const TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0),
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF014C94),
                                    blurRadius: 10,
                                    offset: const Offset(0, 0),
                                  )
                                ],
                              ),
                            ),
                            const Text(
                              "Nivel de Combustible",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        angle: 90,
                        positionFactor: 0.75,
                      )
                    ],
                  ),
                ],
              ),
            ),

            // Panel informativo
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      height: 450,
                      width: 500,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0166B3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información:',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                'Sensor de Nivel de Combustible\n\n'
                                'Mide el porcentaje de combustible restante en el tanque.\n\n'
                                'Interpretación:\n'
                                '• 0-20%: Reserva de combustible.\n'
                                '• 20-40%: Nivel bajo.\n'
                                '• 40-70%: Nivel medio.\n'
                                '• 70-100%: Tanque lleno.\n\n'
                                'Precisión: ±5%.\n'
                                'Tiempo de respuesta: 2-5 segundos.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.4,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black38,
                                      blurRadius: 2,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Timer? timer;

                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setStateDialog) {
                                timer ??= Timer.periodic(
                                  const Duration(seconds: 2),
                                  (_) => setStateDialog(() {}),
                                );

                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text(
                                    'Historial de Nivel de Combustible',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: SizedBox(
                                    height: 450,
                                    width: 500,
                                    child: charts.SfCartesianChart(
                                      backgroundColor: Colors.grey.shade100,
                                      primaryXAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'Tiempo'),
                                        interval: (_contadorCombustible / 4)
                                            .ceilToDouble(),
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      primaryYAxis: const charts.NumericAxis(
                                        title:
                                            charts.AxisTitle(text: 'Nivel (%)'),
                                        minimum: 0,
                                        maximum: 100,
                                        interval: 20,
                                        majorGridLines:
                                            charts.MajorGridLines(width: 0.5),
                                      ),
                                      tooltipBehavior:
                                          charts.TooltipBehavior(enable: true),
                                      series: <charts
                                          .LineSeries<FlSpot, double>>[
                                        charts.LineSeries<FlSpot, double>(
                                          dataSource: _historialCombustible,
                                          xValueMapper: (FlSpot spot, _) =>
                                              spot.x,
                                          yValueMapper: (FlSpot spot, _) =>
                                              spot.y,
                                          color: Colors.blueAccent,
                                          width: 3,
                                          markerSettings:
                                              const charts.MarkerSettings(
                                            isVisible: true,
                                            shape: charts.DataMarkerType.circle,
                                            color: Colors.blue,
                                          ),
                                          dataLabelSettings:
                                              const charts.DataLabelSettings(
                                                  isVisible: false),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    OutlinedButton(
                                      onPressed: () {
                                        timer?.cancel();
                                        Navigator.pop(context);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Colors.blueAccent, width: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cerrar',
                                        style:
                                            TextStyle(color: Colors.blueAccent),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ).then((_) => timer?.cancel());
                      },
                      icon: const Icon(
                        Icons.show_chart,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Gráfico ",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0166B3),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildEstSisComGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _presComNotifier,
      builder: (context, estSisCom, child) {
        if (estSisCom == -1) {
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

        // Actualizar historial
        _historialPresionCombustible
            .add(FlSpot(_contadorPresionComb.toDouble(), estSisCom));
        _contadorPresionComb++;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gauge
            Expanded(
              flex: 2,
              child: gauges.SfRadialGauge(
                axes: <gauges.RadialAxis>[
                  gauges.RadialAxis(
                    startAngle: 140,
                    endAngle: 40,
                    minimum: 250,
                    maximum: 400,
                    radiusFactor: 0.9,
                    majorTickStyle: const gauges.MajorTickStyle(
                      length: 12,
                      thickness: 2,
                      color: Colors.black,
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
                        colors: [Colors.red, Colors.yellow, Colors.green],
                        stops: [0.3, 0.7, 1],
                      ),
                    ),
                    axisLabelStyle: const gauges.GaugeTextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    pointers: <gauges.GaugePointer>[
                      gauges.NeedlePointer(
                        value: estSisCom.clamp(250, 400),
                        enableAnimation: true,
                        animationType: gauges.AnimationType.easeOutBack,
                        needleColor: Colors.red,
                        needleStartWidth: 1,
                        needleEndWidth: 5,
                        needleLength: 0.75,
                        animationDuration: 2000,
                        gradient: const LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.red,
                          ],
                        ),
                        knobStyle: gauges.KnobStyle(
                          color: const Color(0xFF0166B3),
                          borderColor: const Color(0xFF709DCE).withAlpha(150),
                          borderWidth: 2,
                        ),
                      ),
                    ],
                    annotations: [
                      gauges.GaugeAnnotation(
                        widget: Column(
                          children: [
                            const SizedBox(height: 180),
                            Text(
                              "${estSisCom.toStringAsFixed(1)} kPa",
                              style: const TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0),
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF014C94),
                                    blurRadius: 10,
                                    offset: const Offset(0, 0),
                                  )
                                ],
                              ),
                            ),
                            const Text(
                              "Presión Combustible",
                              style: TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 0, 0, 0),
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
              ),
            ),

            // Panel informativo
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      height: 450,
                      width: 500,
                      alignment: Alignment.topLeft,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0166B3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información:',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                'Sensor de Presión de Combustible:\n\n'
                                'Mide la presión en el riel de inyectores.\n\n'
                                'Rangos normales:\n'
                                '• 250-300 kPa: Ralentí.\n'
                                '• 300-350 kPa: Conducción normal.\n'
                                '• 350-400 kPa: Aceleración fuerte.\n\n'
                                'Valores anormales:\n'
                                '• <250 kPa: Problema bomba de combustible.\n'
                                '• >400 kPa: Regulador de presión defectuoso.\n\n'
                                'Precisión: ±10 kPa.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.4,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black38,
                                      blurRadius: 2,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Timer? timer;

                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setStateDialog) {
                                timer ??= Timer.periodic(
                                  const Duration(seconds: 2),
                                  (_) => setStateDialog(() {}),
                                );

                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text(
                                    'Historial de Presión Combustible',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: SizedBox(
                                    height: 450,
                                    width: 500,
                                    child: charts.SfCartesianChart(
                                      backgroundColor: Colors.grey.shade100,
                                      primaryXAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'Tiempo'),
                                        interval: (_contadorPresionComb / 4)
                                            .ceilToDouble(),
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      primaryYAxis: const charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'kPa'),
                                        minimum: 250,
                                        maximum: 400,
                                        interval: 50,
                                        majorGridLines:
                                            charts.MajorGridLines(width: 0.5),
                                      ),
                                      tooltipBehavior:
                                          charts.TooltipBehavior(enable: true),
                                      series: <charts
                                          .LineSeries<FlSpot, double>>[
                                        charts.LineSeries<FlSpot, double>(
                                          dataSource:
                                              _historialPresionCombustible,
                                          xValueMapper: (FlSpot spot, _) =>
                                              spot.x,
                                          yValueMapper: (FlSpot spot, _) =>
                                              spot.y,
                                          color: Colors.blueAccent,
                                          width: 3,
                                          markerSettings:
                                              const charts.MarkerSettings(
                                            isVisible: true,
                                            shape: charts.DataMarkerType.circle,
                                            color: Colors.blue,
                                          ),
                                          dataLabelSettings:
                                              const charts.DataLabelSettings(
                                            isVisible: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    OutlinedButton(
                                      onPressed: () {
                                        timer?.cancel();
                                        Navigator.pop(context);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Colors.blueAccent, width: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cerrar',
                                        style:
                                            TextStyle(color: Colors.blueAccent),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ).then((_) => timer?.cancel());
                      },
                      icon: const Icon(
                        Icons.show_chart,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Gráfico ",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0166B3),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildNivComGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _presRielComNotifier,
      builder: (context, nivCom, child) {
        if (nivCom == -1) {
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

        // Actualizar historial
        _historialPresionRiel
            .add(FlSpot(_contadorPresionRiel.toDouble(), nivCom));
        _contadorPresionRiel++;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gauge
            Expanded(
              flex: 2,
              child: gauges.SfRadialGauge(
                axes: <gauges.RadialAxis>[
                  gauges.RadialAxis(
                    startAngle: 140,
                    endAngle: 40,
                    minimum: 500,
                    maximum: 1500,
                    radiusFactor: 0.9,
                    majorTickStyle: const gauges.MajorTickStyle(
                      length: 12,
                      thickness: 2,
                      color: Colors.black,
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
                        colors: [Colors.red, Colors.yellow, Colors.green],
                        stops: [0.3, 0.7, 1],
                      ),
                    ),
                    axisLabelStyle: const gauges.GaugeTextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    pointers: <gauges.GaugePointer>[
                      gauges.NeedlePointer(
                        value: nivCom.clamp(500, 1500),
                        enableAnimation: true,
                        animationType: gauges.AnimationType.easeOutBack,
                        needleColor: Colors.red,
                        needleStartWidth: 1,
                        needleEndWidth: 5,
                        needleLength: 0.75,
                        animationDuration: 2000,
                        gradient: const LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.red,
                          ],
                        ),
                        knobStyle: gauges.KnobStyle(
                          color: const Color(0xFF0166B3),
                          borderColor: const Color(0xFF709DCE).withAlpha(150),
                          borderWidth: 2,
                        ),
                      ),
                    ],
                    annotations: [
                      gauges.GaugeAnnotation(
                        widget: Column(
                          children: [
                            const SizedBox(height: 180),
                            Text(
                              "${nivCom.toStringAsFixed(1)} kPa",
                              style: const TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0),
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF014C94),
                                    blurRadius: 10,
                                    offset: const Offset(0, 0),
                                  )
                                ],
                              ),
                            ),
                            const Text(
                              "Presión Riel Combustible",
                              style: TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 0, 0, 0),
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
              ),
            ),

            // Panel informativo
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      height: 450,
                      width: 500,
                      alignment: Alignment.topLeft,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0166B3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información:',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                'Sensor de Presión del Riel de Combustible\n\n'
                                'Mide la presión en el riel común del sistema de inyección.\n\n'
                                'Rangos normales:\n'
                                '• 500-800 kPa: Motores convencionales.\n'
                                '• 800-1200 kPa: Motores de inyección directa.\n'
                                '• 1200-1500 kPa: Sistemas de alta presión.\n\n'
                                'Valores críticos:\n'
                                '• <500 kPa: Problema en bomba de combustible.\n'
                                '• >1500 kPa: Riesgo de fallo en el sistema.\n\n'
                                'Precisión: ±25 kPa.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.4,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black38,
                                      blurRadius: 2,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Timer? timer;

                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setStateDialog) {
                                timer ??= Timer.periodic(
                                  const Duration(seconds: 2),
                                  (_) => setStateDialog(() {}),
                                );

                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text(
                                    'Historial Presión Riel',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: SizedBox(
                                    width: 500,
                                    height: 400,
                                    child: charts.SfCartesianChart(
                                      backgroundColor: Colors.grey.shade100,
                                      primaryXAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'Tiempo'),
                                        interval: (_contadorPresionRiel / 4)
                                            .ceilToDouble()
                                            .clamp(1, 100),
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      primaryYAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'kPa'),
                                        minimum: 500,
                                        maximum: 1500,
                                        interval: 200,
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      tooltipBehavior:
                                          charts.TooltipBehavior(enable: true),
                                      series: <charts
                                          .LineSeries<FlSpot, double>>[
                                        charts.LineSeries<FlSpot, double>(
                                          dataSource: _historialPresionRiel,
                                          xValueMapper: (FlSpot spot, _) =>
                                              spot.x,
                                          yValueMapper: (FlSpot spot, _) =>
                                              spot.y,
                                          color: Colors.blueAccent,
                                          width: 3,
                                          markerSettings:
                                              const charts.MarkerSettings(
                                            isVisible: true,
                                            shape: charts.DataMarkerType.circle,
                                            color: Colors.blue,
                                          ),
                                          dataLabelSettings:
                                              const charts.DataLabelSettings(
                                                  isVisible: false),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    OutlinedButton(
                                      onPressed: () {
                                        timer?.cancel();
                                        Navigator.pop(context);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Colors.blueAccent, width: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cerrar',
                                        style:
                                            TextStyle(color: Colors.blueAccent),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ).then((_) => timer?.cancel());
                      },
                      icon: const Icon(
                        Icons.show_chart,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Gráfico ",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0166B3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildPorEtaComGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _tasComNotifier,
      builder: (context, porEtaCom, child) {
        if (porEtaCom == -1) {
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

        // Actualizar historial
        _historialTasaCombustible
            .add(FlSpot(_contadorTasaCombustible.toDouble(), porEtaCom));
        _contadorTasaCombustible++;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gauge
            Expanded(
              flex: 2,
              child: gauges.SfRadialGauge(
                axes: <gauges.RadialAxis>[
                  gauges.RadialAxis(
                    startAngle: 140,
                    endAngle: 40,
                    minimum: 1,
                    maximum: 20,
                    radiusFactor: 0.9,
                    majorTickStyle: const gauges.MajorTickStyle(
                      length: 10,
                      thickness: 2,
                      color: Colors.black,
                    ),
                    minorTicksPerInterval: 2,
                    minorTickStyle: const gauges.MinorTickStyle(
                      length: 5,
                      thickness: 1,
                      color: Colors.grey,
                    ),
                    axisLineStyle: const gauges.AxisLineStyle(
                      thickness: 12,
                      gradient: SweepGradient(
                        colors: [Colors.red, Colors.yellow, Colors.green],
                        stops: [0.3, 0.7, 1],
                      ),
                    ),
                    axisLabelStyle: const gauges.GaugeTextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    pointers: <gauges.GaugePointer>[
                      gauges.NeedlePointer(
                        value: porEtaCom.clamp(1, 20),
                        enableAnimation: true,
                        animationType: gauges.AnimationType.elasticOut,
                        needleColor: Colors.red,
                        needleStartWidth: 1,
                        needleEndWidth: 5,
                        needleLength: 0.75,
                        animationDuration: 1500,
                        gradient: const LinearGradient(
                          colors: [Colors.white, Colors.red],
                        ),
                        knobStyle: gauges.KnobStyle(
                          color: const Color(0xFF0166B3),
                          borderColor: const Color(0xFF709DCE).withAlpha(150),
                          borderWidth: 2,
                        ),
                      ),
                    ],
                    annotations: [
                      gauges.GaugeAnnotation(
                        widget: Column(
                          children: [
                            const SizedBox(height: 180),
                            Text(
                              "${porEtaCom.toStringAsFixed(1)} \nmg/combustión",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0),
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF014C94),
                                    blurRadius: 10,
                                    offset: const Offset(0, 0),
                                  )
                                ],
                              ),
                            ),
                            const Text(
                              "Tasa Combustible",
                              style: TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 0, 0, 0),
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
              ),
            ),

            // Panel informativo
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      height: 450,
                      width: 500,
                      alignment: Alignment.topLeft,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0166B3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información:',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                'Sensor de Tasa de Combustible\n\n'
                                'Mide la cantidad de combustible inyectado por ciclo de combustión.\n\n'
                                'Rangos normales:\n'
                                '• 1-5 mg: Ralentí.\n'
                                '• 5-10 mg: Conducción normal.\n'
                                '• 10-15 mg: Aceleración moderada.\n'
                                '• 15-20 mg: Aceleración fuerte.\n\n'
                                'Valores críticos:\n'
                                '• <1 mg: Posible obstrucción en inyectores.\n'
                                '• >20 mg: Exceso de combustible.\n\n'
                                'Unidad: mg/combustión.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.4,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black38,
                                      blurRadius: 2,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Timer? timer;

                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setStateDialog) {
                                timer ??= Timer.periodic(
                                  const Duration(seconds: 2),
                                  (_) => setStateDialog(() {}),
                                );

                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text(
                                    'Tasa combustible',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: SizedBox(
                                    width: 500,
                                    height: 400,
                                    child: charts.SfCartesianChart(
                                      backgroundColor: Colors.grey.shade100,
                                      primaryXAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'Tiempo'),
                                        interval: (_contadorTasaCombustible / 4)
                                            .ceilToDouble()
                                            .clamp(1, 100),
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      primaryYAxis: const charts.NumericAxis(
                                        title: charts.AxisTitle(
                                            text: 'mg/combustion'),
                                        minimum: 1,
                                        maximum: 20,
                                        interval: 2,
                                        majorGridLines:
                                            charts.MajorGridLines(width: 0.5),
                                      ),
                                      tooltipBehavior:
                                          charts.TooltipBehavior(enable: true),
                                      series: <charts
                                          .LineSeries<FlSpot, double>>[
                                        charts.LineSeries<FlSpot, double>(
                                          dataSource: _historialTasaCombustible,
                                          xValueMapper: (FlSpot spot, _) =>
                                              spot.x,
                                          yValueMapper: (FlSpot spot, _) =>
                                              spot.y,
                                          color: Colors.blueAccent,
                                          width: 3,
                                          markerSettings:
                                              const charts.MarkerSettings(
                                            isVisible: true,
                                            shape: charts.DataMarkerType.circle,
                                            color: Colors.blue,
                                          ),
                                          dataLabelSettings:
                                              const charts.DataLabelSettings(
                                                  isVisible: false),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    OutlinedButton(
                                      onPressed: () {
                                        timer?.cancel();
                                        Navigator.pop(context);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Colors.blueAccent, width: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cerrar',
                                        style:
                                            TextStyle(color: Colors.blueAccent),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ).then((_) => timer?.cancel());
                      },
                      icon: const Icon(
                        Icons.show_chart,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Gráfico ",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0166B3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildPresRielDirGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _ban1CComNotifier,
      builder: (context, presRielDir, child) {
        if (presRielDir == -11) {
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

        // Actualizar historial local
        _historialPresRielDir
            .add(FlSpot(_contadorPresRielDir.toDouble(), presRielDir));
        _contadorPresRielDir++;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gauge (mantenido exactamente igual)
            Expanded(
              flex: 2,
              child: gauges.SfRadialGauge(
                axes: <gauges.RadialAxis>[
                  gauges.RadialAxis(
                    startAngle: 140,
                    endAngle: 40,
                    minimum: -10,
                    maximum: 10,
                    radiusFactor: 0.9,
                    axisLineStyle: const gauges.AxisLineStyle(
                      thickness: 12,
                      gradient: SweepGradient(
                        colors: [Colors.red, Colors.yellow, Colors.green],
                        stops: [0.3, 0.7, 1],
                      ),
                    ),
                    axisLabelStyle: const gauges.GaugeTextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    pointers: <gauges.GaugePointer>[
                      gauges.NeedlePointer(
                        value: presRielDir.clamp(-10, 10),
                        enableAnimation: true,
                        animationType: gauges.AnimationType.elasticOut,
                        needleColor: Colors.red,
                        needleLength: 0.75,
                        animationDuration: 1500,
                        gradient: const LinearGradient(
                          colors: [Colors.white, Colors.red],
                        ),
                        knobStyle: gauges.KnobStyle(
                          color: const Color(0xFF0166B3),
                          borderColor: const Color(0xFF709DCE).withAlpha(150),
                          borderWidth: 2,
                        ),
                      ),
                    ],
                    annotations: [
                      gauges.GaugeAnnotation(
                        widget: Column(
                          children: [
                            const SizedBox(height: 180),
                            Text(
                              "${presRielDir.toStringAsFixed(0)} %",
                              style: const TextStyle(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0),
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF014C94),
                                    blurRadius: 10,
                                    offset: const Offset(0, 0),
                                  )
                                ],
                              ),
                            ),
                            const Text(
                              "Banco 1 - Corto",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        angle: 90,
                        positionFactor: 0.75,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Panel informativo y botón
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Panel informativo
                    Container(
                      padding: const EdgeInsets.all(16),
                      height: 450,
                      width: 500,
                      alignment: Alignment.topLeft,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0166B3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información:',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                'Sensor de Presión del Riel - Banco 1 (Corto)\n\n'
                                'Mide la presión del combustible en el riel de inyección.\n\n'
                                'Rangos normales:\n'
                                '• -10% a -5%: Presión baja.\n'
                                '• -5% a 5%: Rango óptimo.\n'
                                '• 5% a 10%: Presión alta.\n\n'
                                'Valores críticos:\n'
                                '• < -10%: Riesgo de fallo de inyección.\n'
                                '• > 10%: Riesgo de daño en componentes.\n\n'
                                'Unidad: % de variación respecto a presión nominal.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Timer? timer;

                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setStateDialog) {
                                timer ??= Timer.periodic(
                                  const Duration(seconds: 2),
                                  (_) => setStateDialog(() {}),
                                );

                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text(
                                    'Banco 1 - Corto',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: SizedBox(
                                    width: 500,
                                    height: 400,
                                    child: charts.SfCartesianChart(
                                      backgroundColor: Colors.grey.shade100,
                                      primaryXAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'Tiempo'),
                                        interval: (_contadorPresRielDir / 4)
                                            .ceilToDouble()
                                            .clamp(1, 100),
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      primaryYAxis: const charts.NumericAxis(
                                        title: charts.AxisTitle(text: '%'),
                                        minimum: -10,
                                        maximum: 10,
                                        interval: 2,
                                        majorGridLines:
                                            charts.MajorGridLines(width: 0.5),
                                      ),
                                      tooltipBehavior:
                                          charts.TooltipBehavior(enable: true),
                                      series: <charts
                                          .LineSeries<FlSpot, double>>[
                                        charts.LineSeries<FlSpot, double>(
                                          dataSource: _historialPresRielDir,
                                          xValueMapper: (FlSpot spot, _) =>
                                              spot.x,
                                          yValueMapper: (FlSpot spot, _) =>
                                              spot.y,
                                          color: Colors.blueAccent,
                                          width: 3,
                                          markerSettings:
                                              const charts.MarkerSettings(
                                            isVisible: true,
                                            shape: charts.DataMarkerType.circle,
                                            color: Colors.blue,
                                          ),
                                          dataLabelSettings:
                                              const charts.DataLabelSettings(
                                                  isVisible: false),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    OutlinedButton(
                                      onPressed: () {
                                        timer?.cancel();
                                        Navigator.pop(context);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Colors.blueAccent, width: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cerrar',
                                        style:
                                            TextStyle(color: Colors.blueAccent),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ).then((_) => timer?.cancel());
                      },
                      icon: const Icon(
                        Icons.show_chart,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Gráfico ",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0166B3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildPresRielRelGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _ban1LComNotifier,
      builder: (context, presRielRel, child) {
        if (presRielRel == -11) {
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

        // Actualizar historial local
        _historialPresRielRel
            .add(FlSpot(_contadorPresRielRel.toDouble(), presRielRel));
        _contadorPresRielRel++;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gauge (mantenido exactamente igual)
            Expanded(
              flex: 2,
              child: gauges.SfRadialGauge(
                axes: <gauges.RadialAxis>[
                  gauges.RadialAxis(
                    startAngle: 140,
                    endAngle: 40,
                    minimum: -10,
                    maximum: 10,
                    radiusFactor: 0.9,
                    axisLineStyle: const gauges.AxisLineStyle(
                      thickness: 12,
                      gradient: SweepGradient(
                        colors: [Colors.red, Colors.yellow, Colors.green],
                        stops: [0.3, 0.7, 1],
                      ),
                    ),
                    axisLabelStyle: const gauges.GaugeTextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    pointers: <gauges.GaugePointer>[
                      gauges.NeedlePointer(
                        value: presRielRel.clamp(-10, 10),
                        enableAnimation: true,
                        animationType: gauges.AnimationType.elasticOut,
                        needleColor: Colors.red,
                        needleLength: 0.75,
                        animationDuration: 1500,
                        gradient: const LinearGradient(
                          colors: [Colors.white, Colors.red],
                        ),
                        knobStyle: gauges.KnobStyle(
                          color: const Color(0xFF0166B3),
                          borderColor: const Color(0xFF709DCE).withAlpha(150),
                          borderWidth: 2,
                        ),
                      ),
                    ],
                    annotations: [
                      gauges.GaugeAnnotation(
                        widget: Column(
                          children: [
                            const SizedBox(height: 180),
                            Text(
                              "${presRielRel.toStringAsFixed(0)} %",
                              style: const TextStyle(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0),
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF014C94),
                                    blurRadius: 10,
                                    offset: const Offset(0, 0),
                                  )
                                ],
                              ),
                            ),
                            const Text(
                              "Banco 1 - Largo",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        angle: 90,
                        positionFactor: 0.75,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Panel informativo y botón
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Panel informativo
                    Container(
                      padding: const EdgeInsets.all(16),
                      height: 450,
                      width: 500,
                      alignment: Alignment.topLeft,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0166B3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información:',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                'Sensor de Presión del Riel - Banco 1 (Largo)\n\n'
                                'Mide la presión del combustible en el riel de inyección '
                                'para el banco largo del motor.\n\n'
                                'Rangos normales:\n'
                                '• -10% a -5%: Presión baja.\n'
                                '• -5% a 5%: Rango óptimo.\n'
                                '• 5% a 10%: Presión alta.\n\n'
                                'Comparación entre bancos:\n'
                                '• Diferencias > 2% entre bancos pueden indicar:\n'
                                '  - Desbalance en la bomba de combustible.\n'
                                '  - Filtro obstruido parcialmente.\n'
                                '  - Problemas en regulador de presión.\n\n'
                                'Unidad: % de variación respecto a presión nominal.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Botón para gráfico histórico
                    ElevatedButton.icon(
                      onPressed: () {
                        Timer? timer;

                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setStateDialog) {
                                timer ??= Timer.periodic(
                                  const Duration(seconds: 2),
                                  (_) => setStateDialog(() {}),
                                );

                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text(
                                    'Banco 1 - Largo',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: SizedBox(
                                    width: 500,
                                    height: 400,
                                    child: charts.SfCartesianChart(
                                      backgroundColor: Colors.grey.shade100,
                                      primaryXAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'Tiempo'),
                                        interval: (_contadorPresRielRel / 4)
                                            .ceilToDouble()
                                            .clamp(1, 100),
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      primaryYAxis: const charts.NumericAxis(
                                        title: charts.AxisTitle(text: '%'),
                                        minimum: -10,
                                        maximum: 10,
                                        interval: 2,
                                        majorGridLines:
                                            charts.MajorGridLines(width: 0.5),
                                      ),
                                      tooltipBehavior:
                                          charts.TooltipBehavior(enable: true),
                                      series: <charts
                                          .LineSeries<FlSpot, double>>[
                                        charts.LineSeries<FlSpot, double>(
                                          dataSource: _historialPresRielRel,
                                          xValueMapper: (FlSpot spot, _) =>
                                              spot.x,
                                          yValueMapper: (FlSpot spot, _) =>
                                              spot.y,
                                          color: Colors.blueAccent,
                                          width: 3,
                                          markerSettings:
                                              const charts.MarkerSettings(
                                            isVisible: true,
                                            shape: charts.DataMarkerType.circle,
                                            color: Colors.blue,
                                          ),
                                          dataLabelSettings:
                                              const charts.DataLabelSettings(
                                                  isVisible: false),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    OutlinedButton(
                                      onPressed: () {
                                        timer?.cancel();
                                        Navigator.pop(context);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Colors.blueAccent, width: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cerrar',
                                        style:
                                            TextStyle(color: Colors.blueAccent),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ).then((_) => timer?.cancel());
                      },
                      icon: const Icon(
                        Icons.show_chart,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Gráfico ",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0166B3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildPresBomComGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _ban2CComNotifier,
      builder: (context, presBomCom, child) {
        if (presBomCom == -11) {
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

        // Actualizar historial local
        _historialPresBomCom
            .add(FlSpot(_contadorPresBomCom.toDouble(), presBomCom));
        _contadorPresBomCom++;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gauge (mantenido exactamente igual)
            Expanded(
              flex: 2,
              child: gauges.SfRadialGauge(
                axes: <gauges.RadialAxis>[
                  gauges.RadialAxis(
                    startAngle: 140,
                    endAngle: 40,
                    minimum: -10,
                    maximum: 10,
                    radiusFactor: 0.9,
                    axisLineStyle: const gauges.AxisLineStyle(
                      thickness: 12,
                      gradient: SweepGradient(
                        colors: [Colors.red, Colors.yellow, Colors.green],
                        stops: [0.3, 0.7, 1],
                      ),
                    ),
                    axisLabelStyle: const gauges.GaugeTextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    pointers: <gauges.GaugePointer>[
                      gauges.NeedlePointer(
                        value: presBomCom.clamp(-10, 10),
                        enableAnimation: true,
                        animationType: gauges.AnimationType.elasticOut,
                        needleColor: Colors.red,
                        needleLength: 0.75,
                        animationDuration: 1500,
                        gradient: const LinearGradient(
                          colors: [Colors.white, Colors.red],
                        ),
                        knobStyle: gauges.KnobStyle(
                          color: const Color(0xFF0166B3),
                          borderColor: const Color(0xFF709DCE).withAlpha(150),
                          borderWidth: 2,
                        ),
                      ),
                    ],
                    annotations: [
                      gauges.GaugeAnnotation(
                        widget: Column(
                          children: [
                            const SizedBox(height: 180),
                            Text(
                              "${presBomCom.toStringAsFixed(0)} %",
                              style: const TextStyle(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0),
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF014C94),
                                    blurRadius: 10,
                                    offset: const Offset(0, 0),
                                  )
                                ],
                              ),
                            ),
                            const Text(
                              "Banco 2 - Corto",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        angle: 90,
                        positionFactor: 0.75,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Panel informativo y botón
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Panel informativo
                    Container(
                      padding: const EdgeInsets.all(16),
                      height: 450,
                      width: 500,
                      alignment: Alignment.topLeft,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0166B3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información:',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                'Sensor de Presión del Riel - Banco 2 (Corto)\n\n'
                                'Mide la presión del combustible en el riel de inyección '
                                'para el banco corto del motor (cilindros 2 y 4).\n\n'
                                'Rangos normales:\n'
                                '• -10% a -5%: Presión baja.\n'
                                '• -5% a 5%: Rango óptimo.\n'
                                '• 5% a 10%: Presión alta.\n\n'
                                'Diagnóstico comparativo:\n'
                                '• Diferencias > 3% con Banco 1 pueden indicar:\n'
                                '  - Problemas en la rampa de inyección.\n'
                                '  - Filtro de combustible parcialmente obstruido.\n'
                                '  - Fallo en sensor de presión.\n\n'
                                'Unidad: % de variación respecto a presión nominal.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Botón para gráfico histórico
                    ElevatedButton.icon(
                      onPressed: () {
                        Timer? timer;

                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setStateDialog) {
                                timer ??= Timer.periodic(
                                  const Duration(seconds: 2),
                                  (_) => setStateDialog(() {}),
                                );

                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text(
                                    'Banco 2 - Corto',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: SizedBox(
                                    width: 500,
                                    height: 400,
                                    child: charts.SfCartesianChart(
                                      backgroundColor: Colors.grey.shade100,
                                      primaryXAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'Tiempo'),
                                        interval: (_contadorPresBomCom / 4)
                                            .ceilToDouble()
                                            .clamp(1, 100),
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      primaryYAxis: const charts.NumericAxis(
                                        title: charts.AxisTitle(text: '%'),
                                        minimum: -10,
                                        maximum: 10,
                                        interval: 2,
                                        majorGridLines:
                                            charts.MajorGridLines(width: 0.5),
                                      ),
                                      tooltipBehavior:
                                          charts.TooltipBehavior(enable: true),
                                      series: <charts
                                          .LineSeries<FlSpot, double>>[
                                        charts.LineSeries<FlSpot, double>(
                                          dataSource: _historialPresBomCom,
                                          xValueMapper: (FlSpot spot, _) =>
                                              spot.x,
                                          yValueMapper: (FlSpot spot, _) =>
                                              spot.y,
                                          color: Colors.blueAccent,
                                          width: 3,
                                          markerSettings:
                                              const charts.MarkerSettings(
                                            isVisible: true,
                                            shape: charts.DataMarkerType.circle,
                                            color: Colors.blue,
                                          ),
                                          dataLabelSettings:
                                              const charts.DataLabelSettings(
                                                  isVisible: false),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    OutlinedButton(
                                      onPressed: () {
                                        timer?.cancel();
                                        Navigator.pop(context);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Colors.blueAccent, width: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cerrar',
                                        style:
                                            TextStyle(color: Colors.blueAccent),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ).then((_) => timer?.cancel());
                      },
                      icon: const Icon(
                        Icons.show_chart,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Gráfico ",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0166B3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildTipoComGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _ban2LComNotifier,
      builder: (context, tipoCom, child) {
        if (tipoCom == -11) {
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

        // Actualizar historial local
        _historialTipoCom.add(FlSpot(_contadorTipoCom.toDouble(), tipoCom));
        _contadorTipoCom++;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gauge (mantenido exactamente igual)
            Expanded(
              flex: 2,
              child: gauges.SfRadialGauge(
                axes: <gauges.RadialAxis>[
                  gauges.RadialAxis(
                    startAngle: 140,
                    endAngle: 40,
                    minimum: -10,
                    maximum: 10,
                    radiusFactor: 0.9,
                    axisLineStyle: const gauges.AxisLineStyle(
                      thickness: 12,
                      gradient: SweepGradient(
                        colors: [Colors.red, Colors.green, Colors.green],
                        stops: [0.3, 0.7, 1],
                      ),
                    ),
                    axisLabelStyle: const gauges.GaugeTextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    pointers: <gauges.GaugePointer>[
                      gauges.NeedlePointer(
                        value: tipoCom.clamp(-10, 10),
                        enableAnimation: true,
                        animationType: gauges.AnimationType.elasticOut,
                        needleColor: Colors.red,
                        needleLength: 0.75,
                        animationDuration: 1500,
                        gradient: const LinearGradient(
                          colors: [Colors.white, Colors.red],
                        ),
                        knobStyle: gauges.KnobStyle(
                          color: const Color(0xFF0166B3),
                          borderColor: const Color(0xFF709DCE).withAlpha(150),
                          borderWidth: 2,
                        ),
                      ),
                    ],
                    annotations: [
                      gauges.GaugeAnnotation(
                        widget: Column(
                          children: [
                            const SizedBox(height: 180),
                            Text(
                              "${tipoCom.toStringAsFixed(0)} %",
                              style: const TextStyle(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0),
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF014C94),
                                    blurRadius: 10,
                                    offset: const Offset(0, 0),
                                  )
                                ],
                              ),
                            ),
                            const Text(
                              "Banco 2 - Largo",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        angle: 90,
                        positionFactor: 0.75,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Panel informativo y botón
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Panel informativo
                    Container(
                      padding: const EdgeInsets.all(16),
                      height: 450,
                      width: 500,
                      alignment: Alignment.topLeft,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0166B3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información:',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                'Sensor de Tipo de Combustible - Banco 2 (Largo)\n\n'
                                'Mide las características del combustible en el riel '
                                'para el banco largo del motor (cilindros 1, 3 y 5).\n\n'
                                'Interpretación de valores:\n'
                                '• -10% a 0%: Combustible con baja densidad energética.\n'
                                '• 0% a 5%: Mezcla óptima.\n'
                                '• 5% a 10%: Alto contenido de aditivos.\n\n'
                                'Diagnóstico comparativo:\n'
                                '• Diferencias > 2% entre bancos indican:\n'
                                '  - Contaminación de combustible en un banco.\n'
                                '  - Problemas con el sensor de calidad.\n'
                                '  - Variaciones en la mezcla de aditivos.\n\n'
                                'Unidad: % de variación respecto al estándar.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Botón para gráfico histórico
                    ElevatedButton.icon(
                      onPressed: () {
                        Timer? timer;

                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setStateDialog) {
                                timer ??= Timer.periodic(
                                  const Duration(seconds: 2),
                                  (_) => setStateDialog(() {}),
                                );

                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text(
                                    'Banco 2 - Largo',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: SizedBox(
                                    width: 500,
                                    height: 400,
                                    child: charts.SfCartesianChart(
                                      backgroundColor: Colors.grey.shade100,
                                      primaryXAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'Tiempo'),
                                        interval: (_contadorTipoCom / 4)
                                            .ceilToDouble()
                                            .clamp(1, 100),
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      primaryYAxis: const charts.NumericAxis(
                                        title: charts.AxisTitle(text: '%'),
                                        minimum: -10,
                                        maximum: 10,
                                        interval: 2,
                                        majorGridLines:
                                            charts.MajorGridLines(width: 0.5),
                                      ),
                                      tooltipBehavior:
                                          charts.TooltipBehavior(enable: true),
                                      series: <charts
                                          .LineSeries<FlSpot, double>>[
                                        charts.LineSeries<FlSpot, double>(
                                          dataSource: _historialTipoCom,
                                          xValueMapper: (FlSpot spot, _) =>
                                              spot.x,
                                          yValueMapper: (FlSpot spot, _) =>
                                              spot.y,
                                          color: Colors.blueAccent,
                                          width: 3,
                                          markerSettings:
                                              const charts.MarkerSettings(
                                            isVisible: true,
                                            shape: charts.DataMarkerType.circle,
                                            color: Colors.blue,
                                          ),
                                          dataLabelSettings:
                                              const charts.DataLabelSettings(
                                                  isVisible: false),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    OutlinedButton(
                                      onPressed: () {
                                        timer?.cancel();
                                        Navigator.pop(context);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Colors.blueAccent, width: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cerrar',
                                        style:
                                            TextStyle(color: Colors.blueAccent),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ).then((_) => timer?.cancel());
                      },
                      icon: const Icon(
                        Icons.show_chart,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Gráfico ",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0166B3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFF0166B3),
        centerTitle: true,
        title: const Text(
          "Dashboard - Combustible",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            // DropdownButton para seleccionar métrica
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color.fromARGB(255, 9, 181, 204),
                      width: 4), // Borde azul
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF709DCE),
                      blurRadius: 4,
                      offset: Offset(2, 2), // Sombra ligera
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: selectedMetric,
                  items: <String>[
                    'Nivel de combustible',
                    'Presión combustible',
                    'Presión riel',
                    'Tasa combustible',
                    'Banco 1 - Corto',
                    'Banco 1 - Largo',
                    'Banco 2 - Corto',
                    'Banco 2 - Largo',
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
                      selectedMetric = newValue!;
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
            Expanded(
              child: Center(
                child: buildGauge(), // Mostrar gauge basado en selección
              ),
            ),
          ],
        ),
      ),
    );
  }
}
