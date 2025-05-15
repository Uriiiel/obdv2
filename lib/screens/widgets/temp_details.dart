import 'package:obdv2/core/constants.dart';
import 'package:obdv2/core/home_controller.dart';
import 'package:obdv2/screens/widgets/temp_buttom.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class TempDetails extends StatefulWidget {
  const TempDetails({
    super.key,
    required this.homeController,
  });

  final HomeController homeController;

  @override
  State<TempDetails> createState() => _TempDetailsState();
}

class _TempDetailsState extends State<TempDetails> {
  // Variables para cada temperatura
  String tempRefrigerante = "...";
  String tempAceite = "...";
  String catB1S1 = "...";
  String catB1S2 = "...";
  String catB2S1 = "...";
  String catB2S2 = "...";

  @override
  void initState() {
    super.initState();
    _listenToTemperatures();
  }

  void _listenToTemperatures() {
    final db = FirebaseDatabase.instance.ref();

    db.child('SensoresMotor/Temperatura refrigerante').onValue.listen((event) {
      setState(() {
        tempRefrigerante = event.snapshot.value.toString();
      });
    });

    db.child('SensoresMotor/Temperatura aceite').onValue.listen((event) {
      setState(() {
        tempAceite = event.snapshot.value.toString();
      });
    });

    db.child('SensoresOxigeno/Temp catalizador-B1S1').onValue.listen((event) {
      setState(() {
        catB1S1 = event.snapshot.value.toString();
      });
    });

    db.child('SensoresOxigeno/Temp catalizador-B1S2').onValue.listen((event) {
      setState(() {
        catB1S2 = event.snapshot.value.toString();
      });
    });

    db.child('SensoresOxigeno/Temp catalizador-B2S1').onValue.listen((event) {
      setState(() {
        catB2S1 = event.snapshot.value.toString();
      });
    });

    db.child('SensoresOxigeno/Temp catalizador-B2S2').onValue.listen((event) {
      setState(() {
        catB2S2 = event.snapshot.value.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle valueStyle =
        const TextStyle(fontSize: 30, fontWeight: FontWeight.w800);
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTemp("Temperatura refrigerante", tempRefrigerante, big: true),
          _buildTemp("Temperatura aceite", tempAceite),
          _buildTemp("Temp catalizador-B1S1", catB1S1),
          _buildTemp("Temp catalizador-B1S2", catB1S2),
          _buildTemp("Temp catalizador-B2S1", catB2S1),
          _buildTemp("Temp catalizador-B2S2", catB2S2),
        ],
      ),
    );
  }
  // Row(
  //   children: [
  //     TempButtom(
  //       activeColor: primaryColor,
  //       isActive: homeController.isCoolSelected,
  //       svgPic: 'assets/icons/coolShape.svg',
  //      title: 'Cool',
  //       onPress: homeController.updateCoolSelected,
  //       ),
  //        SizedBox(width: 30),
  //       TempButtom(
  //         activeColor: Colors.red,
  //       isActive: !homeController.isCoolSelected,
  //       svgPic: 'assets/icons/heatShape.svg',
  //      title: 'Heat',
  //       onPress: homeController.updateCoolSelected,
  //       ),
  //   ],
  // ),

  Widget _buildTemp(String label, String value, {bool big = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Text(
          "$value °C",
          style: TextStyle(
            fontSize: big ? 70 : 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}