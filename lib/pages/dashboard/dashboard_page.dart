import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:obdv2/pages/dashboard/home_dash.dart';
import 'package:obdv2/pages/home_page.dart';

import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;
import 'package:syncfusion_flutter_charts/charts.dart' as charts;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:async';

final Color colorPrimary = Color(0xFF007AFF); // Azul principal

class SpeedometerPage extends StatefulWidget {
  final User user; // <-- Agrega esto

  const SpeedometerPage({required this.user, Key? key}) : super(key: key);

  @override
  State<SpeedometerPage> createState() => _SpeedometerPageState();
}

//CONTADORES PARA LOS GRAFICOS

List<FlSpot> _historialAvance = [];
int _contador = 0;

final List<FlSpot> _historialCargaMotor = [];
int _contadorCarga = 0;

final List<FlSpot> _historialFlujoAire = [];
int _contadorFlujoAire = 0;

final List<FlSpot> _historialPresionAdmision = [];
int _contadorPresionAdm = 0;

final List<FlSpot> _historialRPM = [];
int _contadorRPM = 0;

final List<FlSpot> _historialTempRef = [];
int _contadorTempRef = 0;

final List<FlSpot> _historialVelocidad = [];
int _contadorVelocidad = 0;

final List<FlSpot> _historialVoltaje = [];
int _contadorVoltaje = 0;

/////////////////////////////////////

class _SpeedometerPageState extends State<SpeedometerPage> {
  final ValueNotifier<double> _avanceEnNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _cargaMotorNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _cargaInComNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _flujoAirComNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _presColAdmiNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _rpmNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _tempRefNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _velocidadNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _voltajeNotifier = ValueNotifier(0.0);

