// import 'package:flutter/material.dart';
// import 'package:obdv2/pages/actuadores/actuadores_page.dart';
// import 'package:obdv2/pages/dashboard/home_dash.dart';
// import 'package:obdv2/pages/graphs/home_graphs.dart';
// import 'package:obdv2/pages/infovin.dart';
// import 'package:obdv2/pages/login_page.dart';
// import 'package:obdv2/pages/actuadores/actuadores_home.dart';

// final Color colorPrimary = Color(0xFF007AFF); // Azul principal
// final Color colorSecondary = Color(0xFF1E90FF); // Azul más claro

// class HomePage extends StatefulWidget {
//   final dynamic user;

//   const HomePage({Key? key, required this.user}) : super(key: key);

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   void _logout() {
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => LoginPage()),
//       (route) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Monitoreo OBD',
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         backgroundColor: colorPrimary,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () {
//               print("Configuraciones del usuario: \${widget.user}");
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: _logout,
//           ),
//         ],
//       ),
      
//       body: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: Column(
//                 children: [
//                   Image.asset(
//                     'assets/images/car.png',
//                     height: 190,
//                   ),
//                   const SizedBox(height: 8),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 32),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Wrap(
//                 alignment: WrapAlignment.center,
//                 spacing: 16.0,
//                 runSpacing: 16.0,
//                 children: [
//                   _HomeButton(
//                     icon: Icons.dashboard,
//                     label: 'Dashboard',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => HomeDash()),
//                       );
//                     },
//                   ),
//                   _HomeButton(
//                     icon: Icons.monitor_heart,
//                     label: 'Diagnóstico',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => HomeGraphs()),
//                       );
//                     },
//                   ),
//                   _HomeButton(
//                     icon: Icons.car_rental,
//                     label: 'Información del vehículo',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => InfoVinPage()),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//       ),
//       backgroundColor: Colors.grey[100],
//     );
//   }
// }

// class _HomeButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;

//   const _HomeButton({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ConstrainedBox(
//       constraints: BoxConstraints(
//         minWidth: 150,
//         maxWidth: 200,
//         minHeight: 120,
//       ),
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           width: 170,  // Ancho fijo para consistencia
//           height: 160,  // Altura fija
//           decoration: BoxDecoration(
//             color: colorSecondary,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 5,
//                 spreadRadius: 1,
//                 offset: Offset(2, 3),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 40,
//                 color: Colors.white,
//               ),
//               const SizedBox(height: 8),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Text(
//                   label,
//                   style: const TextStyle(
//                     fontSize: 16,  // Tamaño reducido para textos largos
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,  // Permite 2 líneas de texto
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }