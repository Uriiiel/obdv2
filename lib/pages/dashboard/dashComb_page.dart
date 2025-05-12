import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:firebase_core/firebase_core.dart';

final Color colorPrimary = Color(0xFF007AFF); // Azul principal

class DashboardCombPage extends StatefulWidget {
  const DashboardCombPage({super.key});

  @override
  State<DashboardCombPage> createState() => _DashboardCombPageState();
}

class _DashboardCombPageState extends State<DashboardCombPage> {
  final ValueNotifier<double> _conInsComNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _estSisComNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _nivComNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _porEtaComNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _presRielDirNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _presRielRelNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _presBomComNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _tipoComNotifier = ValueNotifier(0.0);
  String selectedMetric = "Consumo instantáneo de combustible";
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
        .child('/SensoresCombustible/Consumo instantáneo de combustible')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _conInsComNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final conInsCom = double.tryParse(data.toString()) ?? 0.0;
          _conInsComNotifier.value = conInsCom;
        }
      }
    });
    _databaseRef
        .child('/SensoresCombustible/Estado del sistema de combustible')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _estSisComNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final estSisCom = double.tryParse(data.toString()) ?? 0.0;
          _estSisComNotifier.value = estSisCom;
        }
      }
    });
    _databaseRef
        .child('/SensoresCombustible/Nivel de combustible')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _nivComNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final nivCom = double.tryParse(data.toString()) ?? 0.0;
          _nivComNotifier.value = nivCom;
        }
      }
    });
    _databaseRef
        .child('/SensoresCombustible/Porcentaje etanol en combustible')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _porEtaComNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final porEtaCom = double.tryParse(data.toString()) ?? 0.0;
          _porEtaComNotifier.value = porEtaCom;
        }
      }
    });
    _databaseRef
        .child('/SensoresCombustible/Presion Riel combustible directa')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _presRielDirNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final presRielDir = double.tryParse(data.toString()) ?? 0.0;
          _presRielDirNotifier.value = presRielDir;
        }
      }
    });
    _databaseRef
        .child('/SensoresCombustible/Presion Riel combustible relativa')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _presRielRelNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final presRielRel = double.tryParse(data.toString()) ?? 0.0;
          _presRielRelNotifier.value = presRielRel;
        }
      }
    });
    _databaseRef
        .child('/SensoresCombustible/Presión de la bomba de combustible')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _presBomComNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final presBomCom = double.tryParse(data.toString()) ?? 0.0;
          _presBomComNotifier.value = presBomCom;
        }
      }
    });
    _databaseRef
        .child('/SensoresCombustible/Tipo combustible')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        if (data == "No soportado") {
          _tipoComNotifier.value =
              -1; // Valor especial para indicar "No soportado"
        } else {
          final tipoCom = double.tryParse(data.toString()) ?? 0.0;
          _tipoComNotifier.value = tipoCom;
        }
      }
    });
  }

  Widget buildGauge() {
    switch (selectedMetric) {
      case 'Estado del sistema de combustible':
        return buildEstSisComGauge();
      case 'Nivel de combustible':
        return buildNivComGauge();
      case 'Porcentaje etanol en combustible':
        return buildPorEtaComGauge();
      case 'Presion Riel combustible directa':
        return buildPresRielDirGauge();
      case 'Presion Riel combustible relativa':
        return buildPresRielRelGauge();
      case 'Presión de la bomba de combustible':
        return buildPresBomComGauge();
      case 'Tipo combustible':
        return buildTipoComGauge();
      default:
        return buildConInsComGauge();
    }
  }

  Widget buildConInsComGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _conInsComNotifier,
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
        return SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              startAngle: 140,
              endAngle: 40,
              minimum: 0,
              maximum: 50,
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
                  value: conInsCom,
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
                        "${conInsCom.toStringAsFixed(1)} L/h",
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
                        "Consumo Instantaneo de Combustible",
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

  Widget buildEstSisComGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _estSisComNotifier,
      builder: (context, estSisCom, child) {
        if (estSisCom == -1) {
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
              maximum: 100,
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
                  value: estSisCom,
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
                      Text(estSisCom.toStringAsFixed(0),
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
                        "Estado del Sistema de Combustible",
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

  Widget buildNivComGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _nivComNotifier,
      builder: (context, nivCom, child) {
        if (nivCom == -1) {
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
              maximum: 100,
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
                  value: nivCom,
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
                        "${nivCom.toStringAsFixed(1)} %",
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
                        "Nivel de combustible",
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

  Widget buildPorEtaComGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _porEtaComNotifier,
      builder: (context, porEtaCom, child) {
        if (porEtaCom == -1) {
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
              maximum: 100,
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
                  value:
                      porEtaCom.clamp(0, 100), // Limita valores fuera del rango
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
                        "${porEtaCom.toStringAsFixed(1)} %",
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
                        "Porcentaje etanol en combustible",
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

  Widget buildPresRielDirGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _presRielDirNotifier,
      builder: (context, presRielDir, child) {
        if (presRielDir == -1) {
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
              maximum: 300,
              radiusFactor: 0.9,
              axisLineStyle: const AxisLineStyle(
                thickness: 12,
                gradient: SweepGradient(
                  colors: [Colors.green, Colors.yellow, Colors.red],
                  stops: [0.3, 0.7, 1],
                ),
              ),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: presRielDir.clamp(0, 300),
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
                        "${presRielDir.toStringAsFixed(0)} bar",
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
                        "Presion Riel combustible directa",
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

  Widget buildPresRielRelGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _presRielRelNotifier,
      builder: (context, presRielRel, child) {
        if (presRielRel == -1) {
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
              maximum: 10,
              radiusFactor: 0.9,
              axisLineStyle: const AxisLineStyle(
                thickness: 12,
                gradient: SweepGradient(
                  colors: [Colors.green, Colors.yellow, Colors.red],
                  stops: [0.3, 0.7, 1],
                ),
              ),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: presRielRel.clamp(0, 10),
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
                        "${presRielRel.toStringAsFixed(0)} bar",
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
                        "Presion Riel combustible relativa",
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

  Widget buildPresBomComGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _presBomComNotifier,
      builder: (context, presBomCom, child) {
        if (presBomCom == -1) {
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
              maximum: 10,
              radiusFactor: 0.9,
              axisLineStyle: const AxisLineStyle(
                thickness: 12,
                gradient: SweepGradient(
                  colors: [Colors.red, Colors.yellow, Colors.green],
                  stops: [0.3, 0.7, 1],
                ),
              ),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: presBomCom.clamp(0, 10),
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
                        "${presBomCom.toStringAsFixed(0)} bar",
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
                        "Presión de la bomba de combustible",
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

  Widget buildTipoComGauge() {
    return ValueListenableBuilder<double>(
      valueListenable: _tipoComNotifier,
      builder: (context, tipoCom, child) {
        if (tipoCom == -1) {
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
              maximum: 100,
              radiusFactor: 0.9,
              axisLineStyle: const AxisLineStyle(
                thickness: 12,
                gradient: SweepGradient(
                  colors: [Colors.green, Colors.yellow, Colors.red],
                  stops: [0.3, 0.7, 1],
                ),
              ),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: tipoCom.clamp(0, 100),
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
                        "${tipoCom.toStringAsFixed(0)}",
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
                        "Tipo de Combustible",
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
            color: Colors.white,
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
                  value: selectedMetric,
                  items: <String>[
                    'Consumo instantáneo de combustible',
                    'Estado del sistema de combustible',
                    'Nivel de combustible',
                    'Porcentaje etanol en combustible',
                    'Presion Riel combustible directa',
                    'Presion Riel combustible relativa',
                    'Presión de la bomba de combustible',
                    'Tipo combustible',
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