  String selectedMetric = "Avance encendido";
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
        .child('SensoresMotor/Avance encendido')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _avanceEnNotifier.value = -11;
        } else {
          final avanen = double.tryParse(data.toString()) ?? 0.0;
          _avanceEnNotifier.value = avanen;
        }
      }
    });

    _databaseRef.child('SensoresMotor/Carga del motor').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _cargaMotorNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final carmotor = double.tryParse(data.toString()) ?? 0.0;
          _cargaMotorNotifier.value = carmotor;
        }
      }
    });

    _databaseRef
        .child('SensoresMotor/Flujo aire masivo')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _flujoAirComNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final flujoair = double.tryParse(data.toString()) ?? 0.0;
          _flujoAirComNotifier.value = flujoair;
        }
      }
    });

    _databaseRef
        .child('SensoresMotor/Presión colector admisión')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _presColAdmiNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final prescoladm = double.tryParse(data.toString()) ?? 0.0;
          _presColAdmiNotifier.value = prescoladm;
        }
      }
    });

    _databaseRef.child('/SensoresMotor/RPM').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _rpmNotifier.value = -1; // Valor especial para indicar "No soportado"
        } else {
          final rpm = double.tryParse(data.toString()) ?? 0.0;
          _rpmNotifier.value = rpm;
        }
      }
    });

    _databaseRef.child('SensoresMotor/TempRef').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _tempRefNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final tempref = double.tryParse(data.toString()) ?? 0.0;
          _tempRefNotifier.value = tempref;
        }
      }
    });

    _databaseRef.child('SensoresMotor/Velocidad').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _velocidadNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final velocidad = double.tryParse(data.toString()) ?? 0.0;
          _velocidadNotifier.value = velocidad;
        }
      }
    });

    _databaseRef.child('SensoresMotor/Voltaje').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _voltajeNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final voltaje = double.tryParse(data.toString()) ?? 0.0;
          _voltajeNotifier.value = voltaje;
        }
      }
    });
  }

  Widget buildGauge() {
    switch (selectedMetric) {
      case 'Carga del motor':
        return buildCargamotorGauge();
      case 'Flujo aire masivo':
        return buildFAMGauge();
      case 'Presión colector admisión':
        return buildPresColAdmGauge();
      case 'RPM':
        return buildRpmGauge();
      case 'Temperatura refrigerante':
        return buildTempRefGauge();
      case 'Velocidad':
        return buildSpeedGauge();
      case 'Voltaje':
        return buildVoltajeGauge();
      default:
        return buildAEGauge();
    }
  }

  Widget buildAEGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _avanceEnNotifier,
      builder: (context, avanen, child) {
        if (avanen < -10) {
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

        _historialAvance.add(FlSpot(_contador.toDouble(), avanen));
        _contador++;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gauge intacto
            Expanded(
              flex: 2,
              child: gauges.SfRadialGauge(
                axes: <gauges.RadialAxis>[
                  gauges.RadialAxis(
                    startAngle: 140,
                    endAngle: 40,
                    minimum: -10,
                    maximum: 40,
                    radiusFactor: 0.9,
                    axisLabelStyle: const gauges.GaugeTextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    axisLineStyle: const gauges.AxisLineStyle(
                      thickness: 12,
                      gradient: SweepGradient(
                        colors: [Colors.red, Colors.yellow, Colors.green],
                        stops: [0.0, 0.3, 1],
                      ),
                    ),
                    pointers: <gauges.GaugePointer>[
                      gauges.NeedlePointer(
                        value: avanen.clamp(-10, 40),
                        enableAnimation: true,
                        animationType: gauges.AnimationType.elasticOut,
                        needleColor: Color.fromARGB(255, 255, 17, 0),
                        needleLength: 0.75,
                        animationDuration: 1500,
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
                              "${avanen.toStringAsFixed(2)}°",
                              style: const TextStyle(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255),
                                shadows: [
                                  Shadow(color: Colors.white, blurRadius: 20)
                                ],
                              ),
                            ),
                            const Text(
                              "Avance de Encendido",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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
            // Panel informativo mejorado
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: 500, // Ancho fijo
                      height: 450, // Alto fijo
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFF202020),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información:',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Sensor de Avance del Encendido. \n'
                              'Determina el momento óptimo para que salte la chispa en los cilindros, antes de que el pistón alcance el punto muerto superior. \n'
                              'Un avance correcto mejora la eficiencia y reduce el consumo. Un avance excesivo puede causar "picado" del motor, mientras que uno insuficiente reduce el rendimiento. \n\n'
                              'Rango de Valores: \n'
                              '-10° (retraso) – 40° (avance)',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(221, 255, 255, 255),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            Timer? timer;
                            return StatefulBuilder(
                              builder: (context, setStateDialog) {
                                // Inicia el Timer dentro del builder
                                timer ??= Timer.periodic(
                                    const Duration(seconds: 2), (_) {
                                  if (Navigator.of(context).canPop()) {
                                    setStateDialog(
                                        () {}); // Redibuja el gráfico
                                  }
                                });

                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text(
                                    'Gráfico de avance',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: SizedBox(
                                    height: 450,
                                    width: 500,
                                    child: charts.SfCartesianChart(
                                      backgroundColor: Colors.white,
                                      plotAreaBorderWidth: 1,
                                      primaryXAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'Tiempo'),
                                        interval:
                                            (_contador / 4).ceilToDouble(),
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      primaryYAxis: const charts.NumericAxis(
                                        title: charts.AxisTitle(
                                            text: 'Avance (°)'),
                                        interval: 10,
                                        minimum: -10,
                                        maximum: 40,
                                        majorGridLines:
                                            charts.MajorGridLines(width: 0.5),
                                      ),
                                      tooltipBehavior:
                                          charts.TooltipBehavior(enable: true),
                                      series: <charts
                                          .LineSeries<FlSpot, double>>[
                                        charts.LineSeries<FlSpot, double>(
                                          dataSource: _historialAvance,
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
                                        timer
                                            ?.cancel(); // Cancela el timer al cerrar
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
                        );
                      },
                      icon: const Icon(Icons.show_chart),
                      label: const Text(
                        "Gráfico",
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(160, 60),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildCargamotorGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _cargaMotorNotifier,
      builder: (context, carmotor, child) {
        if (carmotor == -1) {
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

        _historialCargaMotor.add(FlSpot(_contadorCarga.toDouble(), carmotor));
        _contadorCarga++;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gauge intacto
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
                        colors: [
                          Colors.green,
                          Colors.yellow,
                          Colors.orange,
                          Colors.red,
                        ],
                        stops: [0.25, 0.5, 0.75, 1],
                      ),
                    ),
                    axisLabelStyle: const gauges.GaugeTextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold),
                    pointers: <gauges.GaugePointer>[
                      gauges.NeedlePointer(
                        value: carmotor.clamp(0, 100),
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
                          color: const Color(0xFF3F3F3F),
                          borderColor: const Color(0xFF3F3F3F).withAlpha(150),
                          borderWidth: 2,
                        ),
                      ),
                    ],
                    ranges: [
                      gauges.GaugeRange(
                        startValue: 0,
                        endValue: 25,
                        color: Colors.green,
                        startWidth: 15,
                        endWidth: 15,
                      ),
                      gauges.GaugeRange(
                        startValue: 25,
                        endValue: 50,
                        color: Colors.yellow,
                        startWidth: 15,
                        endWidth: 15,
                      ),
                      gauges.GaugeRange(
                        startValue: 50,
                        endValue: 75,
                        color: Colors.orange,
                        startWidth: 15,
                        endWidth: 15,
                      ),
                      gauges.GaugeRange(
                        startValue: 75,
                        endValue: 100,
                        color: Colors.red,
                        startWidth: 15,
                        endWidth: 15,
                      ),
                    ],
                    annotations: [
                      gauges.GaugeAnnotation(
                        widget: Column(
                          children: [
                            const SizedBox(height: 180),
                            Text(
                              "${carmotor.toStringAsFixed(2)} %",
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
                            const Text(
                              "Carga del Motor",
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
              ),
            ),
            // Panel informativo mejorado
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: 500,
                      height: 450,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFF202020),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const SingleChildScrollView(
                        physics: BouncingScrollPhysics(), // Efecto de rebote
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información:',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                                height:
                                    10), // Espaciado entre el título y el contenido
                            Text(
                              'Sensor de Carga del Motor. \n'
                              'Indica el porcentaje de carga que está soportando el motor en relación a su capacidad máxima. \n'
                              'Una carga óptima (20-70%) mejora la eficiencia del combustible. Cargas muy bajas (0-20%) pueden indicar conducción ineficiente, mientras que cargas altas (70-100%) pueden reducir la vida útil del motor si se mantienen por periodos prolongados. \n\n'
                              'Rango de Valores: \n'
                              '0% (mínima carga) – 100% (carga máxima)',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(221, 255, 255, 255),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
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
                                // Timer que actualiza cada 2 segundos mientras el diálogo está activo
                                timer ??= Timer.periodic(
                                    const Duration(seconds: 2), (_) {
                                  if (context.mounted) {
                                    setStateDialog(() {});
                                  }
                                });

                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text(
                                    'Gráfico de carga del motor',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: SizedBox(
                                    height: 450,
                                    width: 500,
                                    child: charts.SfCartesianChart(
                                      backgroundColor: Colors.white,
                                      plotAreaBorderWidth: 1,
                                      primaryXAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'Tiempo'),
                                        interval:
                                            (_contadorCarga / 4).ceilToDouble(),
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      primaryYAxis: charts.NumericAxis(
                                        title:
                                            charts.AxisTitle(text: 'Carga (%)'),
                                        interval: 20,
                                        minimum: 0,
                                        maximum: 100,
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      tooltipBehavior:
                                          charts.TooltipBehavior(enable: true),
                                      series: <charts.LineSeries>[
                                        charts.LineSeries<FlSpot, double>(
                                          dataSource: _historialCargaMotor,
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
                                        timer
                                            ?.cancel(); // Detener el timer al cerrar
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
                        ).then((_) {
                          timer
                              ?.cancel(); // Asegurar cancelación al cerrar el diálogo
                        });
                      },
                      icon: const Icon(Icons.show_chart),
                      label: const Text(
                        "Gráfico",
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(160, 60),
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

  Widget buildFAMGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _flujoAirComNotifier,
      builder: (context, flujoair, child) {
        if (flujoair == -1) {
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

        // Actualizar el historial
        _historialFlujoAire
            .add(FlSpot(_contadorFlujoAire.toDouble(), flujoair));
        _contadorFlujoAire++;

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
                    minimum: 2,
                    maximum: 20,
                    radiusFactor: 0.9,
                    axisLabelStyle: const gauges.GaugeTextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    axisLineStyle: const gauges.AxisLineStyle(
                      thickness: 12,
                      gradient: SweepGradient(
                        colors: [Colors.red, Colors.yellow, Colors.green],
                        stops: [0.0, 0.3, 1],
                      ),
                    ),
                    pointers: <gauges.GaugePointer>[
                      gauges.NeedlePointer(
                        value: flujoair.clamp(2, 20),
                        enableAnimation: true,
                        animationType: gauges.AnimationType.elasticOut,
                        needleColor: Colors.red,
                        needleLength: 0.75,
                        animationDuration: 1500,
                        gradient: const LinearGradient(
                          colors: [Colors.white, Colors.red],
                        ),
                        knobStyle: gauges.KnobStyle(
                          color: const Color(0xFF3F3F3F),
                          borderColor: const Color(0xFF3F3F3F).withAlpha(150),
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
                              "${flujoair.toStringAsFixed(2)} g/s",
                              style: const TextStyle(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255),
                                shadows: [
                                  Shadow(color: Colors.white, blurRadius: 20)
                                ],
                              ),
                            ),
                            const Text(
                              "Flujo aire masivo",
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
                      ),
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
                      width: 500,
                      height: 450,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFF202020),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información:',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Sensor de Flujo de Aire Masivo (MAF). \n'
                              'Mide la cantidad de aire que entra al motor para calcular la mezcla óptima de combustible. \n'
                              'Valores bajos pueden indicar obstrucciones en el sistema de admisión, mientras que valores altos pueden señalar fugas de aire. \n\n'
                              'Rango típico: \n'
                              '2–20 g/s (gramos por segundo)',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(221, 255, 255, 255),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        charts.TooltipBehavior tooltip =
                            charts.TooltipBehavior(enable: true);
                        Timer? timer;

                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setStateDialog) {
                                // Timer para refrescar el gráfico cada 2 segundos
                                timer ??= Timer.periodic(
                                    const Duration(seconds: 2), (_) {
                                  if (context.mounted) {
                                    setStateDialog(
                                        () {}); // Refresca el gráfico
                                  }
                                });

                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text(
                                    'Gráfico de flujo de aire',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: SizedBox(
                                    height: 450,
                                    width: 500,
                                    child: charts.SfCartesianChart(
                                      backgroundColor: Colors.white,
                                      tooltipBehavior: tooltip,
                                      primaryXAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'Tiempo'),
                                        interval: (_contadorFlujoAire / 4)
                                            .ceilToDouble(),
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      primaryYAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(
                                            text: 'Flujo (g/s)'),
                                        interval: 2,
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      series: <charts
                                          .LineSeries<FlSpot, double>>[
                                        charts.LineSeries<FlSpot, double>(
                                          dataSource: _historialFlujoAire,
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
                                        timer
                                            ?.cancel(); // Detener timer al cerrar
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
                        ).then((_) {
                          timer?.cancel(); // Asegurarse de cancelar al salir
                        });
                      },
                      icon: const Icon(Icons.show_chart),
                      label: const Text(
                        "Gráfico",
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(160, 60),
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

  Widget buildPresColAdmGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _presColAdmiNotifier,
      builder: (context, prescoladm, child) {
        if (prescoladm == -1) {
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

        // Actualizar el historial
        _historialPresionAdmision
            .add(FlSpot(_contadorPresionAdm.toDouble(), prescoladm));
        _contadorPresionAdm++;

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
                    minimum: 20,
                    maximum: 250,
                    radiusFactor: 0.9,
                    axisLabelStyle: const gauges.GaugeTextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    axisLineStyle: const gauges.AxisLineStyle(
                      thickness: 12,
                      gradient: SweepGradient(
                        colors: [Colors.red, Colors.yellow, Colors.green],
                        stops: [0.0, 0.043, 1],
                      ),
                    ),
                    pointers: <gauges.GaugePointer>[
                      gauges.NeedlePointer(
                        value: prescoladm.clamp(20, 250),
                        enableAnimation: true,
                        animationType: gauges.AnimationType.elasticOut,
                        needleColor: Colors.red,
                        needleLength: 0.75,
                        animationDuration: 1500,
                        gradient: const LinearGradient(
                          colors: [Colors.white, Colors.red],
                        ),
                        knobStyle: gauges.KnobStyle(
                          color: const Color(0xFF3F3F3F),
                          borderColor: const Color(0xFF3F3F3F).withAlpha(150),
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
                              "${prescoladm.toStringAsFixed(2)} kPa",
                              style: const TextStyle(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255),
                                shadows: [
                                  Shadow(color: Colors.white, blurRadius: 20)
                                ],
                              ),
                            ),
                            const Text(
                              "Presión Colector Admisión",
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
                      ),
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
                      width: 500,
                      height: 450,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFF202020),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información:',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Sensor MAP (Presión Absoluta del Colector). \n'
                              'Mide la presión de aire en el colector de admisión para determinar la cantidad de aire que entra al motor. \n\n'
                              'Valores normales:\n'
                              '- Motor en ralentí: 20-50 kPa\n'
                              '- Aceleración máxima: hasta 250 kPa (en motores turbo)\n'
                              '- Motor apagado: ≈100 kPa (presión atmosférica)\n\n'
                              'Valores bajos pueden indicar fugas de vacío, mientras que valores altos pueden señalar problemas con el turbocompresor o restricciones en el sistema de escape.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(221, 255, 255, 255),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
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
                                    'Gráfico de presión',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: SizedBox(
                                    height: 450,
                                    width: 500,
                                    child: charts.SfCartesianChart(
                                      backgroundColor: Colors.white,
                                      plotAreaBorderWidth: 1,
                                      primaryXAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'Tiempo'),
                                        interval: (_contadorPresionAdm / 4)
                                            .ceilToDouble(),
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      primaryYAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(
                                            text: 'Presión (kPa)'),
                                        interval: 50,
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      tooltipBehavior:
                                          charts.TooltipBehavior(enable: true),
                                      series: <charts
                                          .LineSeries<FlSpot, double>>[
                                        charts.LineSeries<FlSpot, double>(
                                          dataSource: _historialPresionAdmision,
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
                                        timer
                                            ?.cancel(); // Cancelar el timer al cerrar
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
                        ).then((_) => timer
                            ?.cancel()); // Cancelar si el diálogo se cierra por otros medios
                      },
                      icon: const Icon(Icons.show_chart),
                      label: const Text(
                        "Gráfico",
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(160, 60),
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

  Widget buildRpmGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _rpmNotifier,
      builder: (context, rpm, child) {
        if (rpm == -1) {
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

        // Actualizar el historial
        _historialRPM.add(FlSpot(_contadorRPM.toDouble(), rpm));
        _contadorRPM++;

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
                    maximum: 8000,
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
                        colors: [
                          Colors.green,
                          Colors.yellow,
                          Colors.orange,
                          Colors.red,
                        ],
                        stops: [0.25, 0.5, 0.75, 1],
                      ),
                    ),
                    axisLabelStyle: const gauges.GaugeTextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    pointers: <gauges.GaugePointer>[
                      gauges.NeedlePointer(
                        value: rpm.clamp(0, 8000),
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
                          color: const Color(0xFF3F3F3F),
                          borderColor: const Color(0xFF3F3F3F).withAlpha(150),
                          borderWidth: 2,
                        ),
                      ),
                    ],
                    ranges: [
                      gauges.GaugeRange(
                        startValue: 0,
                        endValue: 2000,
                        color: Colors.green,
                        startWidth: 15,
                        endWidth: 15,
                      ),
                      gauges.GaugeRange(
                        startValue: 2000,
                        endValue: 5000,
                        color: Colors.yellow,
                        startWidth: 15,
                        endWidth: 15,
                      ),
                      gauges.GaugeRange(
                        startValue: 5000,
                        endValue: 7000,
                        color: Colors.orange,
                        startWidth: 15,
                        endWidth: 15,
                      ),
                      gauges.GaugeRange(
                        startValue: 7000,
                        endValue: 8000,
                        color: Colors.red,
                        startWidth: 15,
                        endWidth: 15,
                      ),
                    ],
                    annotations: [
                      gauges.GaugeAnnotation(
                        widget: Column(
                          children: [
                            const SizedBox(height: 180),
                            Text(
                              "${rpm.toStringAsFixed(0)} RPM",
                              style: const TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255),
                                shadows: [
                                  Shadow(color: Colors.white, blurRadius: 20)
                                ],
                              ),
                            ),
                            const Text(
                              "Revoluciones por minuto",
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
                      ),
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
                      width: 500,
                      height: 450,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFF202020),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información:',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Sensor de RPM (Revoluciones Por Minuto). \n'
                              'Mide la velocidad de rotación del cigüeñal del motor. \n\n'
                              'Rangos típicos:\n'
                              '- Ralentí: 600-1000 RPM (motor caliente)\n'
                              '- Conducción normal: 1500-3000 RPM\n'
                              '- Aceleración fuerte: 3000-5000 RPM\n'
                              '- Límite máximo: Depende del motor (generalmente 6000-8000 RPM)\n\n'
                              'Valores anormales:\n'
                              '- RPM muy altas en ralentí: Problemas con el regulador\n'
                              '- RPM fluctuantes: Posibles fallos en el sistema de admisión o encendido\n'
                              '- RPM bajas o irregulares: Problemas con las bujías, inyectores o compresión',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(221, 255, 255, 255),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
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
                                    'Gráfico de RPM',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: SizedBox(
                                    height: 450,
                                    width: 500,
                                    child: charts.SfCartesianChart(
                                      backgroundColor: Colors.white,
                                      plotAreaBorderWidth: 1,
                                      primaryXAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'Tiempo'),
                                        interval:
                                            (_contadorRPM / 4).ceilToDouble(),
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      primaryYAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'RPM'),
                                        interval: 1000,
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      tooltipBehavior:
                                          charts.TooltipBehavior(enable: true),
                                      series: <charts
                                          .LineSeries<FlSpot, double>>[
                                        charts.LineSeries<FlSpot, double>(
                                          dataSource: _historialRPM,
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
                                        timer
                                            ?.cancel(); // Cancelar el timer al cerrar
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
                        ).then((_) =>
                            timer?.cancel()); // Por si se cierra de otra forma
                      },
                      icon: const Icon(Icons.show_chart),
                      label: const Text(
                        "Gráfico",
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(160, 60),
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

  Widget buildTempRefGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _tempRefNotifier,
      builder: (context, tempref, child) {
        if (tempref == -1) {
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

        // Actualizar el historial
        _historialTempRef.add(FlSpot(_contadorTempRef.toDouble(), tempref));
        _contadorTempRef++;

        // Parámetros de rango
        const double min = 40;
        const double max = 150;
        final double range = max - min;

        double stop(double value) => (value - min) / range;

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
                    minimum: min,
                    maximum: max,
                    radiusFactor: 0.9,
                    axisLabelStyle: const gauges.GaugeTextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    axisLineStyle: gauges.AxisLineStyle(
                      thickness: 12,
                      gradient: SweepGradient(
                        colors: [
                          Colors.red, // <70
                          Colors.yellow, // 70-89
                          Colors.green, // 90-100 (óptimo)
                          Colors.yellow, // 101-105
                          Colors.red // >105
                        ],
                        stops: [
                          stop(70), // fin rojo bajo
                          stop(89), // fin amarillo bajo
                          stop(100), // fin verde
                          stop(105), // fin amarillo alto
                          1.0 // fin rojo alto
                        ],
                      ),
                    ),
                    pointers: <gauges.GaugePointer>[
                      gauges.NeedlePointer(
                        value: tempref.clamp(min, max),
                        enableAnimation: true,
                        animationType: gauges.AnimationType.elasticOut,
                        needleColor: Colors.red,
                        needleLength: 0.75,
                        animationDuration: 1500,
                        gradient: const LinearGradient(
                          colors: [Colors.white, Colors.red],
                        ),
                        knobStyle: gauges.KnobStyle(
                          color: const Color(0xFF3F3F3F),
                          borderColor: const Color(0xFF3F3F3F).withAlpha(150),
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
                              "${tempref.toStringAsFixed(1)}°C",
                              style: const TextStyle(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255),
                                shadows: [
                                  Shadow(color: Colors.white, blurRadius: 20)
                                ],
                              ),
                            ),
                            const Text(
                              "Temperatura refrigerante",
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
                      ),
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
                      width: 500,
                      height: 450,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFF202020),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información:',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Sensor de Temperatura del Refrigerante. \nMide la temperatura del líquido refrigerante que circula por el motor.\n\n'
                              'Rangos normales:\n'
                              '- Motor frío: 40-70°C\n'
                              '- Temperatura óptima: 90-100°C\n'
                              '- Sobrecalentamiento: >105°C\n\n'
                              'Importancia:\n'
                              '- Temperaturas bajas aumentan el consumo\n'
                              '- Temperaturas altas pueden dañar el motor\n'
                              '- El termostato regula la temperatura ideal\n\n'
                              'Problemas comunes:\n'
                              '- Sensor defectuoso\n'
                              '- Termostato atascado\n'
                              '- Bajo nivel de refrigerante\n'
                              '- Fallo en el ventilador',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(221, 255, 255, 255),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
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
                                    'Gráfico de temperatura',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: SizedBox(
                                    height: 450,
                                    width: 500,
                                    child: charts.SfCartesianChart(
                                      backgroundColor: Colors.white,
                                      plotAreaBorderWidth: 1,
                                      primaryXAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'Tiempo'),
                                        interval: (_contadorTempRef / 4)
                                            .ceilToDouble(),
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      primaryYAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: '°C'),
                                        interval: 20,
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      tooltipBehavior:
                                          charts.TooltipBehavior(enable: true),
                                      series: <charts
                                          .LineSeries<FlSpot, double>>[
                                        charts.LineSeries<FlSpot, double>(
                                          dataSource: _historialTempRef,
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
                      icon: const Icon(Icons.show_chart),
                      label: const Text(
                        "Gráfico",
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(160, 60),
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

  Widget buildSpeedGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _velocidadNotifier,
      builder: (context, velocidad, child) {
        if (velocidad == -1) {
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

        // Actualizar el historial
        _historialVelocidad
            .add(FlSpot(_contadorVelocidad.toDouble(), velocidad));
        _contadorVelocidad++;

        const double min = 0;
        const double max = 240;
        double stop(double value) => value / max;

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
                    minimum: min,
                    maximum: max,
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
                    axisLineStyle: gauges.AxisLineStyle(
                      thickness: 15,
                      gradient: SweepGradient(
                        colors: [
                          Colors.pink, // 0-30 km/h
                          Colors.green, // 30-80 km/h
                          Colors.amber, // 80-160 km/h
                          Colors.red, // 160-240 km/h
                        ],
                        stops: [
                          stop(30),
                          stop(80),
                          stop(160),
                          1.0,
                        ],
                      ),
                    ),
                    axisLabelStyle: const gauges.GaugeTextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    pointers: <gauges.GaugePointer>[
                      gauges.NeedlePointer(
                        value: velocidad.clamp(min, max),
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
                          color: const Color(0xFF3F3F3F),
                          borderColor: const Color(0xFF3F3F3F).withAlpha(150),
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
                              "${velocidad.toStringAsFixed(0)} km/h",
                              style: const TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255),
                                shadows: [
                                  Shadow(color: Colors.white, blurRadius: 20)
                                ],
                              ),
                            ),
                            const Text(
                              "Velocidad",
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
                      ),
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
                      width: 500,
                      height: 450,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFF202020),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información:',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Velocímetro Digital\n\n'
                              'Muestra la velocidad actual del vehículo en kilómetros por hora.\n\n'
                              'Rangos de color:\n'
                              '• 0-30 km/h: Rosa (baja velocidad)\n'
                              '• 30-80 km/h: Verde (velocidad urbana)\n'
                              '• 80-160 km/h: Ámbar (carretera)\n'
                              '• 160-240 km/h: Rojo (alta velocidad)\n\n'
                              'Precisión: ±1 km/h\n'
                              'Rango máximo: 240 km/h',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(221, 255, 255, 255),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
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
                                    'Gráfico de velocidad',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: SizedBox(
                                    height: 450,
                                    width: 500,
                                    child: charts.SfCartesianChart(
                                      backgroundColor: Colors.white,
                                      plotAreaBorderWidth: 1,
                                      primaryXAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'Tiempo'),
                                        interval: (_contadorVelocidad / 4)
                                            .ceilToDouble(),
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      primaryYAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'km/h'),
                                        interval: 40,
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      tooltipBehavior:
                                          charts.TooltipBehavior(enable: true),
                                      series: <charts
                                          .LineSeries<FlSpot, double>>[
                                        charts.LineSeries<FlSpot, double>(
                                          dataSource: _historialVelocidad,
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
                      icon: const Icon(Icons.show_chart),
                      label: const Text(
                        "Gráfico",
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(160, 60),
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

  Widget buildVoltajeGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _voltajeNotifier,
      builder: (context, voltaje, child) {
        if (voltaje == -1) {
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

        // Actualizar el historial
        _historialVoltaje.add(FlSpot(_contadorVoltaje.toDouble(), voltaje));
        _contadorVoltaje++;

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
                    minimum: 6,
                    maximum: 20,
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
                        colors: [
                          Colors.red,
                          Colors.green,
                          Colors.red,
                        ],
                        stops: [0.0, 0.55, 1.0],
                      ),
                    ),
                    axisLabelStyle: const gauges.GaugeTextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    pointers: <gauges.GaugePointer>[
                      gauges.NeedlePointer(
                        value: voltaje.clamp(6, 20),
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
                          color: const Color(0xFF3F3F3F),
                          borderColor: const Color(0xFF3F3F3F).withAlpha(150),
                          borderWidth: 2,
                        ),
                      ),
                    ],
                    ranges: [
                      gauges.GaugeRange(
                        startValue: 6,
                        endValue: 11,
                        color: Colors.red,
                        startWidth: 15,
                        endWidth: 15,
                        label: 'Bajo',
                        labelStyle: const gauges.GaugeTextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      gauges.GaugeRange(
                        startValue: 11,
                        endValue: 15,
                        color: Colors.green,
                        startWidth: 15,
                        endWidth: 15,
                        label: 'Óptimo',
                        labelStyle: const gauges.GaugeTextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      gauges.GaugeRange(
                        startValue: 15,
                        endValue: 20,
                        color: Colors.red,
                        startWidth: 15,
                        endWidth: 15,
                        label: 'Alto',
                        labelStyle: const gauges.GaugeTextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                    annotations: [
                      gauges.GaugeAnnotation(
                        widget: Column(
                          children: [
                            const SizedBox(height: 180),
                            Text(
                              "${voltaje.toStringAsFixed(2)} V",
                              style: const TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255),
                                shadows: [
                                  Shadow(color: Colors.white, blurRadius: 20)
                                ],
                              ),
                            ),
                            const Text(
                              "Voltaje Batería",
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
                      ),
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
                      width: 500,
                      height: 450,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF202020),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Información:',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Medidor de Voltaje del Sistema\n\n'
                                'Muestra el voltaje actual de la batería y sistema eléctrico.\n\n'
                                'Rangos normales:\n'
                                '• 11-15V: Operación normal\n'
                                '• <11V: Batería descargándose\n'
                                '• >15V: Sobrecarga (alternador)\n\n'
                                'Valores típicos:\n'
                                '- Motor apagado: 12.6V\n'
                                '- Motor en marcha: 13.5-14.5V\n'
                                '- Con carga eléctrica: 12.8-13.8V',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(221, 255, 255, 255),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        ),
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
                                    'Gráfico de voltaje',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: SizedBox(
                                    height: 450,
                                    width: 500,
                                    child: charts.SfCartesianChart(
                                      backgroundColor: Colors.white,
                                      plotAreaBorderWidth: 1,
                                      primaryXAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(text: 'Tiempo'),
                                        interval: (_contadorVoltaje / 4)
                                            .ceilToDouble(),
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      primaryYAxis: charts.NumericAxis(
                                        title: charts.AxisTitle(
                                            text: 'Voltaje (V)'),
                                        interval: 2,
                                        majorGridLines:
                                            const charts.MajorGridLines(
                                                width: 0.5),
                                      ),
                                      tooltipBehavior:
                                          charts.TooltipBehavior(enable: true),
                                      series: <charts
                                          .LineSeries<FlSpot, double>>[
                                        charts.LineSeries<FlSpot, double>(
                                          dataSource: _historialVoltaje,
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
                      icon: const Icon(Icons.show_chart),
                      label: const Text(
                        "Gráfico",
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(160, 60),
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
      backgroundColor: const Color(0xFF7E7E7E),
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Dashboard - Motor",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: selectedMetric,
                  items: <String>[
                    'Avance encendido',
                    'Carga del motor',
                    //'Consumo instantáneo combustible',
                    'Flujo aire masivo',
                    //'Presión barométrica',
                    'Presión colector admisión',
                    //'Presión combustible',
                    'RPM',
                    //'Temperatura aceite',
                    'Temperatura refrigerante',
                    //'Tiempo de funcionamiento',
                    //'Valvula admisión',
                    'Velocidad',
                    'Voltaje',
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
                child: buildGauge(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
