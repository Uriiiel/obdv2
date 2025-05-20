// import 'package:flutter/material.dart';

// class BatteryStatus extends StatelessWidget {
//   final BoxConstraints constraints;
//   final String voltage;
//   final Map<String, String> oxygenValues;

//   const BatteryStatus({
//     super.key,
//     required this.constraints,
//     required this.voltage,
//     required this.oxygenValues,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Debug: Verificar datos recibidos
//     print("[BatteryStatus] Voltaje: $voltage");
//     print("[BatteryStatus] Oxygen Values: $oxygenValues");

//     return Padding(
//       padding: const EdgeInsets.all(25),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           _buildDetail('Voltaje', '$voltage V', big: true),
//           const SizedBox(height: 20),
//           ...oxygenValues.entries.map((e) {
//             // Determinar unidad basada en la clave
//             final unit = e.key.toLowerCase().contains('afr') ? ' AFR' : ' V';
//             return _buildDetail(
//               e.key.replaceAll(RegExp(r'\s?\(.*\)'), ''), // Limpiar clave
//               '${e.value}$unit', 
//               big: false,
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetail(String label, String value, {bool big = false}) {
//     // Validar si el valor es numérico
//     final isValid = double.tryParse(value.split(' ').first) != null;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.white.withOpacity(0.8),
//             fontSize: 16,
//           ),
//         ),
//         Text(
//           isValid ? value : '--', // Mostrar -- si no es numérico
//           style: TextStyle(
//             fontSize: big ? 70 : 25,
//             fontWeight: FontWeight.bold,
//             color: isValid ? Colors.white : Colors.red,
//           ),
//         ),
//         const SizedBox(height: 10),
//       ],
//     );
//   }
// }