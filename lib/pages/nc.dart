import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menú de Sensores")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SensoresMotor()),
                );
              },
              child: const Text("Sensores del motor"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const sensoresCombustible()),
                );
              },
              child: const Text("Sensores del combustible"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const sensoresOxigeno()),
                );
              },
              child: const Text("Sensores de oxígeno"),
            ),
          ],
        ),
      ),
    );
  }
}

class SensoresMotor extends StatefulWidget {
  const SensoresMotor({super.key});

  @override
  State<SensoresMotor> createState() => _SensoresMotorState();
}

//Sensores del motor
class _SensoresMotorState extends State<SensoresMotor> {
  final DatabaseReference _sensorsRef =
      FirebaseDatabase.instance.ref('/SensoresMotor');
  String selectedMetricKey = "Vel vehículo";

  final Map<String, String> metricLabels = {
    "Carga del motor": "Carga del motor",
    "Consumo instantáneo combustible": "Consumo instantáneo de combustible",
    "Posición acelerador": "Posición del acelerador",
    "Presión colector admisión": "Presión de colector de admisión",
    "Presión combustible": "Presión de combustible",
    "RPM": "RPM del motor",
    "Sensor MAP": "Sensor MAP",
    "Temperatura aceite": "Temperatura del aceite",
    "Temperatura refrigerante": "Temperatura del refrigerante",
    "Tiempo de encendido": "Tiempo de encendido",
    "Vel vehículo": "Velocidad del vehículo",
  };

  Map<String, dynamic> sensorData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Dashboard Sensores")),
      body: SafeArea(
        child: StreamBuilder(
          stream: _sensorsRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              sensorData = Map<String, dynamic>.from(
                  snapshot.data!.snapshot.value as Map);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButton<String>(
                      value: selectedMetricKey,
                      items: metricLabels.keys
                          .map((String key) => DropdownMenuItem<String>(
                                value: key,
                                child: Text(metricLabels[key]!),
                              ))
                          .toList(),
                      onChanged: (String? newKey) {
                        setState(() {
                          selectedMetricKey = newKey!;
                        });
                      },
                      isExpanded: true,
                    ),
                  ),
                  Expanded(child: Center(child: buildGauge(selectedMetricKey))),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Valor actual: ${getFormattedValue(selectedMetricKey)}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: Text("No se encontraron datos"));
            }
          },
        ),
      ),
    );
  }

  Widget buildGauge(String metricKey) {
    double value = 0.0;
    try {
      value = sensorData[metricKey]?.toDouble() ?? 0.0;
    } catch (e) {
      value = -1.0;
    }

    if (value < 0) {
      return const Center(
          child: Text("NO SOPORTADO",
              style: TextStyle(fontSize: 24, color: Colors.red)));
    }

    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
            minimum: 0,
            maximum: getMaximumValue(metricKey),
            pointers: [NeedlePointer(value: value)]),
      ],
    );
  }

  double getMaximumValue(String metric) {
    switch (metric) {
      case "Carga del motor":
        return 100;
      case "Consumo instantáneo combustible":
        return 20;
      case "Posición acelerador":
        return 100;
      case "Presión colector admisión":
        return 300;
      case "Presión combustible":
        return 1000;
      case "RPM":
        return 8000;
      case "Sensor MAP":
        return 200;
      case "Temperatura aceite":
        return 150;
      case "Temperatura refrigerante":
        return 120;
      case "Tiempo de encendido":
        return 3600;
      case "Vel vehículo":
        return 240;
      default:
        return 100;
    }
  }

  String getFormattedValue(String metricKey) {
    double value = 0.0;
    try {
      value = sensorData[metricKey]?.toDouble() ?? 0.0;
    } catch (e) {
      return "N/A";
    }
    return value.toStringAsFixed(2);
  }
}

//Sensores de combustible
class sensoresCombustible extends StatefulWidget {
  const sensoresCombustible({super.key});

  @override
  State<sensoresCombustible> createState() => _sensoresCombustibleState();
}

class _sensoresCombustibleState extends State<sensoresCombustible> {
  final DatabaseReference _sensorsRef =
      FirebaseDatabase.instance.ref('/SensoresCombustible');
  String selectedMetricKey = "Consumo instantáneo de combustible";

  final Map<String, String> metricLabels = {
    "Consumo instantáneo de combustible": "Consumo instantáneo de combustible",
    "Estado del sistema de combustible": "Estado del sistema de combustible",
    "Nivel de combustible": "Nivel de combustible",
    "Presión de la bomba de combustible": "Presión de la bomba de combustible",
  };

