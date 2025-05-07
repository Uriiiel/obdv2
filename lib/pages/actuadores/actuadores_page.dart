// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // class ActuadoresPage extends StatefulWidget {
// //   const ActuadoresPage({Key? key}) : super(key: key);

// //   @override
// //   _ActuadoresPageState createState() => _ActuadoresPageState();
// // }

// // class _ActuadoresPageState extends State<ActuadoresPage> {
// //   Map<String, dynamic>? actuadoresData;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchActuadoresData();
// //   }

// //   Future<void> _fetchActuadoresData() async {
// //     try {
// //       DocumentSnapshot snapshot = await FirebaseFirestore.instance
// //           .collection('DTC')
// //           .doc('Actuadores')
// //           .get();

// //       if (snapshot.exists) {
// //         setState(() {
// //           actuadoresData = snapshot.data() as Map<String, dynamic>;
// //         });
// //       }
// //     } catch (e) {
// //       print("Error al obtener los datos: $e");
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color.fromARGB(255, 188, 188, 188),
// //       appBar: AppBar(
// //         title: const Text(
// //           'Información de Actuadores',
// //           style: TextStyle(fontSize: 22, color: Colors.white),
// //         ),
// //         backgroundColor: Color(0xFF007AFF),
// //       ),
// //       body: actuadoresData == null
// //           ? const Center(child: CircularProgressIndicator())
// //           : Padding(
// //               padding: const EdgeInsets.all(16.0),
// //               child: Card(
// //                 color: Colors.white,
// //                 elevation: 4,
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(16.0),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       const Text(
// //                         "Datos de Actuadores:",
// //                         style: TextStyle(
// //                           fontSize: 20,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 12),
// //                       Expanded(
// //                         child: ListView(
// //                           children: actuadoresData!.entries.map((entry) {
// //                             return _infoRow(entry.key, entry.value.toString());
// //                           }).toList(),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //     );
// //   }

// //   Widget _infoRow(String label, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 8.0),
// //       child: Row(
// //         mainAxisAlignment:
// //             MainAxisAlignment.spaceBetween, // Alinea los elementos
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Expanded(
// //             flex: 3,
// //             child: Text(
// //               label,
// //               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //             ),
// //           ),
// //           Expanded(
// //             flex: 5,
// //             child: Align(
// //               alignment: Alignment.centerRight, // Alinea el texto a la derecha
// //               child: Text(
// //                 value,
// //                 style: const TextStyle(fontSize: 16),
// //                 textAlign: TextAlign
// //                     .right, // Asegura que el texto también esté alineado a la derecha
// //                 softWrap: true,
// //                 overflow: TextOverflow.visible,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }


// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class RealTimeLineActChart extends StatefulWidget {
//   @override
//   _RealTimeLineActChartState createState() => _RealTimeLineActChartState();
// }

// final Color colorPrimary = Color(0xFF007AFF); // Azul principal

// class _RealTimeLineActChartState extends State<RealTimeLineActChart> {
//   List<ChartData> chartData = [];
//   late DatabaseReference _databaseRef;
//   String selectedChart = '/actuadores/Ajuste combustible corto'; // Opción inicial seleccionada
//   StreamSubscription<DatabaseEvent>? _databaseSubscription; // Listener de Firebase

//   @override
//   void initState() {
//     super.initState();
//     _databaseRef = FirebaseDatabase.instance.ref();
//     _setupDatabaseListener();
//   }

//   // Método para configurar el listener de Firebase
//   void _setupDatabaseListener() {
//     // Cancelar el listener anterior si existe
//     _databaseSubscription?.cancel();

//     // Configurar un nuevo listener para la métrica seleccionada
//     _databaseSubscription = _databaseRef.child(selectedChart).onValue.listen((event) {
//       final data = event.snapshot.value;
//       if (data != null) {
//         final double newValue = double.tryParse(data.toString()) ?? 0.0;
//         setState(() {
//           chartData.add(ChartData(chartData.length, newValue));
//           if (chartData.length > 5000) {
//             chartData.removeAt(0); // Limitar el número de puntos en el gráfico
//           }
//         });
//       }
//     });
//   }

//   // Método para obtener el rango máximo según la métrica seleccionada
//   double _getYAxisMax() {
//     switch (selectedChart) {
//       case '/actuadores/Ajuste combustible corto':
//         return 30;
//         return 10;
//       case '/actuadores/Purga de sistema evaporacion':
//         return 10;
//       default:
//         return 0.0;
//     }
//   }

//   // Método para obtener el rango mínimo según la métrica seleccionada
//   double _getYAxisMin() {
//     switch (selectedChart) {
//       case '/actuadores/Ajuste combustible corto':
//         return 25;
//       case '/actuadores/Purga de sistema evaporacion':
//         return 0;
//       default:
//         return 0.0;
//     }
//   }

//   @override
//   void dispose() {
//     // Cancelar el listener cuando el widget se destruye
//     _databaseSubscription?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 188, 188, 188),
//       appBar: AppBar(
//         backgroundColor: colorPrimary,
//         title: const Text(
//           "Gráfica actuadores",
//           style: TextStyle(
//             fontSize: 24,
//             color: Colors.black,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           // Dropdown para seleccionar métrica
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                     color: Colors.blueAccent, width: 2), // Borde azul
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 4,
//                     offset: Offset(2, 2),
//                   ),
//                 ],
//               ),
//               child: DropdownButton<String>(
//                 value: selectedChart,
//                 items: <String>[
//                   '/actuadores/Ajuste combustible corto',
//                   '/actuadores/Purga de sistema evaporacion',
//                 ]
//                     .map((String value) => DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value.replaceAll('/actuadores/',
//                               '')), // Mostrar nombre sin "/Sensores/"
//                         ))
//                     .toList(),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     selectedChart = newValue!;
//                     chartData.clear(); // Reiniciar datos al cambiar métrica
//                     _setupDatabaseListener(); // Configurar listener para la nueva métrica
//                   });
//                 },
//                 isExpanded: true,
//                 underline: Container(), // Quita la línea por defecto
//                 icon: const Icon(
//                   Icons.arrow_drop_down,
//                   color: Colors.blueAccent,
//                   size: 28,
//                 ),
//                 dropdownColor: Colors.white,
//               ),
//             ),
//           ),
//           // Contenedor para la gráfica
//           Expanded(
//             child: Center(
//               child: SfCartesianChart(
//                 primaryXAxis: NumericAxis(
//                   title: AxisTitle(text: 'Tiempo (s)'),
//                   autoScrollingMode: AutoScrollingMode.end,
//                   autoScrollingDelta: 10,
//                 ),
//                 primaryYAxis: NumericAxis(
//                   title: AxisTitle(
//                       text: selectedChart.replaceAll('/actuadores/', '')),
//                   minimum: _getYAxisMin(),
//                   maximum: _getYAxisMax(),
//                 ),
//                 series: <LineSeries<ChartData, int>>[
//                   LineSeries<ChartData, int>(
//                     dataSource: chartData,
//                     xValueMapper: (ChartData data, _) => data.x,
//                     yValueMapper: (ChartData data, _) => data.y,
//                     color: Colors.blue,
//                     width: 2,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ChartData {
//   final int x;
//   final double y;

//   ChartData(this.x, this.y);
// }