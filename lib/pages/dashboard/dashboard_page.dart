// // import 'package:flutter/material.dart';
// // import 'package:firebase_database/firebase_database.dart';
// // import 'package:syncfusion_flutter_gauges/gauges.dart';

// // final Color colorPrimary = Color(0xFF007AFF); // Azul principal

// // class SpeedometerPage extends StatefulWidget {
// //   const SpeedometerPage({super.key});

// //   @override
// //   State<SpeedometerPage> createState() => _SpeedometerPageState();
// // }

// // class _SpeedometerPageState extends State<SpeedometerPage> {

// //   final ValueNotifier<double> _avanceEnNotifier = ValueNotifier(0.0);
// //   final ValueNotifier<double> _cargaMotorNotifier = ValueNotifier(0.0);
// //   final ValueNotifier<double> _cargaInComNotifier = ValueNotifier(0.0);
// //   final ValueNotifier<double> _flujoAirComNotifier = ValueNotifier(0.0);
// //   final ValueNotifier<double> _presBaromNotifier = ValueNotifier(0.0);
// //   final ValueNotifier<double> _presColAdmiNotifier = ValueNotifier(0.0);
// //   final ValueNotifier<double> _presComNotifier = ValueNotifier(0.0);
// //   final ValueNotifier<double> _rpmNotifier = ValueNotifier(0.0);
// //   final ValueNotifier<double> _tempAceNotifier = ValueNotifier(0.0);
// //   final ValueNotifier<double> _tempRefNotifier = ValueNotifier(0.0);
// //   final ValueNotifier<double> _tiemEncNotifier = ValueNotifier(0.0);
// //   final ValueNotifier<double> _valvAdmNotifier = ValueNotifier(0.0);
// //   final ValueNotifier<double> _velocidadNotifier = ValueNotifier(0.0);
// //   final ValueNotifier<double> _voltajeNotifier = ValueNotifier(0.0);

// //   String selectedMetric = "Avance encendido";
// //   final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

// //   @override
// //   void initState() {
// //     super.initState();
// //     _setupDatabaseListeners();
// //   }

// //   void _setupDatabaseListeners() {

// //     _databaseRef.child('/SensoresMotor/Avance encendido').onValue.listen((event) {
// //       final data = event.snapshot.value;
// //       if (data != null) {
// //         if (data == "No soportado") {
// //           _avanceEnNotifier.value =
// //               -11;
// //         } else {
// //           final avanen = double.tryParse(data.toString()) ?? 0.0;
// //           _avanceEnNotifier.value = avanen;
// //         }
// //       }
// //     });

// //     _databaseRef
// //         .child('/SensoresMotor/Carga del motor')
// //         .onValue
// //         .listen((event) {
// //       final data = event.snapshot.value;
// //       if (data != null) {
// //         if (data == "No soportado") {
// //           _cargaMotorNotifier.value =
// //               -1; // Valor especial para indicar "No soportado"
// //         } else {
// //           final carmotor = double.tryParse(data.toString()) ?? 0.0;
// //           _cargaMotorNotifier.value = carmotor;
// //         }
// //       }
// //     });

// //     _databaseRef
// //         .child('/SensoresMotor/Consumo instantáneo combustible')
// //         .onValue
// //         .listen((event) {
// //       final data = event.snapshot.value;
// //       if (data != null) {
// //         if (data == "No soportado") {
// //           _cargaInComNotifier.value =
// //               -1; // Valor especial para indicar "No soportado"
// //         } else {
// //           final conincom = double.tryParse(data.toString()) ?? 0.0;
// //           _cargaInComNotifier.value = conincom;
// //         }
// //       }
// //     });

// //     _databaseRef.child('/SensoresMotor/Flujo aire masivo').onValue.listen((event) {
// //       final data = event.snapshot.value;
// //       if (data != null) {
// //         if (data == "No soportado") {
// //           _flujoAirComNotifier.value =
// //               -1; // Valor especial para indicar "No soportado"
// //         } else {
// //           final flujoair = double.tryParse(data.toString()) ?? 0.0;
// //           _flujoAirComNotifier.value = flujoair;
// //         }
// //       }
// //     });

// //     _databaseRef
// //         .child('/SensoresMotor/Presion barometrica')
// //         .onValue
// //         .listen((event) {
// //       final data = event.snapshot.value;
// //       if (data != null) {
// //         if (data == "No soportado") {
// //           _presBaromNotifier.value =
// //               -1; // Valor especial para indicar "No soportado"
// //         } else {
// //           final presbarom = double.tryParse(data.toString()) ?? 0.0;
// //           _presBaromNotifier.value = presbarom;
// //         }
// //       }
// //     });

// //     _databaseRef
// //         .child('/SensoresMotor/Presión colector admisión')
// //         .onValue
// //         .listen((event) {
// //       final data = event.snapshot.value;
// //       if (data != null) {
// //         if (data == "No soportado") {
// //           _presColAdmiNotifier.value =
// //               -1; // Valor especial para indicar "No soportado"
// //         } else {
// //           final prescoladm = double.tryParse(data.toString()) ?? 0.0;
// //           _presColAdmiNotifier.value = prescoladm;
// //         }
// //       }
// //     });

// //     _databaseRef
// //         .child('/SensoresMotor/Presión combustible')
// //         .onValue
// //         .listen((event) {
// //       final data = event.snapshot.value;
// //       if (data != null) {
// //         if (data == "No soportado") {
// //           _presComNotifier.value =
// //               -1; // Valor especial para indicar "No soportado"
// //         } else {
// //           final prescom = double.tryParse(data.toString()) ?? 0.0;
// //           _presComNotifier.value = prescom;
// //         }
// //       }
// //     });

// //     _databaseRef.child('/SensoresMotor/RPM').onValue.listen((event) {
// //       final data = event.snapshot.value;
// //       if (data != null) {
// //         if (data == "No soportado") {
// //           _rpmNotifier.value = -1; // Valor especial para indicar "No soportado"
// //         } else {
// //           final rpm = double.tryParse(data.toString()) ?? 0.0;
// //           _rpmNotifier.value = rpm;
// //         }
// //       }
// //     });

// //     _databaseRef
// //         .child('/SensoresMotor/Temperatura aceite')
// //         .onValue
// //         .listen((event) {
// //       final data = event.snapshot.value;
// //       if (data != null) {
// //         if (data == "No soportado") {
// //           _tempAceNotifier.value =
// //               -1; // Valor especial para indicar "No soportado"
// //         } else {
// //           final tempace = double.tryParse(data.toString()) ?? 0.0;
// //           _tempAceNotifier.value = tempace;
// //         }
// //       }
// //     });

// //     _databaseRef
// //         .child('/SensoresMotor/Temperatura refrigerante')
// //         .onValue
// //         .listen((event) {
// //       final data = event.snapshot.value;
// //       if (data != null) {
// //         if (data == "No soportado") {
// //           _tempRefNotifier.value =
// //               -1; // Valor especial para indicar "No soportado"
// //         } else {
// //           final tempref = double.tryParse(data.toString()) ?? 0.0;
// //           _tempRefNotifier.value = tempref;
// //         }
// //       }
// //     });

// //     _databaseRef
// //         .child('/SensoresMotor/Tmp Funcionamiento')
// //         .onValue
// //         .listen((event) {
// //       final data = event.snapshot.value;
// //       if (data != null) {
// //         if (data == "No soportado") {
// //           _tiemEncNotifier.value =
// //               -11; // Valor especial para indicar "No soportado"
// //         } else {
// //           final tiempen = double.tryParse(data.toString()) ?? 0.0;
// //           _tiemEncNotifier.value = tiempen;
// //         }
// //       }
// //     });

// //     _databaseRef.child('/SensoresMotor/Valvula admision').onValue.listen((event) {
// //       final data = event.snapshot.value;
// //       if (data != null) {
// //         if (data == "No soportado") {
// //           _valvAdmNotifier.value =
// //               -1; // Valor especial para indicar "No soportado"
// //         } else {
// //           final valvAdm = double.tryParse(data.toString()) ?? 0.0;
// //           _valvAdmNotifier.value = valvAdm;
// //         }
// //       }
// //     });

