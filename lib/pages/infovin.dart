import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InfoVinPage extends StatefulWidget {
  const InfoVinPage({Key? key}) : super(key: key);

  @override
  _InfoVinPageState createState() => _InfoVinPageState();
}

class _InfoVinPageState extends State<InfoVinPage> {
  Map<String, dynamic>? vinData;
  Map<String, dynamic>? vinD;

  @override
  void initState() {
    super.initState();
    _fetchVinData();
    _fetchVin();
  }

  Future<void> _fetchVinData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('DTC')
          .doc('Descifrado')
          .get();

      if (snapshot.exists) {
        setState(() {
          vinData = snapshot.data() as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      print("Error al obtener los datos: $e");
    }
  }

  Future<void> _fetchVin() async {
    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('DTC').doc('VIN').get();

      if (snapshot.exists) {
        setState(() {
          vinD = snapshot.data() as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      print("Error al obtener los datos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 188, 188, 188),
      appBar: AppBar(
        title: const Text(
          'Información del vehículo',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFF007AFF),
      ),
      body: vinData == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min, // Ajusta el tamaño al contenido
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/autazo.gif',
                          height: 190,
                        ),
                        const SizedBox(height: 16),
                        _infoRow("VIN", vinD!["VIN"].toString()),
                        _infoRow("Año del modelo",
                            vinData!["Año del modelo"].toString()),
                        _infoRow("Fabricante", vinData!["Fabricante"]),
                        _infoRow(
                            "Número de serie", vinData!["Número de serie"]),
                        _infoRow(
                            "Planta de ensamblaje (código)",
                            vinData!["Planta de ensamblaje (código)"]
                                .toString()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Alinea en la parte superior
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5, // Mayor espacio para el valor
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              softWrap: true,
              overflow: TextOverflow.visible, // Permite el ajuste automático
            ),
          ),
        ],
      ),
    );
  }
}