  Map<String, dynamic> sensorData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Dashboard Sensores")),
      body: SafeArea(
        child: StreamBuilder(
          stream: _sensorsRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              sensorData = Map<String, dynamic>.from(
                  snapshot.data!.snapshot.value as Map);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButton<String>(
                      value: selectedMetricKey,
                      items: metricLabels.keys
                          .map((String key) => DropdownMenuItem<String>(
                                value: key,
                                child: Text(metricLabels[key]!),
                              ))
                          .toList(),
                      onChanged: (String? newKey) {
                        setState(() {
                          selectedMetricKey = newKey!;
                        });
                      },
                      isExpanded: true,
                    ),
                  ),
                  Expanded(child: Center(child: buildGauge(selectedMetricKey))),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Valor actual: ${getFormattedValue(selectedMetricKey)}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: Text("No se encontraron datos"));
            }
          },
        ),
      ),
    );
  }

  Widget buildGauge(String metricKey) {
    double value = 0.0;
    try {
      value = sensorData[metricKey]?.toDouble() ?? 0.0;
    } catch (e) {
      value = -1.0;
    }

    if (value < 0) {
      return const Center(
          child: Text("NO SOPORTADO",
              style: TextStyle(fontSize: 24, color: Colors.red)));
    }

    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
            minimum: 0,
            maximum: getMaximumValue(metricKey),
            pointers: [NeedlePointer(value: value)]),
      ],
    );
  }

  double getMaximumValue(String metric) {
    switch (metric) {
      case "Consumo instantáneo de combustible":
        return 100;
      case "Estado del sistema de combustible":
        return 100;
      case "Nivel de combustible":
        return 100;
      case "Presión de la bomba de combustible":
        return 100;
      default:
        return 100;
    }
  }

  String getFormattedValue(String metricKey) {
    double value = 0.0;
    try {
      value = sensorData[metricKey]?.toDouble() ?? 0.0;
    } catch (e) {
      return "N/A";
    }
    return value.toStringAsFixed(2);
  }
}

//Sensores de oxigeno
class sensoresOxigeno extends StatefulWidget {
  const sensoresOxigeno({super.key});

  @override
  State<sensoresOxigeno> createState() => _sensoresOxigenoState();
}

class _sensoresOxigenoState extends State<sensoresOxigeno> {
  final DatabaseReference _sensorsRef =
      FirebaseDatabase.instance.ref('/SensoresOxigeno');
  String selectedMetricKey = "Sensor oxigeno-B1S1";

  final Map<String, String> metricLabels = {
    "Sensor oxigeno-B1S1": "Sensor oxigeno-B1S1",
    "Sensor oxigeno-B1S2": "Sensor oxigeno-B1S2",
    "Sensor oxigeno-B2S1": "Sensor oxigeno-B2S1",
    "Sensor oxigeno-B2S2": "Sensor oxigeno-B2S2",
    "Temp catalizador-B1S1": "Temp catalizador-B1S1",
    "Temp catalizador-B1S2": "Temp catalizador-B1S2",
    "Temp catalizador-B2S1": "Temp catalizador-B2S1",
    "Temp catalizador-B2S2": "Temp catalizador-B2S2",
  };

  Map<String, dynamic> sensorData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Dashboard Sensores")),
      body: SafeArea(
        child: StreamBuilder(
          stream: _sensorsRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              sensorData = Map<String, dynamic>.from(
                  snapshot.data!.snapshot.value as Map);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButton<String>(
                      value: selectedMetricKey,
                      items: metricLabels.keys
                          .map((String key) => DropdownMenuItem<String>(
                                value: key,
                                child: Text(metricLabels[key]!),
                              ))
                          .toList(),
                      onChanged: (String? newKey) {
                        setState(() {
                          selectedMetricKey = newKey!;
                        });
                      },
                      isExpanded: true,
                    ),
                  ),
                  Expanded(child: Center(child: buildGauge(selectedMetricKey))),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Valor actual: ${getFormattedValue(selectedMetricKey)}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: Text("No se encontraron datos"));
            }
          },
        ),
      ),
    );
  }

  Widget buildGauge(String metricKey) {
    double value = 0.0;
    try {
      value = sensorData[metricKey]?.toDouble() ?? 0.0;
    } catch (e) {
      value = -1.0;
    }

    if (value < 0) {
      return const Center(
          child: Text("NO SOPORTADO",
              style: TextStyle(fontSize: 24, color: Colors.red)));
    }

    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
            minimum: 0,
            maximum: getMaximumValue(metricKey),
            pointers: [NeedlePointer(value: value)]),
      ],
    );
  }

  double getMaximumValue(String metric) {
    switch (metric) {
      case "Sensor oxigeno-B1S1":
        return 20;
      case "Sensor oxigeno-B1S2":
        return 20;
      case "Sensor oxigeno-B2S1":
        return 20;
      case "Sensor oxigeno-B2S2":
        return 20;
      case "Temp catalizador-B1S1":
        return 20;
      case "Temp catalizador-B1S2":
        return 20;
      case "Temp catalizador-B2S1":
        return 20;
      case "Temp catalizador-B2S2":
        return 20;
      default:
        return 100;
    }
  }

  String getFormattedValue(String metricKey) {
    double value = 0.0;
    try {
      value = sensorData[metricKey]?.toDouble() ?? 0.0;
    } catch (e) {
      return "N/A";
    }
    return value.toStringAsFixed(2);
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainMenuPage(),
  ));
}