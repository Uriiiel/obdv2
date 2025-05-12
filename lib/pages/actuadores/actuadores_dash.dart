// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';

// final Color colorPrimary = Color(0xFF007AFF); // Azul principal

// class ActDashPage extends StatefulWidget {
//   const ActDashPage({super.key});

//   @override
//   State<ActDashPage> createState() => _ActDashPageState();
// }

// class _ActDashPageState extends State<ActDashPage> {
//   final ValueNotifier<double> _ajusteComNotifier = ValueNotifier(0.0);
//   final ValueNotifier<double> _cargaMotorNotifier = ValueNotifier(0.0);
//   final ValueNotifier<double> _purgaEvaNotifier = ValueNotifier(0.0);

//   //final ValueNotifier<double> _tiempFuncNotifier = ValueNotifier(0.0);
//   String selectedMetric = "Ajuste combustible corto";
//   final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

//   @override
//   void initState() {
//     super.initState();
//     _setupDatabaseListeners();
//   }

//   void _setupDatabaseListeners() {
//     _databaseRef
//         .child('/actuadores/Ajuste combustible corto')
//         .onValue
//         .listen((event) {
//       final data = event.snapshot.value;
//       if (data != null) {
//         if (data == "No soportado") {
//           _ajusteComNotifier.value =
//               -26;
//         } else {
//           final ajustecom = double.tryParse(data.toString()) ?? 0.0;
//           _ajusteComNotifier.value = ajustecom;
//         }
//       }
//     });

//     _databaseRef
//         .child('/actuadores/Purga de sistema evaporacion')
//         .onValue
//         .listen((event) {
//       final data = event.snapshot.value;
//       if (data != null) {
//         if (data == "No soportado") {
//           _purgaEvaNotifier.value =
//               -1; // Valor especial para indicar "No soportado"
//         } else {
//           final purgaEva = double.tryParse(data.toString()) ?? 0.0;
//           _purgaEvaNotifier.value = purgaEva;
//         }
//       }
//     });

//   }

//   Widget buildGauge() {
//     switch (selectedMetric) {
//       case 'Purga de sistema evaporacion':
//         return buildPSEGauge();
//       default:
//         return buildACCGauge();
//     }
//   }

//   Widget buildACCGauge() {
//     return ValueListenableBuilder<double>(
//       valueListenable: _ajusteComNotifier,
//       builder: (context, ajustecom, child) {
//         if (ajustecom < -25) {
//           return Center(
//             child: Text(
//               "No soportado",
//               style: TextStyle(
//                 fontSize: 40,
//                 color: Colors.red,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           );
//         }