// //     _databaseRef.child('/SensoresMotor/Velocidad').onValue.listen((event) {
// //       final data = event.snapshot.value;
// //       if (data != null) {
// //         if (data == "No soportado") {
// //           _velocidadNotifier.value =
// //               -1; // Valor especial para indicar "No soportado"
// //         } else {
// //           final velocidad = double.tryParse(data.toString()) ?? 0.0;
// //           _velocidadNotifier.value = velocidad;
// //         }
// //       }
// //     });

// //     _databaseRef.child('/SensoresMotor/Voltaje').onValue.listen((event) {
// //       final data = event.snapshot.value;
// //       if (data != null) {
// //         if (data == "No soportado") {
// //           _voltajeNotifier.value =
// //               -1; // Valor especial para indicar "No soportado"
// //         } else {
// //           final voltaje = double.tryParse(data.toString()) ?? 0.0;
// //           _voltajeNotifier.value = voltaje;
// //         }
// //       }
// //     });
// //   }

// //   Widget buildGauge() {
// //     switch (selectedMetric) {
// //       case 'Carga del motor':
// //         return buildCargamotorGauge();
// //       case 'Consumo instantáneo combustible':
// //         return buildConsumoInsComGauge();
// //       case 'Flujo aire masivo':
// //         return buildFAMGauge();
// //       case 'Presion barometrica':
// //         return buildPBGauge();
// //       case 'Presión colector admisión':
// //         return buildPresColAdmGauge();
// //       case 'Presión combustible':
// //         return buildPresComGauge();
// //       case 'RPM':
// //         return buildRpmGauge();
// //       case 'Temperatura aceite':
// //         return buildTempAceiteGauge();
// //       case 'Temperatura refrigerante':
// //         return buildTempRefGauge();
// //       case 'Tiempo de funcionamiento':
// //         return buildTieEncGauge();
// //       case 'Valvula admision':
// //         return buildVAGauge();
// //       case 'Velocidad':
// //         return buildSpeedGauge();
// //       case 'Voltaje':
// //         return buildVoltajeGauge();
// //       default:
// //         return buildAEGauge();
// //     }
// //   }

// //   Widget buildAEGauge() {
// //     return ValueListenableBuilder<double>(
// //       valueListenable: _avanceEnNotifier,
// //       builder: (context, avanen, child) {
// //         if (avanen < -10) {
// //           return Center(
// //             child: Text(
// //               "No soportado",
// //               style: TextStyle(
// //                 fontSize: 40,
// //                 color: Colors.red,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           );
// //         }

