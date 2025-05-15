import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

final Color colorPrimary = Color(0xFF007AFF); // Azul principal

class DashboardOxPage extends StatefulWidget {
  const DashboardOxPage({super.key});

  @override
  State<DashboardOxPage> createState() => _DashboardOxPageState();
}

class _DashboardOxPageState extends State<DashboardOxPage> {
  final ValueNotifier<double> _sOB1S1Notifier = ValueNotifier(0.0);
  final ValueNotifier<double> _sOB1S2Notifier = ValueNotifier(0.0);
  final ValueNotifier<double> _sOB1S3Notifier = ValueNotifier(0.0);
  final ValueNotifier<double> _sOB1S4Notifier = ValueNotifier(0.0);
  final ValueNotifier<double> _sOB2S1Notifier = ValueNotifier(0.0);
  final ValueNotifier<double> _sOB2S2Notifier = ValueNotifier(0.0);
  final ValueNotifier<double> _sOB2S3Notifier = ValueNotifier(0.0);
  final ValueNotifier<double> _sOB2S4Notifier = ValueNotifier(0.0);
  final ValueNotifier<double> _tempCataB1S1Notifier = ValueNotifier(0.0);
  final ValueNotifier<double> _tempCataB1S2Notifier = ValueNotifier(0.0);
  final ValueNotifier<double> _tempCataB2S1Notifier = ValueNotifier(0.0);
  final ValueNotifier<double> _tempCataB2S2Notifier = ValueNotifier(0.0);
  String selectedMetric = "Sensor oxigeno-B1S1";
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _setupDatabaseListeners();
  }

  void _setupDatabaseListeners() {
    _databaseRef
        .child('/SensoresOxigeno/Sensor oxigeno-B1S1')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _sOB1S1Notifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final sOB1S1 = double.tryParse(data.toString()) ?? 0.0;
          _sOB1S1Notifier.value = sOB1S1;
        }
      }
    });
    _databaseRef
        .child('/SensoresOxigeno/Sensor oxigeno-B1S2')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _sOB1S2Notifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final sOB1S2 = double.tryParse(data.toString()) ?? 0.0;
          _sOB1S2Notifier.value = sOB1S2;
        }
      }
    });
    _databaseRef
        .child('/SensoresOxigeno/Sensor oxigeno-B1S3')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _sOB1S3Notifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final sOB1S3 = double.tryParse(data.toString()) ?? 0.0;
          _sOB1S3Notifier.value = sOB1S3;
        }
      }
    });
    _databaseRef
        .child('/SensoresOxigeno/Sensor oxigeno-B1S4')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _sOB1S4Notifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final sOB1S4 = double.tryParse(data.toString()) ?? 0.0;
          _sOB1S4Notifier.value = sOB1S4;
        }
      }
    });
    _databaseRef
        .child('/SensoresOxigeno/Sensor oxigeno-B2S1')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _sOB2S1Notifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final sOB2S1 = double.tryParse(data.toString()) ?? 0.0;
          _sOB1S4Notifier.value = sOB2S1;
        }
      }
    });
    _databaseRef
        .child('/SensoresOxigeno/Sensor oxigeno-B2S2')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _sOB2S2Notifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final sOB2S2 = double.tryParse(data.toString()) ?? 0.0;
          _sOB2S2Notifier.value = sOB2S2;
        }
      }
    });
    _databaseRef
        .child('/SensoresOxigeno/Sensor oxigeno-B2S3')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _sOB2S3Notifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final sOB2S3 = double.tryParse(data.toString()) ?? 0.0;
          _sOB2S3Notifier.value = sOB2S3;
        }
      }
    });
    _databaseRef
        .child('/SensoresOxigeno/Sensor oxigeno-B2S4')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _sOB2S4Notifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final sOB2S4 = double.tryParse(data.toString()) ?? 0.0;
          _sOB2S4Notifier.value = sOB2S4;
        }
      }
    });
    _databaseRef
        .child('/SensoresOxigeno/Temp catalizador-B1S1')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _tempCataB1S1Notifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final tempCataB1S1 = double.tryParse(data.toString()) ?? 0.0;
          _tempCataB1S1Notifier.value = tempCataB1S1;
        }
      }
    });
    _databaseRef
        .child('/SensoresOxigeno/Temp catalizador-B1S2')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _tempCataB1S2Notifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final tempCataB1S2 = double.tryParse(data.toString()) ?? 0.0;
          _tempCataB1S2Notifier.value = tempCataB1S2;
        }
      }
    });
    _databaseRef
        .child('/SensoresOxigeno/Temp catalizador-B2S1')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _tempCataB2S1Notifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final tempCataB2S1 = double.tryParse(data.toString()) ?? 0.0;
          _tempCataB2S1Notifier.value = tempCataB2S1;
        }
      }
    });
    _databaseRef
        .child('/SensoresOxigeno/Temp catalizador-B2S2')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _tempCataB2S2Notifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final tempCataB2S2 = double.tryParse(data.toString()) ?? 0.0;
          _tempCataB2S2Notifier.value = tempCataB2S2;
        }
      }
    });
  }

  Widget buildGauge() {
    switch (selectedMetric) {
      case 'Sensor oxigeno-B1S2':
        return buildSOB1S2Gauge();
      case 'Sensor oxigeno-B1S3':
        return buildSOB1S3Gauge();
      case 'Sensor oxigeno-B1S4':
        return buildSOB1S4Gauge();
      case 'Sensor oxigeno-B2S1':
        return buildSOB2S1Gauge();
      case 'Sensor oxigeno-B2S2':
        return buildSOB2S2Gauge();
      case 'Sensor oxigeno-B2S3':
        return buildSOB2S3Gauge();
      case 'Sensor oxigeno-B2S4':
        return buildSOB2S4Gauge();
      case 'Temp catalizador-B1S1':
        return buildTCataB1S1Gauge();
      case 'Temp catalizador-B1S2':
        return buildTCataB1S2Gauge();
      case 'Temp catalizador-B2S1':
        return buildTCataB2S1Gauge();
      case 'Temp catalizador-B2S2':
        return buildTCataB2S2Gauge();
      default:
        return buildSOB1S1Gauge();
    }
  }

  Widget buildSOB1S1Gauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _sOB1S1Notifier,
      builder: (context, sOB1S1, child) {
        if (sOB1S1 == -1) {
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
        return SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              startAngle: 140,
              endAngle: 40,
              minimum: 0,
              maximum: 1,
              radiusFactor: 0.9,
              majorTickStyle: const MajorTickStyle(
                length: 12,
                thickness: 2,
                color: Colors.white,
              ),
              minorTicksPerInterval: 4,
              minorTickStyle: const MinorTickStyle(
                length: 6,
                thickness: 1,
                color: Colors.grey,
              ),
              axisLineStyle: const AxisLineStyle(
                thickness: 15,
                gradient: SweepGradient(
                  colors: [Colors.green, Colors.yellow, Colors.red],
                  stops: [0.3, 0.7, 1],
                ),
              ),
              axisLabelStyle: const GaugeTextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: sOB1S1,
                  enableAnimation: true,
                  animationType: AnimationType.easeOutBack,
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
                  knobStyle: KnobStyle(
                    color: Colors.transparent,
                    borderColor: Colors.blue.withAlpha(100),
                    borderWidth: 1,
                  ),
                ),
              ],
              annotations: [
                GaugeAnnotation(
                  widget: Column(
                    children: [
                      const SizedBox(height: 180),
                      Text(
                        "${sOB1S1.toDouble()}",
                        style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          shadows: [
                            Shadow(
                              color: Colors.white,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        "Sensor oxigeno-B1S1",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
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
      },
    );
  }

  Widget buildSOB1S2Gauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _sOB1S2Notifier,
      builder: (context, sOB1S2, child) {
        if (sOB1S2 == -1) {
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
        return SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              startAngle: 140,
              endAngle: 40,
              minimum: 0,
              maximum: 1,
              radiusFactor: 0.9,
              majorTickStyle: const MajorTickStyle(
                length: 12,
                thickness: 2,
                color: Colors.black,
              ),
              minorTicksPerInterval: 4,
              minorTickStyle: const MinorTickStyle(
                length: 6,
                thickness: 1,
                color: Colors.grey,
              ),
              axisLineStyle: const AxisLineStyle(
                thickness: 15,
                gradient: SweepGradient(
                  colors: [Colors.green, Colors.yellow, Colors.red],
                  stops: [0.3, 0.7, 1],
                ),
              ),
              axisLabelStyle: const GaugeTextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: sOB1S2,
                  enableAnimation: true,
                  animationType: AnimationType.easeOutBack,
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
                  knobStyle: KnobStyle(
                    color: Colors.transparent,
                    borderColor: Colors.blue.withAlpha(100),
                    borderWidth: 1,
                  ),
                ),
              ],
              annotations: [
                GaugeAnnotation(
                  widget: Column(
                    children: [
                      const SizedBox(height: 180),
                      Text("${sOB1S2.toDouble()}",
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                            shadows: [
                              Shadow(
                                color: Colors.white,
                                blurRadius: 20,
                              ),
                            ],
                          )),
                      const Text(
                        "Sensor oxigeno-B1S2",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
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
      },
    );
  }

  Widget buildSOB1S3Gauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _sOB1S3Notifier,
      builder: (context, sOB1S3, child) {
        if (sOB1S3 == -1) {
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
        return SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              startAngle: 140,
              endAngle: 40,
              minimum: 0,
              maximum: 1,
              radiusFactor: 0.9,
              majorTickStyle: const MajorTickStyle(
                length: 12,
                thickness: 2,
                color: Colors.black,
              ),
              minorTicksPerInterval: 4,
              minorTickStyle: const MinorTickStyle(
                length: 6,
                thickness: 1,
                color: Colors.grey,
              ),
              axisLineStyle: const AxisLineStyle(
                thickness: 15,
                gradient: SweepGradient(
                  colors: [Colors.green, Colors.yellow, Colors.red],
                  stops: [0.3, 0.7, 1],
                ),
              ),
              axisLabelStyle: const GaugeTextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: sOB1S3,
                  enableAnimation: true,
                  animationType: AnimationType.easeOutBack,
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
                  knobStyle: KnobStyle(
                    color: Colors.transparent,
                    borderColor: Colors.blue.withAlpha(100),
                    borderWidth: 1,
                  ),
                ),
              ],
              annotations: [
                GaugeAnnotation(
                  widget: Column(
                    children: [
                      const SizedBox(height: 180),
                      Text(
                        "${sOB1S3.toDouble()}",
                        style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          shadows: [
                            Shadow(
                              color: Colors.white,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        "Sensor oxigeno-B1S3",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
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
      },
    );
  }

  Widget buildSOB1S4Gauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _sOB1S4Notifier,
      builder: (context, sOB1S4, child) {
        if (sOB1S4 == -1) {
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

        return SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              startAngle: 140,
              endAngle: 40,
              minimum: 0,
              maximum: 1,
              radiusFactor: 0.9,
              majorTickStyle: const MajorTickStyle(
                length: 10,
                thickness: 2,
                color: Colors.black,
              ),
              minorTicksPerInterval: 2,
              minorTickStyle: const MinorTickStyle(
                length: 5,
                thickness: 1,
                color: Colors.grey,
              ),
              axisLineStyle: const AxisLineStyle(
                thickness: 12,
                gradient: SweepGradient(
                  colors: [Colors.green, Colors.yellow, Colors.red],
                  stops: [0.3, 0.7, 1],
                ),
              ),
              axisLabelStyle: const GaugeTextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: sOB1S4.clamp(0, 1),
                  enableAnimation: true,
                  animationType: AnimationType.elasticOut,
                  needleColor: Colors.red,
                  needleStartWidth: 1,
                  needleEndWidth: 5,
                  needleLength: 0.75,
                  animationDuration: 1500,
                  gradient: const LinearGradient(
                    colors: [Colors.white, Colors.red],
                  ),
                  knobStyle: KnobStyle(
                    color: Colors.transparent,
                    borderColor: Colors.blue.withAlpha(100),
                    borderWidth: 1,
                  ),
                ),
              ],
              annotations: [
                GaugeAnnotation(
                  widget: Column(
                    children: [
                      const SizedBox(height: 180),
                      Text(
                        "${sOB1S4.toDouble()}",
                        style: const TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          shadows: [
                            Shadow(
                              color: Colors.white,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        "Sensor oxigeno-B1S4",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
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
      },
    );
  }

  Widget buildSOB2S1Gauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _sOB2S1Notifier,
      builder: (context, sOB2S1, child) {
        if (sOB2S1 == -1) {
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

        return SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              startAngle: 140,
              endAngle: 40,
              minimum: 0,
              maximum: 1,
              radiusFactor: 0.9,
              majorTickStyle: const MajorTickStyle(
                length: 12,
                thickness: 2,
                color: Colors.black,
              ),
              minorTicksPerInterval: 4,
              minorTickStyle: const MinorTickStyle(
                length: 6,
                thickness: 1,
                color: Colors.grey,
              ),
              axisLineStyle: const AxisLineStyle(
                thickness: 12,
                gradient: SweepGradient(
                  colors: [Colors.green, Colors.yellow, Colors.red],
                  stops: [0.3, 0.7, 1],
                ),
              ),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: sOB2S1.clamp(0, 1),
                  enableAnimation: true,
                  animationType: AnimationType.elasticOut,
                  needleColor: Colors.red,
                  needleLength: 0.75,
                  animationDuration: 1500,
                  gradient: const LinearGradient(
                    colors: [Colors.white, Colors.red],
                  ),
                  knobStyle: KnobStyle(
                    color: Colors.transparent,
                    borderColor: Colors.blue.withAlpha(100),
                    borderWidth: 1,
                  ),
                ),
              ],
              annotations: [
                GaugeAnnotation(
                  widget: Column(
                    children: [
                      const SizedBox(height: 180),
                      Text(
                        "${sOB2S1.toDouble()}",
                        style: const TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          shadows: [
                            Shadow(color: Colors.white, blurRadius: 20)
                          ],
                        ),
                      ),
                      const Text(
                        "Sensor oxigeno-B2S1",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  ),
                  angle: 90,
                  positionFactor: 0.75,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildSOB2S2Gauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _sOB2S2Notifier,
      builder: (context, sOB2S2, child) {
        if (sOB2S2 == -1) {
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

        return SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              startAngle: 140,
              endAngle: 40,
              minimum: 0,
              maximum: 1,
              radiusFactor: 0.9,
              majorTickStyle: const MajorTickStyle(
                length: 12,
                thickness: 2,
                color: Colors.black,
              ),
              minorTicksPerInterval: 4,
              minorTickStyle: const MinorTickStyle(
                length: 6,
                thickness: 1,
                color: Colors.grey,
              ),
              axisLineStyle: const AxisLineStyle(
                thickness: 12,
                gradient: SweepGradient(
                  colors: [Colors.green, Colors.yellow, Colors.red],
                  stops: [0.3, 0.7, 1],
                ),
              ),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: sOB2S2.clamp(0, 1),
                  enableAnimation: true,
                  animationType: AnimationType.elasticOut,
                  needleColor: Colors.red,
                  needleLength: 0.75,
                  animationDuration: 1500,
                  gradient: const LinearGradient(
                    colors: [Colors.white, Colors.red],
                  ),
                  knobStyle: KnobStyle(
                    color: Colors.transparent,
                    borderColor: Colors.blue.withAlpha(100),
                    borderWidth: 1,
                  ),
                ),
              ],
              annotations: [
                GaugeAnnotation(
                  widget: Column(
                    children: [
                      const SizedBox(height: 180),
                      Text(
                        "${sOB2S2.toDouble()}",
                        style: const TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          shadows: [
                            Shadow(color: Colors.white, blurRadius: 20)
                          ],
                        ),
                      ),
                      const Text(
                        "Sensor oxigeno-B2S2",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  ),
                  angle: 90,
                  positionFactor: 0.75,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildSOB2S3Gauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _sOB2S3Notifier,
      builder: (context, sOB2S3, child) {
        if (sOB2S3 == -1) {
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

        return SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              startAngle: 140,
              endAngle: 40,
              minimum: 0,
              maximum: 1,
              radiusFactor: 0.9,
              majorTickStyle: const MajorTickStyle(
                length: 12,
                thickness: 2,
                color: Colors.black,
              ),
              minorTicksPerInterval: 4,
              minorTickStyle: const MinorTickStyle(
                length: 6,
                thickness: 1,
                color: Colors.grey,
              ),
              axisLineStyle: const AxisLineStyle(
                thickness: 12,
                gradient: SweepGradient(
                  colors: [Colors.red, Colors.yellow, Colors.green],
                  stops: [0.3, 0.7, 1],
                ),
              ),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: sOB2S3.clamp(0, 1),
                  enableAnimation: true,
                  animationType: AnimationType.elasticOut,
                  needleColor: Colors.red,
                  needleLength: 0.75,
                  animationDuration: 1500,
                  gradient: const LinearGradient(
                    colors: [Colors.white, Colors.red],
                  ),
                  knobStyle: KnobStyle(
                    color: Colors.transparent,
                    borderColor: Colors.blue.withAlpha(100),
                    borderWidth: 1,
                  ),
                ),
              ],
              annotations: [
                GaugeAnnotation(
                  widget: Column(
                    children: [
                      const SizedBox(height: 180),
                      Text(
                        "${sOB2S3.toDouble()}",
                        style: const TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          shadows: [
                            Shadow(color: Colors.white, blurRadius: 20)
                          ],
                        ),
                      ),
                      const Text(
                        "Sensor oxigeno-B2S3",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  ),
                  angle: 90,
                  positionFactor: 0.75,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildSOB2S4Gauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _sOB2S4Notifier,
      builder: (context, sOB2S4, child) {
        if (sOB2S4 == -1) {
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

        return SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              startAngle: 140,
              endAngle: 40,
              minimum: 0,
              maximum: 1,
              radiusFactor: 0.9,
              majorTickStyle: const MajorTickStyle(
                length: 12,
                thickness: 2,
                color: Colors.black,
              ),
              minorTicksPerInterval: 4,
              minorTickStyle: const MinorTickStyle(
                length: 6,
                thickness: 1,
                color: Colors.grey,
              ),
              axisLineStyle: const AxisLineStyle(
                thickness: 12,
                gradient: SweepGradient(
                  colors: [Colors.green, Colors.yellow, Colors.red],
                  stops: [0.3, 0.7, 1],
                ),
              ),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: sOB2S4.clamp(0, 1),
                  enableAnimation: true,
                  animationType: AnimationType.elasticOut,
                  needleColor: Colors.red,
                  needleLength: 0.75,
                  animationDuration: 1500,
                  gradient: const LinearGradient(
                    colors: [Colors.white, Colors.red],
                  ),
                  knobStyle: KnobStyle(
                    color: Colors.transparent,
                    borderColor: Colors.blue.withAlpha(100),
                    borderWidth: 1,
                  ),
                ),
              ],
              annotations: [
                GaugeAnnotation(
                  widget: Column(
                    children: [
                      const SizedBox(height: 180),
                      Text(
                        "${sOB2S4.toDouble()}",
                        style: const TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          shadows: [
                            Shadow(color: Colors.white, blurRadius: 20)
                          ],
                        ),
                      ),
                      const Text(
                        "Sensor oxigeno-B2S4",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  ),
                  angle: 90,
                  positionFactor: 0.75,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildTCataB1S1Gauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _tempCataB1S1Notifier,
      builder: (context, tempCataB1S1, child) {
        if (tempCataB1S1 == -1) {
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

        return SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              startAngle: 140,
              endAngle: 40,
              minimum: 0,
              maximum: 1200,
              radiusFactor: 0.9,
              majorTickStyle: const MajorTickStyle(
                length: 12,
                thickness: 2,
                color: Colors.black,
              ),
              minorTicksPerInterval: 4,
              minorTickStyle: const MinorTickStyle(
                length: 6,
                thickness: 1,
                color: Colors.grey,
              ),
              axisLineStyle: const AxisLineStyle(
                thickness: 12,
                gradient: SweepGradient(
                  colors: [Colors.green, Colors.yellow, Colors.red],
                  stops: [0.3, 0.7, 1],
                ),
              ),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: tempCataB1S1.clamp(0, 1200),
                  enableAnimation: true,
                  animationType: AnimationType.elasticOut,
                  needleColor: Colors.red,
                  needleLength: 0.75,
                  animationDuration: 1500,
                  gradient: const LinearGradient(
                    colors: [Colors.white, Colors.red],
                  ),
                  knobStyle: KnobStyle(
                    color: Colors.transparent,
                    borderColor: Colors.blue.withAlpha(100),
                    borderWidth: 1,
                  ),
                ),
              ],
              annotations: [
                GaugeAnnotation(
                  widget: Column(
                    children: [
                      const SizedBox(height: 180),
                      Text(
                        "${tempCataB1S1.toDouble()}",
                        style: const TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          shadows: [
                            Shadow(color: Colors.white, blurRadius: 20)
                          ],
                        ),
                      ),
                      const Text(
                        "Temp catalizador-B1S1",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  ),
                  angle: 90,
                  positionFactor: 0.75,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildTCataB1S2Gauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _tempCataB1S2Notifier,
      builder: (context, tempCataB1S2, child) {
        if (tempCataB1S2 == -1) {
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

        return SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              startAngle: 140,
              endAngle: 40,
              minimum: 0,
              maximum: 1200,
              radiusFactor: 0.9,
              majorTickStyle: const MajorTickStyle(
                length: 12,
                thickness: 2,
                color: Colors.black,
              ),
              minorTicksPerInterval: 4,
              minorTickStyle: const MinorTickStyle(
                length: 6,
                thickness: 1,
                color: Colors.grey,
              ),
              axisLineStyle: const AxisLineStyle(
                thickness: 12,
                gradient: SweepGradient(
                  colors: [Colors.green, Colors.yellow, Colors.red],
                  stops: [0.3, 0.7, 1],
                ),
              ),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: tempCataB1S2.clamp(0, 1200),
                  enableAnimation: true,
                  animationType: AnimationType.elasticOut,
                  needleColor: Colors.red,
                  needleLength: 0.75,
                  animationDuration: 1500,
                  gradient: const LinearGradient(
                    colors: [Colors.white, Colors.red],
                  ),
                  knobStyle: KnobStyle(
                    color: Colors.transparent,
                    borderColor: Colors.blue.withAlpha(100),
                    borderWidth: 1,
                  ),
                ),
              ],
              annotations: [
                GaugeAnnotation(
                  widget: Column(
                    children: [
                      const SizedBox(height: 180),
                      Text(
                        "${tempCataB1S2.toDouble()}",
                        style: const TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          shadows: [
                            Shadow(color: Colors.white, blurRadius: 20)
                          ],
                        ),
                      ),
                      const Text(
                        "Temp catalizador-B1S2",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  ),
                  angle: 90,
                  positionFactor: 0.75,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildTCataB2S1Gauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _tempCataB2S1Notifier,
      builder: (context, tempCataB2S1, child) {
        if (tempCataB2S1 == -1) {
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

        return SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              startAngle: 140,
              endAngle: 40,
              minimum: 0,
              maximum: 1200,
              radiusFactor: 0.9,
              majorTickStyle: const MajorTickStyle(
                length: 12,
                thickness: 2,
                color: Colors.black,
              ),
              minorTicksPerInterval: 4,
              minorTickStyle: const MinorTickStyle(
                length: 6,
                thickness: 1,
                color: Colors.grey,
              ),
              axisLineStyle: const AxisLineStyle(
                thickness: 12,
                gradient: SweepGradient(
                  colors: [Colors.red, Colors.yellow, Colors.green],
                  stops: [0.3, 0.7, 1],
                ),
              ),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: tempCataB2S1.clamp(0, 1200),
                  enableAnimation: true,
                  animationType: AnimationType.elasticOut,
                  needleColor: Colors.red,
                  needleLength: 0.75,
                  animationDuration: 1500,
                  gradient: const LinearGradient(
                    colors: [Colors.white, Colors.red],
                  ),
                  knobStyle: KnobStyle(
                    color: Colors.transparent,
                    borderColor: Colors.blue.withAlpha(100),
                    borderWidth: 1,
                  ),
                ),
              ],
              annotations: [
                GaugeAnnotation(
                  widget: Column(
                    children: [
                      const SizedBox(height: 180),
                      Text(
                        "${tempCataB2S1.toDouble()}",
                        style: const TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          shadows: [
                            Shadow(color: Colors.white, blurRadius: 20)
                          ],
                        ),
                      ),
                      const Text(
                        "Temp catalizador-B2S1",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  ),
                  angle: 90,
                  positionFactor: 0.75,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildTCataB2S2Gauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _tempCataB2S2Notifier,
      builder: (context, tempCataB2S2, child) {
        if (tempCataB2S2 == -1) {
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

        return SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              startAngle: 140,
              endAngle: 40,
              minimum: 0,
              maximum: 1200,
              radiusFactor: 0.9,
              majorTickStyle: const MajorTickStyle(
                length: 12,
                thickness: 2,
                color: Colors.black,
              ),
              minorTicksPerInterval: 4,
              minorTickStyle: const MinorTickStyle(
                length: 6,
                thickness: 1,
                color: Colors.grey,
              ),
              axisLineStyle: const AxisLineStyle(
                thickness: 12,
                gradient: SweepGradient(
                  colors: [Colors.green, Colors.yellow, Colors.red],
                  stops: [0.3, 0.7, 1],
                ),
              ),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: tempCataB2S2.clamp(0, 1200),
                  enableAnimation: true,
                  animationType: AnimationType.elasticOut,
                  needleColor: Colors.red,
                  needleLength: 0.75,
                  animationDuration: 1500,
                  gradient: const LinearGradient(
                    colors: [Colors.white, Colors.red],
                  ),
                  knobStyle: KnobStyle(
                    color: Colors.transparent,
                    borderColor: Colors.blue.withAlpha(100),
                    borderWidth: 1,
                  ),
                ),
              ],
              annotations: [
                GaugeAnnotation(
                  widget: Column(
                    children: [
                      const SizedBox(height: 180),
                      Text(
                        "${tempCataB2S2.toDouble()}",
                        style: const TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          shadows: [
                            Shadow(color: Colors.white, blurRadius: 20)
                          ],
                        ),
                      ),
                      const Text(
                        "Temp catalizador-B2S2",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  ),
                  angle: 90,
                  positionFactor: 0.75,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 188, 188, 188),
      appBar: AppBar(
        backgroundColor: colorPrimary,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
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
            // DropdownButton para seleccionar métrica
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  boxShadow: [
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
                    'Sensor oxigeno-B1S1',
                    'Sensor oxigeno-B1S2',
                    'Sensor oxigeno-B1S3',
                    'Sensor oxigeno-B1S4',
                    'Sensor oxigeno-B2S1',
                    'Sensor oxigeno-B2S2',
                    'Sensor oxigeno-B2S3',
                    'Sensor oxigeno-B2S4',
                    'Temp catalizador-B1S1',
                    'Temp catalizador-B1S2',
                    'Temp catalizador-B2S1',
                    'Temp catalizador-B2S2',
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