//         return SfRadialGauge(
//           axes: <RadialAxis>[
//             RadialAxis(
//               startAngle: 140,
//               endAngle: 40,
//               minimum: -25, 
//               maximum: 30, 
//               radiusFactor: 0.9,
//               axisLineStyle: const AxisLineStyle(
//                 thickness: 12,
//                 gradient: SweepGradient(
//                   colors: [Colors.green, Colors.yellow, Colors.red],
//                   stops: [0.3, 0.7, 1],
//                 ),
//               ),
//               pointers: <GaugePointer>[
//                 NeedlePointer(
//                   value: ajustecom.clamp(-25, 30),
//                   enableAnimation: true,
//                   animationType: AnimationType.elasticOut,
//                   needleColor: Colors.red,
//                   needleLength: 0.75,
//                   animationDuration: 1500,
//                   gradient: const LinearGradient(
//                     colors: [Colors.white, Colors.red],
//                   ),
//                   knobStyle: KnobStyle(
//                     color: Colors.transparent,
//                     borderColor: Colors.blue.withAlpha(100),
//                     borderWidth: 1,
//                   ),
//                 ),
//               ],
//               annotations: [
//                 GaugeAnnotation(
//                   widget: Column(
//                     children: [
//                       const SizedBox(height: 180),
//                       Text(
//                         "${ajustecom.toStringAsFixed(0)}%",
//                         style: const TextStyle(
//                           fontSize: 45,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.teal,
//                           shadows: [
//                             Shadow(color: Colors.white, blurRadius: 20)
//                           ],
//                         ),
//                       ),
//                       const Text(
//                         "Ajuste combustible corto",
//                         style: TextStyle(fontSize: 18, color: Colors.black),
//                       ),
//                     ],
//                   ),
//                   angle: 90,
//                   positionFactor: 0.75,
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget buildPSEGauge() {
//     return ValueListenableBuilder<double>(
//       valueListenable: _purgaEvaNotifier,
//       builder: (context, purgaEva, child) {
//         if (purgaEva == -1) {
//           return Center(
//             child: Text(
//               "No soportado",
//               style: TextStyle(
//                 fontSize: 40,
//                 color: Colors.red,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           );
//         }

//         return SfRadialGauge(
//           axes: <RadialAxis>[
//             RadialAxis(
//               startAngle: 140,
//               endAngle: 40,
//               minimum: 0,
//               maximum: 100,
//               radiusFactor: 0.9,
//               axisLineStyle: const AxisLineStyle(
//                 thickness: 12,
//                 gradient: SweepGradient(
//                   colors: [Colors.green, Colors.yellow, Colors.red],
//                   stops: [0.3, 0.7, 1],
//                 ),
//               ),
//               pointers: <GaugePointer>[
//                 NeedlePointer(
//                   value: purgaEva.clamp(0, 100),
//                   enableAnimation: true,
//                   animationType: AnimationType.elasticOut,
//                   needleColor: Colors.red,
//                   needleLength: 0.75,
//                   animationDuration: 1500,
//                   gradient: const LinearGradient(
//                     colors: [Colors.white, Colors.red],
//                   ),
//                   knobStyle: KnobStyle(
//                     color: Colors.transparent,
//                     borderColor: Colors.blue.withAlpha(100),
//                     borderWidth: 1,
//                   ),
//                 ),
//               ],
//               annotations: [
//                 GaugeAnnotation(
//                   widget: Column(
//                     children: [
//                       const SizedBox(height: 180),
//                       Text(
//                         "${purgaEva.toStringAsFixed(0)}%",
//                         style: const TextStyle(
//                           fontSize: 45,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.teal,
//                           shadows: [
//                             Shadow(color: Colors.white, blurRadius: 20)
//                           ],
//                         ),
//                       ),
//                       const Text(
//                         "Purga de sistema evaporacion",
//                         style: TextStyle(fontSize: 18, color: Colors.black),
//                       ),
//                     ],
//                   ),
//                   angle: 90,
//                   positionFactor: 0.75,
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 188, 188, 188),
//       appBar: AppBar(
//         backgroundColor: colorPrimary,
//         title: const Text(
//           "Dashboard",
//           style: TextStyle(
//             fontSize: 24,
//             color: Colors.white,
//           ),
//         ),
//         actions: <Widget>[
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // DropdownButton para seleccionar métrica
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                       color: Colors.blueAccent, width: 2), // Borde azul
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 4,
//                       offset: Offset(2, 2), // Sombra ligera
//                     ),
//                   ],
//                 ),
//                 child: DropdownButton<String>(
//                   value: selectedMetric,
//                   items: <String>[
//                     'Ajuste combustible corto',
//                     'Purga de sistema evaporacion',
//                   ]
//                       .map((String value) => DropdownMenuItem<String>(
//                             value: value,
//                             child: Text(
//                               value,
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                           ))
//                       .toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       selectedMetric = newValue!;
//                     });
//                   },
//                   isExpanded: true,
//                   underline: Container(), // Quita la línea por defecto
//                   icon: const Icon(
//                     Icons.arrow_drop_down,
//                     color: Colors.blueAccent,
//                     size: 28,
//                   ),
//                   dropdownColor: Colors.white,
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Center(
//                 child: buildGauge(), // Mostrar gauge basado en selección
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