// //         return SfRadialGauge(
// //           axes: <RadialAxis>[
// //             RadialAxis(
// //               startAngle: 140,
// //               endAngle: 40,
// //               minimum: -10,
// //               maximum: 30,
// //               radiusFactor: 0.9,
// //               axisLineStyle: const AxisLineStyle(
// //                 thickness: 12,
// //                 gradient: SweepGradient(
// //                   colors: [Colors.green, Colors.yellow, Colors.red],
// //                   stops: [0.3, 0.7, 1],
// //                 ),
// //               ),
// //               pointers: <GaugePointer>[
// //                 NeedlePointer(
// //                   value: avanen.clamp(-10, 30),
// //                   enableAnimation: true,
// //                   animationType: AnimationType.elasticOut,
// //                   needleColor: Colors.red,
// //                   needleLength: 0.75,
// //                   animationDuration: 1500,
// //                   gradient: const LinearGradient(
// //                     colors: [Colors.white, Colors.red],
// //                   ),
// //                   knobStyle: KnobStyle(
// //                     color: Colors.transparent,
// //                     borderColor: Colors.blue.withAlpha(100),
// //                     borderWidth: 1,
// //                   ),
// //                 ),
// //               ],
// //               annotations: [
// //                 GaugeAnnotation(
// //                   widget: Column(
// //                     children: [
// //                       const SizedBox(height: 180),
// //                       Text(
// //                         "${avanen.toStringAsFixed(0)}°",
// //                         style: const TextStyle(
// //                           fontSize: 45,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.teal,
// //                           shadows: [
// //                             Shadow(color: Colors.white, blurRadius: 20)
// //                           ],
// //                         ),
// //                       ),
// //                       const Text(
// //                         "Avance de Encendido",
// //                         style: TextStyle(fontSize: 18, color: Colors.black),
// //                       ),
// //                     ],
// //                   ),
// //                   angle: 90,
// //                   positionFactor: 0.75,
// //                 ),
// //               ],
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Widget buildCargamotorGauge() {
// //     return ValueListenableBuilder<double>(
// //       valueListenable: _cargaMotorNotifier,
// //       builder: (context, carmotor, child) {
// //         if (carmotor == -1) {
// //           return Center(
// //             child: Text(
// //               "No soportado",
// //               style: TextStyle(
// //                 fontSize: 40,
// //                 color: Colors.red,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           );
// //         }
// //         return SfRadialGauge(
// //           axes: <RadialAxis>[
// //             RadialAxis(
// //               startAngle: 140,
// //               endAngle: 40,
// //               minimum: 0,
// //               maximum: 100,
// //               radiusFactor: 0.9,
// //               majorTickStyle: const MajorTickStyle(
// //                 length: 12,
// //                 thickness: 2,
// //                 color: Colors.black,
// //               ),
// //               minorTicksPerInterval: 4,
// //               minorTickStyle: const MinorTickStyle(
// //                 length: 6,
// //                 thickness: 1,
// //                 color: Colors.grey,
// //               ),
// //               axisLineStyle: const AxisLineStyle(
// //                 thickness: 15,
// //                 gradient: SweepGradient(
// //                   colors: [
// //                     Colors.green,
// //                     Colors.yellow,
// //                     Colors.orange,
// //                     Colors.red,
// //                   ],
// //                   stops: [0.25, 0.5, 0.75, 1],
// //                 ),
// //               ),
// //               axisLabelStyle: const GaugeTextStyle(
// //                 fontSize: 14,
// //                 color: Colors.black,
// //               ),
// //               pointers: <GaugePointer>[
// //                 NeedlePointer(
// //                   value: carmotor,
// //                   enableAnimation: true,
// //                   animationType: AnimationType.easeOutBack,
// //                   needleColor: Colors.red,
// //                   needleStartWidth: 1,
// //                   needleEndWidth: 5,
// //                   needleLength: 0.75,
// //                   animationDuration: 2000,
// //                   gradient: const LinearGradient(
// //                     colors: [
// //                       Colors.white,
// //                       Colors.red,
// //                     ],
// //                   ),
// //                   knobStyle: KnobStyle(
// //                     color: Colors.transparent,
// //                     borderColor: Colors.blue.withAlpha(100),
// //                     borderWidth: 1,
// //                   ),
// //                 ),
// //               ],
// //               ranges: [
// //                 GaugeRange(
// //                   startValue: 0,
// //                   endValue: 25,
// //                   color: Colors.green,
// //                   startWidth: 15,
// //                   endWidth: 15,
// //                 ),
// //                 GaugeRange(
// //                   startValue: 25,
// //                   endValue: 50,
// //                   color: Colors.yellow,
// //                   startWidth: 15,
// //                   endWidth: 15,
// //                 ),
// //                 GaugeRange(
// //                   startValue: 50,
// //                   endValue: 75,
// //                   color: Colors.orange,
// //                   startWidth: 15,
// //                   endWidth: 15,
// //                 ),
// //                 GaugeRange(
// //                   startValue: 75,
// //                   endValue: 100,
// //                   color: Colors.red,
// //                   startWidth: 15,
// //                   endWidth: 15,
// //                 ),
// //               ],
// //               annotations: [
// //                 GaugeAnnotation(
// //                   widget: Column(
// //                     children: [
// //                       const SizedBox(height: 180),
// //                       Text(
// //                         carmotor.toStringAsFixed(0),
// //                         style: const TextStyle(
// //                           fontSize: 50,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.teal,
// //                           shadows: [
// //                             Shadow(
// //                               color: Colors.white,
// //                               blurRadius: 20,
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       const Text(
// //                         "Carga del Motor",
// //                         style: TextStyle(
// //                           fontSize: 18,
// //                           color: Colors.black,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   angle: 90,
// //                   positionFactor: 0.75,
// //                 )
// //               ],
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Widget buildConsumoInsComGauge() {
// //     return ValueListenableBuilder<double>(
// //       valueListenable: _cargaInComNotifier,
// //       builder: (context, conincom, child) {
// //         if (conincom == -1) {
// //           return Center(
// //             child: Text(
// //               "No soportado",
// //               style: TextStyle(
// //                 fontSize: 40,
// //                 color: Colors.red,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           );
// //         }

// //         return SfRadialGauge(
// //           axes: <RadialAxis>[
// //             RadialAxis(
// //               startAngle: 140,
// //               endAngle: 40,
// //               minimum: 0,
// //               maximum: 30, // Ajustado a un rango más realista
// //               radiusFactor: 0.9,
// //               majorTickStyle: const MajorTickStyle(
// //                 length: 10,
// //                 thickness: 2,
// //                 color: Colors.black,
// //               ),
// //               minorTicksPerInterval: 2,
// //               minorTickStyle: const MinorTickStyle(
// //                 length: 5,
// //                 thickness: 1,
// //                 color: Colors.grey,
// //               ),
// //               axisLineStyle: const AxisLineStyle(
// //                 thickness: 12,
// //                 gradient: SweepGradient(
// //                   colors: [
// //                     Colors.green, // Bajo consumo
// //                     Colors.yellow, // Moderado
// //                     Colors.orange, // Alto consumo
// //                     Colors.red, // Excesivo
// //                   ],
// //                   stops: [0.15, 0.35, 0.65, 1],
// //                 ),
// //               ),
// //               axisLabelStyle: const GaugeTextStyle(
// //                 fontSize: 14,
// //                 color: Colors.black,
// //               ),
// //               pointers: <GaugePointer>[
// //                 NeedlePointer(
// //                   value:
// //                       conincom.clamp(0, 30), // Limita valores fuera del rango
// //                   enableAnimation: true,
// //                   animationType: AnimationType.elasticOut,
// //                   needleColor: Colors.red,
// //                   needleStartWidth: 1,
// //                   needleEndWidth: 5,
// //                   needleLength: 0.75,
// //                   animationDuration: 1500,
// //                   gradient: const LinearGradient(
// //                     colors: [Colors.white, Colors.red],
// //                   ),
// //                   knobStyle: KnobStyle(
// //                     color: Colors.transparent,
// //                     borderColor: Colors.blue.withAlpha(100),
// //                     borderWidth: 1,
// //                   ),
// //                 ),
// //               ],
// //               ranges: [
// //                 GaugeRange(
// //                   startValue: 0,
// //                   endValue: 5,
// //                   color: Colors.green,
// //                   startWidth: 12,
// //                   endWidth: 12,
// //                 ),
// //                 GaugeRange(
// //                   startValue: 5,
// //                   endValue: 10,
// //                   color: Colors.yellow,
// //                   startWidth: 12,
// //                   endWidth: 12,
// //                 ),
// //                 GaugeRange(
// //                   startValue: 10,
// //                   endValue: 20,
// //                   color: Colors.orange,
// //                   startWidth: 12,
// //                   endWidth: 12,
// //                 ),
// //                 GaugeRange(
// //                   startValue: 20,
// //                   endValue: 30,
// //                   color: Colors.red,
// //                   startWidth: 12,
// //                   endWidth: 12,
// //                 ),
// //               ],
// //               annotations: [
// //                 GaugeAnnotation(
// //                   widget: Column(
// //                     children: [
// //                       const SizedBox(height: 180),
// //                       Text(
// //                         "${conincom.toStringAsFixed(1)} L/100km",
// //                         style: const TextStyle(
// //                           fontSize: 45,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.teal,
// //                           shadows: [
// //                             Shadow(
// //                               color: Colors.white,
// //                               blurRadius: 20,
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       const Text(
// //                         "Consumo Instantáneo",
// //                         style: TextStyle(
// //                           fontSize: 18,
// //                           color: Colors.black,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   angle: 90,
// //                   positionFactor: 0.75,
// //                 )
// //               ],
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Widget buildFAMGauge() {
// //     return ValueListenableBuilder<double>(
// //       valueListenable: _flujoAirComNotifier,
// //       builder: (context, flujoair, child) {
// //         if (flujoair == -1) {
// //           return Center(
// //             child: Text(
// //               "No soportado",
// //               style: TextStyle(
// //                 fontSize: 40,
// //                 color: Colors.red,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           );
// //         }

// //         return SfRadialGauge(
// //           axes: <RadialAxis>[
// //             RadialAxis(
// //               startAngle: 140,
// //               endAngle: 40,
// //               minimum: 0,
// //               maximum: 100,
// //               radiusFactor: 0.9,
// //               axisLineStyle: const AxisLineStyle(
// //                 thickness: 12,
// //                 gradient: SweepGradient(
// //                   colors: [Colors.green, Colors.yellow, Colors.red],
// //                   stops: [0.3, 0.7, 1],
// //                 ),
// //               ),
// //               pointers: <GaugePointer>[
// //                 NeedlePointer(
// //                   value: flujoair.clamp(0, 300),
// //                   enableAnimation: true,
// //                   animationType: AnimationType.elasticOut,
// //                   needleColor: Colors.red,
// //                   needleLength: 0.75,
// //                   animationDuration: 1500,
// //                   gradient: const LinearGradient(
// //                     colors: [Colors.white, Colors.red],
// //                   ),
// //                   knobStyle: KnobStyle(
// //                     color: Colors.transparent,
// //                     borderColor: Colors.blue.withAlpha(100),
// //                     borderWidth: 1,
// //                   ),
// //                 ),
// //               ],
// //               annotations: [
// //                 GaugeAnnotation(
// //                   widget: Column(
// //                     children: [
// //                       const SizedBox(height: 180),
// //                       Text(
// //                         "${flujoair.toStringAsFixed(0)}%",
// //                         style: const TextStyle(
// //                           fontSize: 45,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.teal,
// //                           shadows: [
// //                             Shadow(color: Colors.white, blurRadius: 20)
// //                           ],
// //                         ),
// //                       ),
// //                       const Text(
// //                         "Flujo aire masivo",
// //                         style: TextStyle(fontSize: 18, color: Colors.black),
// //                       ),
// //                     ],
// //                   ),
// //                   angle: 90,
// //                   positionFactor: 0.75,
// //                 ),
// //               ],
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Widget buildPBGauge() {
// //     return ValueListenableBuilder<double>(
// //       valueListenable: _presBaromNotifier,
// //       builder: (context, presbarom, child) {
// //         if (presbarom == -1) {
// //           return Center(
// //             child: Text(
// //               "No soportado",
// //               style: TextStyle(
// //                 fontSize: 40,
// //                 color: Colors.red,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           );
// //         }

// //         return SfRadialGauge(
// //           axes: <RadialAxis>[
// //             RadialAxis(
// //               startAngle: 140,
// //               endAngle: 40,
// //               minimum: 0,
// //               maximum: 120,
// //               radiusFactor: 0.9,
// //               axisLineStyle: const AxisLineStyle(
// //                 thickness: 12,
// //                 gradient: SweepGradient(
// //                   colors: [Colors.green, Colors.yellow, Colors.red],
// //                   stops: [0.3, 0.7, 1],
// //                 ),
// //               ),
// //               pointers: <GaugePointer>[
// //                 NeedlePointer(
// //                   value: presbarom.clamp(0, 120),
// //                   enableAnimation: true,
// //                   animationType: AnimationType.elasticOut,
// //                   needleColor: Colors.red,
// //                   needleLength: 0.75,
// //                   animationDuration: 1500,
// //                   gradient: const LinearGradient(
// //                     colors: [Colors.white, Colors.red],
// //                   ),
// //                   knobStyle: KnobStyle(
// //                     color: Colors.transparent,
// //                     borderColor: Colors.blue.withAlpha(100),
// //                     borderWidth: 1,
// //                   ),
// //                 ),
// //               ],
// //               annotations: [
// //                 GaugeAnnotation(
// //                   widget: Column(
// //                     children: [
// //                       const SizedBox(height: 180),
// //                       Text(
// //                         "${presbarom.toStringAsFixed(0)} g/s",
// //                         style: const TextStyle(
// //                           fontSize: 45,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.teal,
// //                           shadows: [
// //                             Shadow(color: Colors.white, blurRadius: 20)
// //                           ],
// //                         ),
// //                       ),
// //                       const Text(
// //                         "Presion Barometrica",
// //                         style: TextStyle(fontSize: 18, color: Colors.black),
// //                       ),
// //                     ],
// //                   ),
// //                   angle: 90,
// //                   positionFactor: 0.75,
// //                 ),
// //               ],
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Widget buildPresColAdmGauge() {
// //     return ValueListenableBuilder<double>(
// //       valueListenable: _presColAdmiNotifier,
// //       builder: (context, prescoladm, child) {
// //         if (prescoladm == -1) {
// //           return Center(
// //             child: Text(
// //               "No soportado",
// //               style: TextStyle(
// //                 fontSize: 40,
// //                 color: Colors.red,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           );
// //         }

// //         return SfRadialGauge(
// //           axes: <RadialAxis>[
// //             RadialAxis(
// //               startAngle: 140,
// //               endAngle: 40,
// //               minimum: 20, // 🔹 Rango realista
// //               maximum: 250, // 🔹 MAP puede llegar a 250 kPa en motores turbo
// //               radiusFactor: 0.9,
// //               axisLineStyle: const AxisLineStyle(
// //                 thickness: 12,
// //                 gradient: SweepGradient(
// //                   colors: [Colors.green, Colors.yellow, Colors.red],
// //                   stops: [0.3, 0.7, 1],
// //                 ),
// //               ),
// //               pointers: <GaugePointer>[
// //                 NeedlePointer(
// //                   value: prescoladm.clamp(20, 250),
// //                   enableAnimation: true,
// //                   animationType: AnimationType.elasticOut,
// //                   needleColor: Colors.red,
// //                   needleLength: 0.75,
// //                   animationDuration: 1500,
// //                   gradient: const LinearGradient(
// //                     colors: [Colors.white, Colors.red],
// //                   ),
// //                   knobStyle: KnobStyle(
// //                     color: Colors.transparent,
// //                     borderColor: Colors.blue.withAlpha(100),
// //                     borderWidth: 1,
// //                   ),
// //                 ),
// //               ],
// //               annotations: [
// //                 GaugeAnnotation(
// //                   widget: Column(
// //                     children: [
// //                       const SizedBox(height: 180),
// //                       Text(
// //                         "${prescoladm.toStringAsFixed(0)} kPa",
// //                         style: const TextStyle(
// //                           fontSize: 45,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.teal,
// //                           shadows: [
// //                             Shadow(color: Colors.white, blurRadius: 20)
// //                           ],
// //                         ),
// //                       ),
// //                       const Text(
// //                         "Presión Colector Admisión",
// //                         style: TextStyle(fontSize: 18, color: Colors.black),
// //                       ),
// //                     ],
// //                   ),
// //                   angle: 90,
// //                   positionFactor: 0.75,
// //                 ),
// //               ],
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Widget buildPresComGauge() {
// //     return ValueListenableBuilder<double>(
// //       valueListenable: _presComNotifier,
// //       builder: (context, prescom, child) {
// //         if (prescom == -1) {
// //           return Center(
// //             child: Text(
// //               "No soportado",
// //               style: TextStyle(
// //                 fontSize: 40,
// //                 color: Colors.red,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           );
// //         }

// //         return SfRadialGauge(
// //           axes: <RadialAxis>[
// //             RadialAxis(
// //               startAngle: 140,
// //               endAngle: 40,
// //               minimum: 0,
// //               maximum: 500,
// //               radiusFactor: 0.9,
// //               axisLineStyle: const AxisLineStyle(
// //                 thickness: 12,
// //                 gradient: SweepGradient(
// //                   colors: [Colors.red, Colors.yellow, Colors.green],
// //                   stops: [0.3, 0.7, 1],
// //                 ),
// //               ),
// //               pointers: <GaugePointer>[
// //                 NeedlePointer(
// //                   value: prescom.clamp(0, 500),
// //                   enableAnimation: true,
// //                   animationType: AnimationType.elasticOut,
// //                   needleColor: Colors.red,
// //                   needleLength: 0.75,
// //                   animationDuration: 1500,
// //                   gradient: const LinearGradient(
// //                     colors: [Colors.white, Colors.red],
// //                   ),
// //                   knobStyle: KnobStyle(
// //                     color: Colors.transparent,
// //                     borderColor: Colors.blue.withAlpha(100),
// //                     borderWidth: 1,
// //                   ),
// //                 ),
// //               ],
// //               annotations: [
// //                 GaugeAnnotation(
// //                   widget: Column(
// //                     children: [
// //                       const SizedBox(height: 180),
// //                       Text(
// //                         "${prescom.toStringAsFixed(0)} kPa",
// //                         style: const TextStyle(
// //                           fontSize: 45,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.teal,
// //                           shadows: [
// //                             Shadow(color: Colors.white, blurRadius: 20)
// //                           ],
// //                         ),
// //                       ),
// //                       const Text(
// //                         "Presión de Combustible",
// //                         style: TextStyle(fontSize: 18, color: Colors.black),
// //                       ),
// //                     ],
// //                   ),
// //                   angle: 90,
// //                   positionFactor: 0.75,
// //                 ),
// //               ],
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// Widget buildRpmGauge() {
//   return ValueListenableBuilder<double>(
//     valueListenable: _rpmNotifier,
//     builder: (context, rpm, child) {
//       if (rpm == -1) {
//         return Center(
//           child: Text(
//             "No soportado",
//             style: TextStyle(
//               fontSize: 40,
//               color: Colors.red,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         );
//       }
//       return SfRadialGauge(
//         axes: <RadialAxis>[
//           RadialAxis(
//             startAngle: 140,
//             endAngle: 40,
//             minimum: 0,
//             maximum: 8000,
//             radiusFactor: 0.9,
//             majorTickStyle: const MajorTickStyle(
//               length: 12,
//               thickness: 2,
//               color: Colors.black,
//             ),
//             minorTicksPerInterval: 4,
//             minorTickStyle: const MinorTickStyle(
//               length: 6,
//               thickness: 1,
//               color: Colors.grey,
//             ),
//             axisLineStyle: const AxisLineStyle(
//               thickness: 15,
//               gradient: SweepGradient(
//                 colors: [
//                   Colors.green,
//                   Colors.yellow,
//                   Colors.orange,
//                   Colors.red,
//                 ],
//                 stops: [0.25, 0.5, 0.75, 1],
//               ),
//             ),
//             axisLabelStyle: const GaugeTextStyle(
//               fontSize: 14,
//               color: Colors.black,
//             ),
//             pointers: <GaugePointer>[
//               NeedlePointer(
//                 value: rpm,
//                 enableAnimation: true,
//                 animationType: AnimationType.easeOutBack,
//                 needleColor: Colors.red,
//                 needleStartWidth: 1,
//                 needleEndWidth: 5,
//                 needleLength: 0.75,
//                 animationDuration: 2000,
//                 gradient: const LinearGradient(
//                   colors: [
//                     Colors.white,
//                     Colors.red,
//                   ],
//                 ),
//                 knobStyle: KnobStyle(
//                   color: Colors.transparent,
//                   borderColor: Colors.blue.withAlpha(100),
//                   borderWidth: 1,
//                 ),
//               ),
//             ],
//             ranges: [
//               GaugeRange(
//                 startValue: 0,
//                 endValue: 2000,
//                 color: Colors.green,
//                 startWidth: 15,
//                 endWidth: 15,
//               ),
//               GaugeRange(
//                 startValue: 2000,
//                 endValue: 5000,
//                 color: Colors.yellow,
//                 startWidth: 15,
//                 endWidth: 15,
//               ),
//               GaugeRange(
//                 startValue: 5000,
//                 endValue: 7000,
//                 color: Colors.orange,
//                 startWidth: 15,
//                 endWidth: 15,
//               ),
//               GaugeRange(
//                 startValue: 7000,
//                 endValue: 8000,
//                 color: Colors.red,
//                 startWidth: 15,
//                 endWidth: 15,
//               ),
//             ],
//             annotations: [
//               GaugeAnnotation(
//                 widget: Column(
//                   children: [
//                     const SizedBox(height: 180),
//                     Text(rpm.toStringAsFixed(0),
//                         style: TextStyle(
//                           fontSize: 50,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.teal,
//                           shadows: [
//                             Shadow(
//                               color: Colors.white,
//                               blurRadius: 20,
//                             ),
//                           ],
//                         )),
//                     const Text(
//                       "RPM",
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//                 angle: 90,
//                 positionFactor: 0.75,
//               )
//             ],
//           ),
//         ],
//       );
//     },
//   );
// }

// //   Widget buildTempAceiteGauge() {
// //     return ValueListenableBuilder<double>(
// //       valueListenable: _tempAceNotifier,
// //       builder: (context, tempace, child) {
// //         if (tempace == -1) {
// //           return Center(
// //             child: Text(
// //               "No soportado",
// //               style: TextStyle(
// //                 fontSize: 40,
// //                 color: Colors.red,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           );
// //         }
// //         return SfRadialGauge(
// //           axes: <RadialAxis>[
// //             RadialAxis(
// //               startAngle: 140,
// //               endAngle: 40,
// //               minimum: 0,
// //               maximum: 150,
// //               radiusFactor: 0.9,
// //               axisLineStyle: const AxisLineStyle(
// //                 thickness: 12,
// //                 gradient: SweepGradient(
// //                   colors: [Colors.green, Colors.yellow, Colors.red],
// //                   stops: [0.3, 0.7, 1],
// //                 ),
// //               ),
// //               pointers: <GaugePointer>[
// //                 NeedlePointer(
// //                   value: tempace.clamp(20, 250),
// //                   enableAnimation: true,
// //                   animationType: AnimationType.elasticOut,
// //                   needleColor: Colors.red,
// //                   needleLength: 0.75,
// //                   animationDuration: 1500,
// //                   gradient: const LinearGradient(
// //                     colors: [Colors.white, Colors.red],
// //                   ),
// //                   knobStyle: KnobStyle(
// //                     color: Colors.transparent,
// //                     borderColor: Colors.blue.withAlpha(100),
// //                     borderWidth: 1,
// //                   ),
// //                 ),
// //               ],
// //               annotations: [
// //                 GaugeAnnotation(
// //                   widget: Column(
// //                     children: [
// //                       const SizedBox(height: 180),
// //                       Text(
// //                         "${tempace.toStringAsFixed(0)} C°",
// //                         style: const TextStyle(
// //                           fontSize: 45,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.teal,
// //                           shadows: [
// //                             Shadow(color: Colors.white, blurRadius: 20)
// //                           ],
// //                         ),
// //                       ),
// //                       const Text(
// //                         "Temperatura del aceite",
// //                         style: TextStyle(fontSize: 18, color: Colors.black),
// //                       ),
// //                     ],
// //                   ),
// //                   angle: 90,
// //                   positionFactor: 0.75,
// //                 ),
// //               ],
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Widget buildTempRefGauge() {
// //     return ValueListenableBuilder<double>(
// //       valueListenable: _tempRefNotifier,
// //       builder: (context, tempref, child) {
// //         if (tempref == -1) {
// //           return Center(
// //             child: Text(
// //               "No soportado",
// //               style: TextStyle(
// //                 fontSize: 40,
// //                 color: Colors.red,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           );
// //         }
// //         return SfRadialGauge(
// //           axes: <RadialAxis>[
// //             RadialAxis(
// //               startAngle: 140,
// //               endAngle: 40,
// //               minimum: 40,
// //               maximum: 150,
// //               radiusFactor: 0.9,
// //               axisLineStyle: const AxisLineStyle(
// //                 thickness: 12,
// //                 gradient: SweepGradient(
// //                   colors: [Colors.green, Colors.yellow, Colors.red],
// //                   stops: [0.3, 0.7, 1],
// //                 ),
// //               ),
// //               pointers: <GaugePointer>[
// //                 NeedlePointer(
// //                   value: tempref.clamp(20, 250),
// //                   enableAnimation: true,
// //                   animationType: AnimationType.elasticOut,
// //                   needleColor: Colors.red,
// //                   needleLength: 0.75,
// //                   animationDuration: 1500,
// //                   gradient: const LinearGradient(
// //                     colors: [Colors.white, Colors.red],
// //                   ),
// //                   knobStyle: KnobStyle(
// //                     color: Colors.transparent,
// //                     borderColor: Colors.blue.withAlpha(100),
// //                     borderWidth: 1,
// //                   ),
// //                 ),
// //               ],
// //               annotations: [
// //                 GaugeAnnotation(
// //                   widget: Column(
// //                     children: [
// //                       const SizedBox(height: 180),
// //                       Text(
// //                         "${tempref.toStringAsFixed(0)} C°",
// //                         style: const TextStyle(
// //                           fontSize: 45,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.teal,
// //                           shadows: [
// //                             Shadow(color: Colors.white, blurRadius: 20)
// //                           ],
// //                         ),
// //                       ),
// //                       const Text(
// //                         "Temperatura refrigerante",
// //                         style: TextStyle(fontSize: 18, color: Colors.black),
// //                       ),
// //                     ],
// //                   ),
// //                   angle: 90,
// //                   positionFactor: 0.75,
// //                 ),
// //               ],
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Widget buildTieEncGauge() {
// //     return ValueListenableBuilder<double>(
// //       valueListenable: _tiemEncNotifier,
// //       builder: (context, tiempen, child) {
// //         if (tiempen == -11) {
// //           return Center(
// //             child: Text(
// //               "No soportado",
// //               style: TextStyle(
// //                 fontSize: 40,
// //                 color: Colors.red,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           );
// //         }
// //         return SfRadialGauge(
// //           axes: <RadialAxis>[
// //             RadialAxis(
// //               startAngle: 140,
// //               endAngle: 40,
// //               minimum: -10,
// //               maximum: 50,
// //               radiusFactor: 0.9,
// //               majorTickStyle: const MajorTickStyle(
// //                 length: 12,
// //                 thickness: 2,
// //                 color: Colors.black,
// //               ),
// //               minorTicksPerInterval: 4,
// //               minorTickStyle: const MinorTickStyle(
// //                 length: 6,
// //                 thickness: 1,
// //                 color: Colors.grey,
// //               ),
// //               axisLineStyle: const AxisLineStyle(
// //                 thickness: 12,
// //                 gradient: SweepGradient(
// //                   colors: [Colors.green, Colors.yellow, Colors.red],
// //                   stops: [0.3, 0.7, 1],
// //                 ),
// //               ),
// //               axisLabelStyle: const GaugeTextStyle(
// //                 fontSize: 14,
// //                 color: Colors.black,
// //               ),
// //               pointers: <GaugePointer>[
// //                 NeedlePointer(
// //                   value: tiempen.clamp(0, 50),
// //                   enableAnimation: true,
// //                   animationType: AnimationType.easeOutBack,
// //                   needleColor: Colors.red,
// //                   needleStartWidth: 1,
// //                   needleEndWidth: 5,
// //                   needleLength: 0.75,
// //                   animationDuration: 2000,
// //                   gradient: const LinearGradient(
// //                     colors: [
// //                       Colors.white,
// //                       Colors.red,
// //                     ],
// //                   ),
// //                   knobStyle: KnobStyle(
// //                     color: Colors.transparent,
// //                     borderColor: Colors.blue.withAlpha(100),
// //                     borderWidth: 1,
// //                   ),
// //                 ),
// //               ],
// //               annotations: [
// //                 GaugeAnnotation(
// //                   widget: Column(
// //                     children: [
// //                       const SizedBox(height: 180),
// //                       Text(
// //                         "${tiempen.toStringAsFixed(0)} °",
// //                         style: TextStyle(
// //                           fontSize: 50,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.teal,
// //                           shadows: [
// //                             Shadow(
// //                               color: Colors.white,
// //                               blurRadius: 20,
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       const Text(
// //                         "Tiempo de funcionamiento",
// //                         style: TextStyle(
// //                           fontSize: 18,
// //                           color: Colors.black,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   angle: 90,
// //                   positionFactor: 0.75,
// //                 )
// //               ],
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Widget buildVAGauge() {
// //     return ValueListenableBuilder<double>(
// //       valueListenable: _valvAdmNotifier,
// //       builder: (context, valvAdm, child) {
// //         if (valvAdm == -1) {
// //           return Center(
// //             child: Text(
// //               "No soportado",
// //               style: TextStyle(
// //                 fontSize: 40,
// //                 color: Colors.red,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           );
// //         }

// //         return SfRadialGauge(
// //           axes: <RadialAxis>[
// //             RadialAxis(
// //               startAngle: 140,
// //               endAngle: 40,
// //               minimum: 0,
// //               maximum: 100,
// //               radiusFactor: 0.9,
// //               axisLineStyle: const AxisLineStyle(
// //                 thickness: 12,
// //                 gradient: SweepGradient(
// //                   colors: [Colors.green, Colors.yellow, Colors.red],
// //                   stops: [0.3, 0.7, 1],
// //                 ),
// //               ),
// //               pointers: <GaugePointer>[
// //                 NeedlePointer(
// //                   value: valvAdm.clamp(0, 100),
// //                   enableAnimation: true,
// //                   animationType: AnimationType.elasticOut,
// //                   needleColor: Colors.red,
// //                   needleLength: 0.75,
// //                   animationDuration: 1500,
// //                   gradient: const LinearGradient(
// //                     colors: [Colors.white, Colors.red],
// //                   ),
// //                   knobStyle: KnobStyle(
// //                     color: Colors.transparent,
// //                     borderColor: Colors.blue.withAlpha(100),
// //                     borderWidth: 1,
// //                   ),
// //                 ),
// //               ],
// //               annotations: [
// //                 GaugeAnnotation(
// //                   widget: Column(
// //                     children: [
// //                       const SizedBox(height: 180),
// //                       Text(
// //                         "${valvAdm.toStringAsFixed(0)}%",
// //                         style: const TextStyle(
// //                           fontSize: 45,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.teal,
// //                           shadows: [
// //                             Shadow(color: Colors.white, blurRadius: 20)
// //                           ],
// //                         ),
// //                       ),
// //                       const Text(
// //                         "Valvula admision",
// //                         style: TextStyle(fontSize: 18, color: Colors.black),
// //                       ),
// //                     ],
// //                   ),
// //                   angle: 90,
// //                   positionFactor: 0.75,
// //                 ),
// //               ],
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// Widget buildSpeedGauge() {
//   return ValueListenableBuilder<double>(
//     valueListenable: _velocidadNotifier,
//     builder: (context, velocidad, child) {
//       if (velocidad == -1) {
//         return Center(
//           child: Text(
//             "No soportado",
//             style: TextStyle(
//               fontSize: 40,
//               color: Colors.red,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         );
//       }
//       return SfRadialGauge(
//         axes: <RadialAxis>[
//           RadialAxis(
//             startAngle: 140,
//             endAngle: 40,
//             minimum: 0,
//             maximum: 240,
//             radiusFactor: 0.9,
//             majorTickStyle: const MajorTickStyle(
//               length: 12,
//               thickness: 2,
//               color: Colors.black,
//             ),
//             minorTicksPerInterval: 4,
//             minorTickStyle: const MinorTickStyle(
//               length: 6,
//               thickness: 1,
//               color: Colors.grey,
//             ),
//             axisLineStyle: const AxisLineStyle(
//               thickness: 15,
//               gradient: SweepGradient(
//                 colors: [
//                   Colors.green,
//                   Colors.yellow,
//                   Colors.orange,
//                   Colors.red,
//                 ],
//                 stops: [0.25, 0.5, 0.75, 1],
//               ),
//             ),
//             axisLabelStyle: const GaugeTextStyle(
//               fontSize: 14,
//               color: Colors.black,
//             ),
//             pointers: <GaugePointer>[
//               NeedlePointer(
//                 value: velocidad,
//                 enableAnimation: true,
//                 animationType: AnimationType.easeOutBack,
//                 needleColor: Colors.red,
//                 needleStartWidth: 1,
//                 needleEndWidth: 5,
//                 needleLength: 0.75,
//                 animationDuration: 2000,
//                 gradient: const LinearGradient(
//                   colors: [
//                     Colors.white,
//                     Colors.red,
//                   ],
//                 ),
//                 knobStyle: KnobStyle(
//                   color: Colors.transparent,
//                   borderColor: Colors.blue.withAlpha(100),
//                   borderWidth: 1,
//                 ),
//               ),
//             ],
//             ranges: [
//               GaugeRange(
//                 startValue: 0,
//                 endValue: 30,
//                 color: Colors.pink,
//                 startWidth: 15,
//                 endWidth: 15,
//               ),
//               GaugeRange(
//                 startValue: 30,
//                 endValue: 80,
//                 color: Colors.green,
//                 startWidth: 15,
//                 endWidth: 15,
//               ),
//               GaugeRange(
//                 startValue: 80,
//                 endValue: 160,
//                 color: Colors.amber,
//                 startWidth: 15,
//                 endWidth: 15,
//               ),
//               GaugeRange(
//                 startValue: 160,
//                 endValue: 240,
//                 color: Colors.red,
//                 startWidth: 15,
//                 endWidth: 15,
//               ),
//             ],
//             annotations: [
//               GaugeAnnotation(
//                 widget: Column(
//                   children: [
//                     const SizedBox(height: 180),
//                     Text(
//                       velocidad.toStringAsFixed(0),
//                       style: const TextStyle(
//                         fontSize: 50,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.teal,
//                         shadows: [
//                           Shadow(
//                             color: Colors.white,
//                             blurRadius: 20,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const Text(
//                       "km/h",
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//                 angle: 90,
//                 positionFactor: 0.75,
//               )
//             ],
//           ),
//         ],
//       );
//     },
//   );
// }

// //   Widget buildVoltajeGauge() {
// //     return ValueListenableBuilder<double>(
// //       valueListenable: _voltajeNotifier,
// //       builder: (context, voltaje, child) {
// //         if (voltaje == -1) {
// //           return Center(
// //             child: Text(
// //               "No soportado",
// //               style: TextStyle(
// //                 fontSize: 40,
// //                 color: Colors.red,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           );
// //         }
// //         return SfRadialGauge(
// //           axes: <RadialAxis>[
// //             RadialAxis(
// //               startAngle: 140,
// //               endAngle: 40,
// //               minimum: 6,
// //               maximum: 20,
// //               radiusFactor: 0.9,
// //               majorTickStyle: const MajorTickStyle(
// //                 length: 12,
// //                 thickness: 2,
// //                 color: Colors.black,
// //               ),
// //               minorTicksPerInterval: 4,
// //               minorTickStyle: const MinorTickStyle(
// //                 length: 6,
// //                 thickness: 1,
// //                 color: Colors.grey,
// //               ),
// //               axisLineStyle: const AxisLineStyle(
// //                 thickness: 15,
// //                 gradient: SweepGradient(
// //                   colors: [
// //                     Colors.red,
// //                     Colors.green,
// //                     Colors.red,
// //                   ],
// //                   stops: [1, 1, 1],
// //                 ),
// //               ),
// //               axisLabelStyle: const GaugeTextStyle(
// //                 fontSize: 14,
// //                 color: Colors.black,
// //               ),
// //               pointers: <GaugePointer>[
// //                 NeedlePointer(
// //                   value: voltaje,
// //                   enableAnimation: true,
// //                   animationType: AnimationType.easeOutBack,
// //                   needleColor: Colors.red,
// //                   needleStartWidth: 1,
// //                   needleEndWidth: 5,
// //                   needleLength: 0.75,
// //                   animationDuration: 2000,
// //                   gradient: const LinearGradient(
// //                     colors: [
// //                       Colors.white,
// //                       Colors.red,
// //                     ],
// //                   ),
// //                   knobStyle: KnobStyle(
// //                     color: Colors.transparent,
// //                     borderColor: Colors.blue.withAlpha(100),
// //                     borderWidth: 1,
// //                   ),
// //                 ),
// //               ],
// //               ranges: [
// //                 GaugeRange(
// //                   startValue: 6,
// //                   endValue: 11,
// //                   color: Colors.red,
// //                   startWidth: 15,
// //                   endWidth: 15,
// //                 ),
// //                 GaugeRange(
// //                   startValue: 11,
// //                   endValue: 15,
// //                   color: Colors.green,
// //                   startWidth: 15,
// //                   endWidth: 15,
// //                 ),
// //                 GaugeRange(
// //                   startValue: 15,
// //                   endValue: 20,
// //                   color: Colors.red,
// //                   startWidth: 15,
// //                   endWidth: 15,
// //                 ),
// //               ],
// //               annotations: [
// //                 GaugeAnnotation(
// //                   widget: Column(
// //                     children: [
// //                       const SizedBox(height: 180),
// //                       Text("${voltaje.toDouble()} V",
// //                           style: TextStyle(
// //                             fontSize: 50,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.teal,
// //                             shadows: [
// //                               Shadow(
// //                                 color: Colors.white,
// //                                 blurRadius: 20,
// //                               ),
// //                             ],
// //                           )),
// //                       const Text(
// //                         "Voltaje",
// //                         style: TextStyle(
// //                           fontSize: 18,
// //                           color: Colors.black,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   angle: 90,
// //                   positionFactor: 0.75,
// //                 )
// //               ],
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color.fromARGB(255, 188, 188, 188),
// //       appBar: AppBar(
// //         backgroundColor: colorPrimary,
// //         title: const Text(
// //           "Dashboard",
// //           style: TextStyle(
// //             fontSize: 24,
// //             color: Colors.white,
// //           ),
// //         ),
// //         actions: <Widget>[
// //           IconButton(
// //             icon: const Icon(Icons.settings),
// //             onPressed: () {},
// //           ),
// //         ],
// //       ),
// //       body: SafeArea(
// //         child: Column(
// //           children: [
// //             Padding(
// //               padding:
// //                   const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
// //               child: Container(
// //                 padding: const EdgeInsets.symmetric(horizontal: 16),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(12),
// //                   border: Border.all(
// //                       color: Colors.blueAccent, width: 2),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.black26,
// //                       blurRadius: 4,
// //                       offset: Offset(2, 2),
// //                     ),
// //                   ],
// //                 ),
// //                 child: DropdownButton<String>(
// //                   value: selectedMetric,
// //                   items: <String>[
// //                     'Avance encendido',
// //                     'Carga del motor',
// //                     'Consumo instantáneo combustible',
// //                     'Flujo aire masivo',
// //                     'Presion barometrica',
// //                     'Presión colector admisión',
// //                     'Presión combustible',
// //                     'RPM',
// //                     'Temperatura aceite',
// //                     'Temperatura refrigerante',
// //                     'Tiempo de funcionamiento',
// //                     'Valvula admision',
// //                     'Velocidad',
// //                     'Voltaje',
// //                   ]
// //                       .map((String value) => DropdownMenuItem<String>(
// //                             value: value,
// //                             child: Text(
// //                               value,
// //                               style: const TextStyle(
// //                                 fontSize: 16,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.black87,
// //                               ),
// //                             ),
// //                           ))
// //                       .toList(),
// //                   onChanged: (String? newValue) {
// //                     setState(() {
// //                       selectedMetric = newValue!;
// //                     });
// //                   },
// //                   isExpanded: true,
// //                   underline: Container(),
// //                   icon: const Icon(
// //                     Icons.arrow_drop_down,
// //                     color: Colors.blueAccent,
// //                     size: 28,
// //                   ),
// //                   dropdownColor: Colors.white,
// //                 ),
// //               ),
// //             ),
// //             Expanded(
// //               child: Center(
// //                 child: buildGauge(),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';

// class SpeedometerPage extends StatelessWidget {
//   final double value;
//   final String title;
//   final String unit;
//   final double maxValue;

//   const SpeedometerPage({
//     super.key,
//     required this.value,
//     required this.title,
//     required this.unit,
//     required this.maxValue,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.black.withOpacity(0.9),
//       insetPadding: const EdgeInsets.all(20),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 24,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close, color: Colors.white),
//                   onPressed: () => Navigator.of(context).pop(),
//                 ),
//               ],
//             ),
//             SizedBox(
//               width: 300,
//               height: 300,
//               child: SfRadialGauge(
//                 axes: <RadialAxis>[
//                   RadialAxis(
//                     startAngle: 140,
//                     endAngle: 40,
//                     minimum: 0,
//                     maximum: maxValue,
//                     radiusFactor: 0.9,
//                     majorTickStyle: const MajorTickStyle(
//                       length: 12,
//                       thickness: 2,
//                       color: Colors.black,
//                     ),
//                     minorTicksPerInterval: 4,
//                     minorTickStyle: const MinorTickStyle(
//                       length: 6,
//                       thickness: 1,
//                       color: Colors.grey,
//                     ),
//                     axisLineStyle: const AxisLineStyle(
//                       thickness: 15,
//                       gradient: SweepGradient(
//                         colors: [
//                           Colors.green,
//                           Colors.yellow,
//                           Colors.orange,
//                           Colors.red,
//                         ],
//                         stops: [0.25, 0.5, 0.75, 1],
//                       ),
//                     ),
//                     pointers: <GaugePointer>[
//                       NeedlePointer(
//                         value: value.clamp(0, maxValue),
//                         enableAnimation: true,
//                         animationType: AnimationType.easeOutBack,
//                         needleColor: Colors.red,
//                         needleStartWidth: 1,
//                         needleEndWidth: 5,
//                         needleLength: 0.75,
//                         animationDuration: 2000,
//                         gradient: const LinearGradient(
//                           colors: [Colors.white, Colors.red],
//                         ),
//                         knobStyle: KnobStyle(
//                           color: Colors.transparent,
//                           borderColor: Colors.blue.withAlpha(100),
//                           borderWidth: 1,
//                         ),
//                       ),
//                     ],
//                     ranges: [
//                       GaugeRange(
//                         startValue: 0,
//                         endValue: 30,
//                         color: Colors.pink,
//                         startWidth: 15,
//                         endWidth: 15,
//                       ),
//                       GaugeRange(
//                         startValue: 30,
//                         endValue: 80,
//                         color: Colors.green,
//                         startWidth: 15,
//                         endWidth: 15,
//                       ),
//                       GaugeRange(
//                         startValue: 80,
//                         endValue: 160,
//                         color: Colors.amber,
//                         startWidth: 15,
//                         endWidth: 15,
//                       ),
//                       GaugeRange(
//                         startValue: 160,
//                         endValue: 240,
//                         color: Colors.red,
//                         startWidth: 15,
//                         endWidth: 15,
//                       ),
//                     ],
//                     annotations: <GaugeAnnotation>[
//                       GaugeAnnotation(
//                         widget: Column(
//                           children: [
//                             const SizedBox(height: 180),
//                             Text(
//                               value.toStringAsFixed(0),
//                               style: const TextStyle(
//                                 fontSize: 50,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.teal,
//                                 shadows: [
//                                   Shadow(
//                                     color: Colors.white,
//                                     blurRadius: 20,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Text(
//                               unit,
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ],
//                         ),
//                         angle: 90,
//                         positionFactor: 0.75,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:obdv2/core/constants.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GaugeConfig {
  final double maxValue;
  final double minValue;
  final List<GaugeRange> ranges;
  final String unit;
  final SweepGradient gradient;
  final Color needleColor;

  GaugeConfig({
    required this.maxValue,
    required this.minValue,
    required this.ranges,
    required this.unit,
    required this.gradient,
    this.needleColor = Colors.red,
  });
}

class SpeedometerPage extends StatelessWidget {
  final double value;
  final String title;
  final GaugeConfig config;

  const SpeedometerPage({
    super.key,
    required this.value,
    required this.title,
    required this.config,
  });

   Color _getValueColor(double value, List<GaugeRange> ranges) {
    // Ordenar los rangos por valor inicial
    final sortedRanges = List<GaugeRange>.from(ranges)
      ..sort((a, b) => a.startValue.compareTo(b.startValue));

    for (final range in sortedRanges) {
      if (value >= range.startValue && value <= range.endValue) {
        return range.color ?? Colors.white; // Usamos operador null-coalescing
      }
    }
    return Colors.white; // Valor por defecto
  }

  factory SpeedometerPage.speedometer({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Velocidad',
      config: GaugeConfig(
        maxValue: 240,
        minValue: 0,
        unit: 'km/h',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 60,
            color: Colors.pink,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 60,
            endValue: 120,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 120,
            endValue: 180,
            color: Colors.amber,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 180,
            endValue: 240,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }

  factory SpeedometerPage.rpm({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'RPM',
      config: GaugeConfig(
        maxValue: 8000,
        minValue: 0,
        unit: 'RPM',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 2000,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 2000,
            endValue: 4000,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 4000,
            endValue: 6000,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 6000,
            endValue: 8000,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.tempR({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Temp. Refrigerante',
      config: GaugeConfig(
        maxValue: 105,
        minValue: 0,
        unit: '°',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 30,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 30,
            endValue: 60,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 60,
            endValue: 90,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 90,
            endValue: 105,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.cargaMotor({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Carga del motor',
      config: GaugeConfig(
        maxValue: 100,
        minValue: 0,
        unit: '%',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 25,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 25,
            endValue: 50,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 50,
            endValue: 75,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 75,
            endValue: 100,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.avanceEncentido({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Avance encendido',
      config: GaugeConfig(
        maxValue: 40,
        minValue: -10,
        unit: '°',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: -10,
            endValue: 0,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 0,
            endValue: 15,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 15,
            endValue: 30,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 30,
            endValue: 40,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.flujoAir({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Flujo aire masivo',
      config: GaugeConfig(
        maxValue: 20,
        minValue: 0,
        unit: '°',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 5,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 5,
            endValue: 10,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 10,
            endValue: 15,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 15,
            endValue: 20,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.presionCA({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Presión colector \nadmisión',
      config: GaugeConfig(
        maxValue: 100,
        minValue: 0,
        unit: 'kPa',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 25,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 25,
            endValue: 50,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 50,
            endValue: 75,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 75,
            endValue: 100,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.voltaje({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Voltaje',
      config: GaugeConfig(
        maxValue: 25,
        minValue: 0,
        unit: 'V',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 11,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 11,
            endValue: 13,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 13,
            endValue: 14,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 14,
            endValue: 25,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.sensorO21V({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Sensor O2 1 (V) [0]',
      config: GaugeConfig(
        maxValue: 0.9,
        minValue: 0,
        unit: 'V',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 0.3,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 0.3,
            endValue: 0.5,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 0.5,
            endValue: 0.6,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 0.6,
            endValue: 0.9,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.sensorO21AFR({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Sensor O2 1 (AFR) [0]',
      config: GaugeConfig(
        maxValue: 16,
        minValue: 0,
        unit: 'V',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 4,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 4,
            endValue: 8,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 8,
            endValue: 12,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 12,
            endValue: 16,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.sensorO22V({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Sensor O2 2 (V) [1]',
      config: GaugeConfig(
        maxValue: 0.9,
        minValue: 0,
        unit: 'V',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 0.3,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 0.3,
            endValue: 0.5,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 0.5,
            endValue: 0.6,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 0.6,
            endValue: 0.9,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.sensorO22AFR({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Sensor O2 2 (AFR) [1]',
      config: GaugeConfig(
        maxValue: 16,
        minValue: 0,
        unit: 'V',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 4,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 4,
            endValue: 8,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 8,
            endValue: 12,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 12,
            endValue: 16,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.sensorO23V({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Sensor O2 3 (V) [2]',
      config: GaugeConfig(
        maxValue: 0.9,
        minValue: 0,
        unit: 'V',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 0.3,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 0.3,
            endValue: 0.5,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 0.5,
            endValue: 0.6,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 0.6,
            endValue: 0.9,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.sensorO23AFR({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Sensor O2 3 (AFR) [2]',
      config: GaugeConfig(
        maxValue: 16,
        minValue: 0,
        unit: 'V',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 4,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 4,
            endValue: 8,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 8,
            endValue: 12,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 12,
            endValue: 16,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.sensorO24V({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Sensor O2 4 (V) [3]',
      config: GaugeConfig(
        maxValue: 0.9,
        minValue: 0,
        unit: 'V',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 0.3,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 0.3,
            endValue: 0.5,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 0.5,
            endValue: 0.6,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 0.6,
            endValue: 0.9,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.sensorO24AFR({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Sensor O2 4 (AFR) [3]',
      config: GaugeConfig(
        maxValue: 16,
        minValue: 0,
        unit: 'V',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 4,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 4,
            endValue: 8,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 8,
            endValue: 12,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 12,
            endValue: 16,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.afrC({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'AFR Comandado',
      config: GaugeConfig(
        maxValue: 20,
        minValue: 0,
        unit: 'AFR',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 5,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 5,
            endValue: 10,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 10,
            endValue: 15,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 15,
            endValue: 20,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.nivelC({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Nivel Combustible',
      config: GaugeConfig(
        maxValue: 100,
        minValue: 0,
        unit: '%',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 25,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 25,
            endValue: 50,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 50,
            endValue: 75,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 75,
            endValue: 100,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.presionC({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Presión Combustible',
      config: GaugeConfig(
        maxValue: 400,
        minValue: 0,
        unit: 'kPa',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 100,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 100,
            endValue: 200,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 200,
            endValue: 300,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 300,
            endValue: 400,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.presionR({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Presión Riel',
      config: GaugeConfig(
        maxValue: 2000,
        minValue: 0,
        unit: 'kPa',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 500,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 500,
            endValue: 1000,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 1000,
            endValue: 1500,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 1500,
            endValue: 2000,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.consumo({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Consumo',
      config: GaugeConfig(
        maxValue: 50,
        minValue: 0,
        unit: 'mg/combustión',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 12.5,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 12.5,
            endValue: 25,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 25,
            endValue: 37.5,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 37.5,
            endValue: 50,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.banco1C({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Banco 1 Corto',
      config: GaugeConfig(
        maxValue: 10,
        minValue: -10,
        unit: '%',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: -10,
            endValue: -5,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: -5,
            endValue: 0,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 0,
            endValue: 5,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 5,
            endValue: 10,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.banco1L({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Banco 1 Largo',
      config: GaugeConfig(
        maxValue: 10,
        minValue: -10,
        unit: '%',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: -10,
            endValue: -5,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: -5,
            endValue: 0,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 0,
            endValue: 5,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 5,
            endValue: 10,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.banco2C({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Banco 2 Corto',
      config: GaugeConfig(
        maxValue: 10,
        minValue: -10,
        unit: '%',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: -10,
            endValue: -5,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: -5,
            endValue: 0,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 0,
            endValue: 5,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 5,
            endValue: 10,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  factory SpeedometerPage.banco2L({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'Banco 2 Largo',
      config: GaugeConfig(
        maxValue: 10,
        minValue: -10,
        unit: '%',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: -10,
            endValue: -5,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: -5,
            endValue: 0,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 0,
            endValue: 5,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 5,
            endValue: 10,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
    factory SpeedometerPage.catB1S1({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'CatB1S1',
      config: GaugeConfig(
        maxValue: 950,
        minValue: 0,
        unit: '°C',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 237.5,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 237.5,
            endValue: 475,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 475,
            endValue: 712.5,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 712.5,
            endValue: 950,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
    factory SpeedometerPage.catB1S2({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'CatB1S2',
      config: GaugeConfig(
        maxValue: 650,
        minValue: 0,
        unit: '°C',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 162.5,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 162.5,
            endValue: 325,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 325,
            endValue: 487.5,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 487.5,
            endValue: 650,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
    factory SpeedometerPage.catB2S1({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'CatB2S1',
      config: GaugeConfig(
        maxValue: 950,
        minValue: 0,
        unit: '°C',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 237.5,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 237.5,
            endValue: 475,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 475,
            endValue: 712.5,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 712.5,
            endValue: 950,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
    factory SpeedometerPage.catB2S2({required double value}) {
    return SpeedometerPage(
      value: value,
      title: 'CatB2S2',
      config: GaugeConfig(
        maxValue: 650,
        minValue: 0,
        unit: '°C',
        gradient: const SweepGradient(
          colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          stops: [0.25, 0.5, 0.75, 1],
        ),
        ranges: [
          GaugeRange(
            startValue: 0,
            endValue: 162.5,
            color: Colors.green,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 162.5,
            endValue: 325,
            color: Colors.yellow,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 325,
            endValue: 487.5,
            color: Colors.orange,
            startWidth: 15,
            endWidth: 15,
          ),
          GaugeRange(
            startValue: 487.5,
            endValue: 650,
            color: Colors.red,
            startWidth: 15,
            endWidth: 15,
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final currentColor = _getValueColor(value, config.ranges);

    return Dialog(
      backgroundColor: Color(0xFF0166B3),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 300,
                  child: SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        startAngle: 140,
                        endAngle: 40,
                        minimum: config.minValue,
                        maximum: config.maxValue,
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
                        axisLineStyle: AxisLineStyle(
                          thickness: 15,
                          gradient: config.gradient,
                        ),
                        pointers: <GaugePointer>[
                          NeedlePointer(
                            value: value.clamp(0, config.maxValue),
                            enableAnimation: true,
                            animationType: AnimationType.easeOutBack,
                            needleColor: config.needleColor,
                            needleStartWidth: 1,
                            needleEndWidth: 5,
                            needleLength: 0.75,
                            animationDuration: 2000,
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
                        ranges: config.ranges,
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                            widget: Column(
                              children: [
                                const SizedBox(height: 110),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  style: TextStyle(
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    color: currentColor,
                                    shadows: [
                                      Shadow(
                                        color: currentColor.withOpacity(0.5),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: Text(value.toStringAsFixed(1)), // Child agregado aquí
                                ),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: currentColor,
                                  ),
                                  child: Text(config.unit), // Child agregado aquí
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
