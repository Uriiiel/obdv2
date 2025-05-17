import 'dart:math';

import 'package:obdv2/core/constants.dart';
import 'package:obdv2/core/home_controller.dart';
import 'package:obdv2/core/model/tyres_model.dart';
import 'package:obdv2/pages/dashboard/dashboard_page.dart';
import 'package:obdv2/screens/widgets/battery_status.dart';
import 'package:obdv2/screens/widgets/button_nav_bar.dart';
import 'package:obdv2/screens/widgets/door_lock.dart';
import 'package:obdv2/screens/widgets/temp_details.dart';
import 'package:obdv2/screens/widgets/tyres_list.dart';
import 'package:obdv2/screens/widgets/tyres_psi_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  //pruebas sin obd

  // bool _mockMode = true;

  // bluetooth
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _device;
  BluetoothConnection? _connection;
  bool _isConnecting = false;
  bool _isConnected = false;
  String _messageBuffer = '';
  String _vin = 'No disponible';
  bool _isFetchingVin = false;
  List<String> _vinCommands = ['0902', '22 194', '21 194'];
  int _currentVinCommandIndex = 0;

  // Datos que vas a mostrar:
  double _speed = 0.0;
  double _rpm = 0.0;
  double _coolantTemp = 0.0;
  double _engineLoad = 0.0;
  double _ignitionAdvance = 0.0;

  double _maf = 0.0;
  double _intakeManifoldPressure = 0.0;

  
  // Variables para sensores de oxígeno
  List<double> _o2Voltage = [0.0, 0.0, 0.0, 0.0];
  List<double> _o2AFR = [0.0, 0.0, 0.0, 0.0];
  double _commandedAFR = 0.0;
  String _o2SensorsPresent = 'Desconocido';

  // Variables para sensores de combustible
  double _fuelLevel = 0.0; // Nivel de combustible (0-100%)
  double _fuelPressure = 0.0; // Presión de combustible (kPa)
  double _fuelRailPressure = 0.0; // Presión del riel de combustible (kPa)
  double _fuelRate = 0.0; // Tasa de consumo de combustible (L/h)
  double _fuelTrimBank1ShortTerm =
      0.0; // Ajuste de combustible banco 1 corto plazo (%)
  double _fuelTrimBank1LongTerm =
      0.0; // Ajuste de combustible banco 1 largo plazo (%)
  double _fuelTrimBank2ShortTerm =
      0.0; // Ajuste de combustible banco 2 corto plazo (%)
  double _fuelTrimBank2LongTerm =
      0.0; // Ajuste de combustible banco 2 largo plazo (%)

  final ValueNotifier<double> _speedNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _rpmNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _cooltempNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _engineNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _ignitionNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _mafNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _intakeMPNotifier = ValueNotifier(0.0);

  final ValueNotifier<List<double>> _o2VNotifier = ValueNotifier ([0.0, 0.0, 0.0, 0.0]);
  final ValueNotifier<List<double>> _o2AFRNotifier = ValueNotifier ([0.0, 0.0, 0.0, 0.0]);
  final ValueNotifier<double> _commandedAFRNotifier = ValueNotifier(0.0);
  // final ValueNotifier<String> _o2SPNotifier = ValueNotifier("desconocido");

  final ValueNotifier<double> _fuelLevelNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _fuelPressureNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _fuelRailPNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _fuelRateNotifier = ValueNotifier(0.0);

  final ValueNotifier<double> _fuelTrimB1SNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _fuelTrimB1LNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _fuelTrimB2SNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _fuelTrimB2LNotifier = ValueNotifier(0.0);

  Timer? _commandTimer;
  int _currentCommandIndex = 0;
  // Define tus comandos OBD:
  final List<String> _obdCommands = [
    '010D', // Velocidad del vehículo
    '010C', // RPM motor
    '0105', // Temperatura refrigerante
    '0104', // Carga del motor
    '010E', // Avance de encendido
    '0110', // Flujo de aire masivo (MAF)
    '010B', // Presión del colector de admisión
    '0124', // Relación aire-combustible comandada
    // '0134', // Sensores de oxígeno presentes
    '0114', // Sensor O2 1 - Voltaje y AFR
    '0115', // Sensor O2 2 - Voltaje y AFR
    '0116', // Sensor O2 3 - Voltaje y AFR
    '0117', // Sensor O2 4 - Voltaje y AFR
    '012F', // Nivel de combustible
    '010A', // Presión de combustible
    '0122', // Presión del riel de combustible
    '015E', // Tasa de consumo de combustible
    '0106', // Ajuste de combustible banco 1 corto plazo
    '0107', // Ajuste de combustible banco 1 largo plazo
    '0108', // Ajuste de combustible banco 2 corto plazo
    '0109', // Ajuste de combustible banco 2 largo plazo
  ];

  final ValueNotifier<List<Map<String, dynamic>>> _sensorsNotifier = 
  ValueNotifier([]);

  List<Map<String, dynamic>> _sensors = [];

  String _buffer = '';
  // home controller
  HomeController homeController = HomeController();

  /// battery controller
  ///

  late AnimationController batteryAnimatedController;
  late Animation<double> batteryAnimation;
  late Animation<double> batteryStatusAnimation;

  /// end battery controller
  ///
  /// temprature controller
  ///
  late AnimationController tempratureAnimationController;
  late Animation<double> carShiftAnimation;
  late Animation<double> carShiftLeftAnimation;
  late Animation<double> tempratureShowInfoAnimation;
  late Animation<double> temCoolGlowAnimation;

  /// end temprature controller
  ///
  ///tyres animation controller
  late AnimationController tyresAnimationController;
  late Animation<double> tyresAnimation1Psi;
  late Animation<double> tyresAnimation2Psi;
  late Animation<double> tyresAnimation3Psi;
  late Animation<double> tyresAnimation4Psi;

  late List<Animation<double>> tyresAnimation;

  ///
  ///
  void setupTyresAnimation() {
    tyresAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1100),
    );
    tyresAnimation1Psi = CurvedAnimation(
      parent: tyresAnimationController,
      curve: Interval(0.34, 0.5),
    );
    tyresAnimation2Psi = CurvedAnimation(
      parent: tyresAnimationController,
      curve: Interval(0.5, 0.66),
    );
    tyresAnimation3Psi = CurvedAnimation(
      parent: tyresAnimationController,
      curve: Interval(0.66, 0.82),
    );
    tyresAnimation4Psi = CurvedAnimation(
      parent: tyresAnimationController,
      curve: Interval(0.82, 1),
    );
  }

  void setupTempratureAnimation() {
    tempratureAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    carShiftAnimation = CurvedAnimation(
      parent: tempratureAnimationController,
      curve: Interval(0, 0.2),
    );
    tempratureShowInfoAnimation = CurvedAnimation(
      parent: tempratureAnimationController,
      curve: Interval(0.25, 0.45),
    );
    temCoolGlowAnimation = CurvedAnimation(
      parent: tempratureAnimationController,
      curve: Interval(0.45, 1),
    );
  }

  ///functions of battery
  void setupBatteryAnimated() {
    batteryAnimatedController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    batteryAnimation = CurvedAnimation(
      parent: batteryAnimatedController,
      curve: Interval(0, 0.5),
    );
    batteryStatusAnimation = CurvedAnimation(
      parent: batteryAnimatedController,
      curve: Interval(0.6, 1),
    );
    carShiftLeftAnimation = CurvedAnimation(
      parent: batteryAnimatedController,
      curve: const Interval(0, 0.2),
    );
  }

  @override
  void initState() {
    super.initState();
    //pruebas sin obd
    // if (_mockMode) {
    //   _isConnected = true; // Simular conexión exitosa
    //   _startMockDataGeneration();
    // } else {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _ensureConnection();
    //   });
    //   _checkBluetoothState();
    // }
    //pruebas sin obd
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureConnection();
    });
    _checkBluetoothState();
    setupBatteryAnimated();
    setupTempratureAnimation();
    setupTyresAnimation();
    tyresAnimation = [
      tyresAnimation1Psi,
      tyresAnimation2Psi,
      tyresAnimation3Psi,
      tyresAnimation4Psi
    ];
  }

  // void _startMockDataGeneration() {
  //   Timer.periodic(Duration(milliseconds: 1000), (timer) {
  //     //pruebas sin obd
  //     // if (!_mockMode) {
  //     //   timer.cancel();
  //     //   return;
  //     // }
  //     //pruebas sin obd
  //     final random = Random();
  //     final newSpeed = random.nextDouble() * 200;
  //     final newRpm = random.nextDouble() * 8000;

  //     // Actualiza los ValueNotifiers
  //     _speedNotifier.value = newSpeed;
  //     _rpmNotifier.value = newRpm;

  //     // Mantén la actualización del estado para las tarjetas
  //     setState(() {
  //       _speed = newSpeed;
  //       _rpm = newRpm;
  //     });
      
  //     _updateSensors();
  //   });
  // }

  void _ensureConnection() {
    //pruebas sin obd
    // if (!_mockMode && !_isConnected) {
    //   showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (_) => AlertDialog(
    //       title: const Text('Conectar OBD'),
    //       content: const Text(
    //           'Debes conectar el dispositivo OBD por Bluetooth para continuar.'),
    //       actions: [
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //             _showDeviceList(context);
    //           },
    //           child: const Text('Conectar'),
    //         ),
    //       ],
    //     ),
    //   );
    // }
    //pruebas sin obd
    if (!_isConnected) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Conectar OBD'),
          content: const Text(
              'Debes conectar el dispositivo OBD por Bluetooth para continuar.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showDeviceList(context);
              },
              child: const Text('Conectar'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _checkBluetoothState() async {
    bool? isEnabled = await _bluetooth.isEnabled;
    if (isEnabled == true) {
      _getPairedDevices();
    } else {
      _requestEnableBluetooth();
    }
  }

  Future<void> _requestEnableBluetooth() async {
    bool? enabled = await _bluetooth.requestEnable();
    if (enabled == true) {
      _getPairedDevices();
    }
  }

  Future<void> _getPairedDevices() async {
    try {
      List<BluetoothDevice> devices = await _bluetooth.getBondedDevices();
      setState(() {
        _devicesList = devices;
      });

      if (devices.isNotEmpty) {
        _connectToDevice(
          devices.firstWhere(
            (d) => d.name?.toLowerCase().contains("obd") ?? false,
            orElse: () => devices.first,
          ),
        );
      }
    } catch (error) {
      _showError("Error al buscar dispositivos: $error");
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    //pruebas sin obd
    // if (_mockMode) return;
    //pruebas sin obd
    if (_isConnecting) return;

    // Verificamos que sea un OBD (opcionalmente con un nombre que lo indique)
    if (!(device.name?.toLowerCase().contains("obd") ?? false)) {
      _showError("Este dispositivo no parece ser un OBD. Selecciona uno válido.");
      _ensureConnection(); // vuelve a abrir la ventana de conexión
      return;
    }

    setState(() => _isConnecting = true);

    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        _device = device;
        _isConnected = true;
        _isConnecting = false;
      });

      Navigator.of(context, rootNavigator: true).pop(); // cierra modal

      _startDataListening();
      _startAutoUpdate();
    } catch (error) {
      setState(() => _isConnecting = false);
      _showError("Error al conectar: ${error.toString()}");
      _ensureConnection(); // vuelve a pedir conexión
    }
  }

  void _disconnect() {
    _commandTimer?.cancel();
    if (_connection != null) {
      _connection!.close();
      _connection = null;
    }
    setState(() {
      _isConnected = false;
      _device = null;
      // Resetear valores
      _coolantTemp = 0.0;
      _rpm = 0.0;
      _engineLoad = 0.0;
      _ignitionAdvance = 0.0;
      _speed = 0.0;
      _maf = 0.0;
      _intakeManifoldPressure = 0.0;
      _vin = 'No disponible';
      _isFetchingVin = false;

      // Resetear sensores O2
      _o2Voltage = [0.0, 0.0, 0.0, 0.0];
      _o2AFR = [0.0, 0.0, 0.0, 0.0];
      _commandedAFR = 0.0;
      _o2SensorsPresent = 'Desconocido';
      // Resetear sensores de combustible
      _fuelLevel = 0.0;
      _fuelPressure = 0.0;
      _fuelRailPressure = 0.0;
      _fuelRate = 0.0;
      _fuelTrimBank1ShortTerm = 0.0;
      _fuelTrimBank1LongTerm = 0.0;
      _fuelTrimBank2ShortTerm = 0.0;
      _fuelTrimBank2LongTerm = 0.0;
    });
  }

  void _startDataListening() {
    _connection?.input?.listen((Uint8List data) {
      String newData = String.fromCharCodes(data);
      _messageBuffer += newData;

      while (_messageBuffer.contains('>')) {
        int endIndex = _messageBuffer.indexOf('>');
        if (endIndex > 0) {
          String message = _messageBuffer.substring(0, endIndex).trim();
          _processMessage(message);
          _messageBuffer = _messageBuffer.substring(endIndex + 1);
        } else {
          _messageBuffer = '';
        }
      }
    }, onDone: _disconnect);
  }

  void _processMessage(String message) {
    message = message.replaceAll(RegExp(r'[\r\n\s]'), '').toUpperCase();

    if (message.startsWith('4105') && message.length >= 6) {
      // Temperatura refrigerante (0105)
      try {
        int tempValue = int.parse(message.substring(4, 6), radix: 16) - 40;
        setState(() => _coolantTemp = tempValue.toDouble());
        _coolantTemp = tempValue.toDouble();
      } catch (e) {
        print("Error procesando temperatura: $e");
      }
    } else if (message.startsWith('410C') && message.length >= 8) {
      // RPM motor (010C)
      try {
        int rpmValue = int.parse(message.substring(4, 8), radix: 16);
        setState(() => _rpm = rpmValue / 4.0);
        _rpmNotifier.value = rpmValue / 4.0;
      } catch (e) {
        print("Error procesando RPM: $e");
      }
    } else if (message.startsWith('4104') && message.length >= 6) {
      // Carga del motor (0104)
      try {
        int loadValue = int.parse(message.substring(4, 6), radix: 16);
        setState(() => _engineLoad = (loadValue * 100 / 255).toDouble());
        _engineNotifier.value = loadValue.toDouble();
      } catch (e) {
        print("Error procesando carga del motor: $e");
      }
    } else if (message.startsWith('410E') && message.length >= 6) {
      // Avance de encendido (010E)
      try {
        int advanceValue = int.parse(message.substring(4, 6), radix: 16) - 64;
        setState(() => _ignitionAdvance = advanceValue.toDouble());
        _ignitionNotifier.value = advanceValue.toDouble();
      } catch (e) {
        print("Error procesando avance de encendido: $e");
      }
    } else if (message.startsWith('410D') && message.length >= 6) {
      // Velocidad del vehículo (010D)
      try {
        int speedValue = int.parse(message.substring(4, 6), radix: 16);
        setState(() => _speed = speedValue.toDouble());
        _speedNotifier.value = speedValue.toDouble();
      } catch (e) {
        print("Error procesando velocidad: $e");
      }
    } else if (message.startsWith('4110') && message.length >= 8) {
      // Flujo de aire masivo (0110)
      try {
        int mafValue = int.parse(message.substring(4, 8), radix: 16);
        setState(() => _maf = mafValue / 100.0); // Convertir a g/s
        _mafNotifier.value = mafValue.toDouble();
      } catch (e) {
        print("Error procesando MAF: $e");
      }
    } else if (message.startsWith('410B') && message.length >= 6) {
      // Presión del colector de admisión (010B)
      try {
        int pressureValue = int.parse(message.substring(4, 6), radix: 16);
        setState(() => _intakeManifoldPressure = pressureValue.toDouble());
        _intakeMPNotifier.value = pressureValue.toDouble();
      } catch (e) {
        print("Error procesando presión del colector: $e");
      }



    } else if (message.startsWith('4114') && message.length >= 8) {
      // Sensor O2 1 (0114)
      try {
        double voltage = int.parse(message.substring(4, 6), radix: 16) / 200.0;
        double afr =
            int.parse(message.substring(6, 8), radix: 16) / 32768.0 * 14.7;
        setState(() {
          _o2Voltage[0] = voltage;
          _o2AFR[0] = afr;
          _o2VNotifier.value = List.from(_o2Voltage);
          _o2AFRNotifier.value = List.from(_o2AFR);
        });
      } catch (e) {
        print("Error procesando sensor O2 1: $e");
      }
    } else if (message.startsWith('4115') && message.length >= 8) {
      // Sensor O2 2 (0115)
      try {
        double voltage = int.parse(message.substring(4, 6), radix: 16) / 200.0;
        double afr =
            int.parse(message.substring(6, 8), radix: 16) / 32768.0 * 14.7;
        setState(() {
          _o2Voltage[1] = voltage;
          _o2AFR[1] = afr;
          _o2VNotifier.value = List.from(_o2Voltage);
          _o2AFRNotifier.value = List.from(_o2AFR);
        });
      } catch (e) {
        print("Error procesando sensor O2 2: $e");
      }
    } else if (message.startsWith('4116') && message.length >= 8) {
      // Sensor O2 3 (0116)
      try {
        double voltage = int.parse(message.substring(4, 6), radix: 16) / 200.0;
        double afr =
            int.parse(message.substring(6, 8), radix: 16) / 32768.0 * 14.7;
        setState(() {
          _o2Voltage[2] = voltage;
          _o2AFR[2] = afr;
          _o2VNotifier.value = List.from(_o2Voltage);
          _o2AFRNotifier.value = List.from(_o2AFR);
        });
      } catch (e) {
        print("Error procesando sensor O2 3: $e");
      }
    } else if (message.startsWith('4117') && message.length >= 8) {
      // Sensor O2 4 (0117)
      try {
        double voltage = int.parse(message.substring(4, 6), radix: 16) / 200.0;
        double afr =
            int.parse(message.substring(6, 8), radix: 16) / 32768.0 * 14.7;
        setState(() {
          _o2Voltage[3] = voltage;
          _o2AFR[3] = afr;
          _o2VNotifier.value = List.from(_o2Voltage);
          _o2AFRNotifier.value = List.from(_o2AFR);
        });
      } catch (e) {
        print("Error procesando sensor O2 4: $e");
      }
    } else if (message.startsWith('4124') && message.length >= 6) {
      // Relación aire-combustible comandada (0124)
      try {
        double afr = int.parse(message.substring(4, 6), radix: 16) / 32768.0 * 14.7;
        setState(() => _commandedAFR = afr);
        _commandedAFRNotifier.value = afr.toDouble();
      } catch (e) {
        print("Error procesando AFR comandado: $e");
      }
    } 
    // else if (message.startsWith('4134') && message.length >= 6) {
    //   // Sensores de oxígeno presentes (0134)
    //   try {
    //     int sensors = int.parse(message.substring(4, 6), radix: 16);
    //     String present = '';
    //     if (sensors & 0x01 != 0) present += 'B1S1 ';
    //     if (sensors & 0x02 != 0) present += 'B1S2 ';
    //     if (sensors & 0x04 != 0) present += 'B2S1 ';
    //     if (sensors & 0x08 != 0) present += 'B2S2 ';
    //     setState(
    //       () =>
    //           _o2SensorsPresent =
    //               present.isNotEmpty ? present.trim() : 'Ninguno',
    //     );
    //     //////////////////////////////////////////////////////////////
    //     _o2SPNotifier.value = _o2SensorsPresent;
    //   } catch (e) {
    //     print("Error procesando sensores O2 presentes: $e");
    //   }
    // } 
    else if (message.startsWith('412F') && message.length >= 6) {
      // Nivel de combustible (012F)
      try {
        int level = int.parse(message.substring(4, 6), radix: 16) * 100 ~/ 255;
        setState(() => _fuelLevel = level.toDouble());
        _fuelLevelNotifier.value = level.toDouble();
      } catch (e) {
        print("Error procesando nivel de combustible: $e");
      }
    } else if (message.startsWith('410A') && message.length >= 6) {
      // Presión de combustible (010A)
      try {
        int pressure = int.parse(message.substring(4, 6), radix: 16) * 3;
        setState(() => _fuelPressure = pressure.toDouble());
        _fuelPressureNotifier.value = pressure.toDouble();
      } catch (e) {
        print("Error procesando presión de combustible: $e");
      }
    } else if (message.startsWith('4122') && message.length >= 8) {
      // Presión del riel de combustible (0122)
      try {
        double pressure = int.parse(message.substring(4, 8), radix: 16) * 0.079;
        setState(() => _fuelRailPressure = pressure.toDouble());
        _fuelRailPNotifier.value = pressure.toDouble();
      } catch (e) {
        print("Error procesando presión del riel: $e");
      }
    } else if (message.startsWith('415E') && message.length >= 8) {
      // Tasa de consumo de combustible (015E)
      try {
        double rate = int.parse(message.substring(4, 8), radix: 16) * 0.05;
        setState(() => _fuelRate = rate);
        _fuelRateNotifier.value = rate.toDouble();
      } catch (e) {
        print("Error procesando tasa de combustible: $e");
      }
    } else if (message.startsWith('4106') && message.length >= 6) {
      // Ajuste de combustible banco 1 corto plazo (0106)
      try {
        int trim = int.parse(message.substring(4, 6), radix: 16) - 128;
        setState(() => _fuelTrimBank1ShortTerm = trim.toDouble());
        _fuelTrimB1SNotifier.value = trim.toDouble();
      } catch (e) {
        print("Error procesando ajuste banco 1 corto plazo: $e");
      }
    } else if (message.startsWith('4107') && message.length >= 6) {
      // Ajuste de combustible banco 1 largo plazo (0107)
      try {
        int trim = int.parse(message.substring(4, 6), radix: 16) - 128;
        setState(() => _fuelTrimBank1LongTerm = trim.toDouble());
        _fuelTrimB1LNotifier.value = trim.toDouble();
      } catch (e) {
        print("Error procesando ajuste banco 1 largo plazo: $e");
      }
    } else if (message.startsWith('4108') && message.length >= 6) {
      // Ajuste de combustible banco 2 corto plazo (0108)
      try {
        int trim = int.parse(message.substring(4, 6), radix: 16) - 128;
        setState(() => _fuelTrimBank2ShortTerm = trim.toDouble());
        _fuelTrimB2SNotifier.value = trim.toDouble();
      } catch (e) {
        print("Error procesando ajuste banco 2 corto plazo: $e");
      }
    } else if (message.startsWith('4109') && message.length >= 6) {
      // Ajuste de combustible banco 2 largo plazo (0109)
      try {
        int trim = int.parse(message.substring(4, 6), radix: 16) - 128;
        setState(() => _fuelTrimBank2LongTerm = trim.toDouble());
        _fuelTrimB2LNotifier.value = trim.toDouble();
      } catch (e) {
        print("Error procesando ajuste banco 2 largo plazo: $e");
      }



    } else if (message.contains('490201') ||
        message.contains('62194') ||
        message.contains('61194')) {
      // Respuesta del VIN
      try {
        String vinHex = message.replaceAll(RegExp(r'[^0-9A-F]'), '');
        String vin = '';

        if (message.contains('490201')) {
          vinHex = vinHex.substring(vinHex.indexOf('490201') + 6);
        } else if (message.contains('62194')) {
          vinHex = vinHex.substring(vinHex.indexOf('62194') + 5);
        } else if (message.contains('61194')) {
          vinHex = vinHex.substring(vinHex.indexOf('61194') + 5);
        }

        for (int i = 0; i < vinHex.length; i += 2) {
          if (i + 2 > vinHex.length) break;
          String hexPair = vinHex.substring(i, i + 2);
          try {
            int charCode = int.parse(hexPair, radix: 16);
            if (charCode >= 32 && charCode <= 126) {
              vin += String.fromCharCode(charCode);
            }
          } catch (e) {
            print("Error convirtiendo caracter VIN: $e");
          }
        }

        vin = vin.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').trim();

        if (vin.length >= 17) {
          vin = vin.substring(0, 17);
          setState(() => _vin = vin);
        } else if (vin.isNotEmpty) {
          setState(() => _vin = vin);
        }
      } catch (e) {
        print("Error procesando VIN: $e");
      }
    }
      _updateSensors(); 
  }

  void _sendCommand(String command) {
    //pruebas sin obd
    // if (_mockMode) return;
    //pruebas sin obd
    if (_isConnected && _connection != null) {
      command = '$command\r';
      _connection!.output.add(Uint8List.fromList(utf8.encode(command)));
    }
  }

  void _startAutoUpdate() {
    _commandTimer?.cancel();
    _commandTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (_isConnected && _connection != null) {
        _sendCommand(_obdCommands[_currentCommandIndex]);
        _currentCommandIndex = (_currentCommandIndex + 1) % _obdCommands.length;
      } else {
        timer.cancel();
      }
    });
  }

  void _showSensorDialog(BuildContext context, String sensorName, double initialValue) {
    final ValueNotifier<double>? notifier = _getNotifierForSensor(sensorName);
    if (notifier == null) return;

    showDialog(
      context: context,
      builder: (_) => ValueListenableBuilder<double>(
        valueListenable: notifier,
        builder: (context, value, _) => _buildGaugeBySensor(sensorName, value),
      ),
    );
  }

  ValueNotifier<double>? _getNotifierForSensor(String sensorName) {
    switch (sensorName) {
      case 'Velocidad': return _speedNotifier; //'010D', // Velocidad del vehículo
      case 'RPM': return _rpmNotifier; // '010C', // RPM motor
      case 'Temp. Refrigerante': return _cooltempNotifier; //'0105', Temperatura refrigerante
      case 'Carga del motor': return _engineNotifier; //'0104', // Carga del motor
      case 'Avance encendido': return _ignitionNotifier; //'010E', // Avance de encendido
      case 'MAF (g/s)': return _mafNotifier; //'0110', // Flujo de aire masivo (MAF)
      case 'Presión Colector (kPa)': return _intakeMPNotifier; //'010B', // Presión del colector de admisión
      case 'AFR Comandado': return _commandedAFRNotifier; //'0124', // Relación aire-combustible comandada
      // case 'Sensores O2 Activos': return _o2SPNotifier.to;
      case 'Sensor O2 1 (V) [0]': return ValueNotifier(_o2VNotifier.value[0]); //'0114', // Sensor O2 1 - Voltaje y AFR
      case 'Sensor O2 1 (AFR) [0]': return ValueNotifier(_o2AFRNotifier.value[0]);
      case 'Sensor O2 1 (V) [1]': return ValueNotifier(_o2VNotifier.value[1]); //'0115', // Sensor O2 2 - Voltaje y AFR
      case 'Sensor O2 1 (AFR) [1]': return ValueNotifier(_o2AFRNotifier.value[1]);
      case 'Sensor O2 1 (V) [2]': return ValueNotifier(_o2VNotifier.value[2]); //'0116', // Sensor O2 3 - Voltaje y AFR
      case 'Sensor O2 1 (AFR) [2]': return ValueNotifier(_o2AFRNotifier.value[2]);
      case 'Sensor O2 1 (V) [3]': return ValueNotifier(_o2VNotifier.value[3]); //'0117', // Sensor O2 4 - Voltaje y AFR
      case 'Sensor O2 1 (AFR) [3]': return ValueNotifier(_o2AFRNotifier.value[3]);
      case 'Nivel Combustible': return _fuelLevelNotifier; //'012F', // Nivel de combustible
      case 'Presión Combustible': return _fuelPressureNotifier; //'010A', // Presión de combustible
      case 'Presión Riel': return _fuelRailPNotifier; //'0122', // Presión del riel de combustible
      case 'Consumo': return _fuelRateNotifier; //'015E', // Tasa de consumo de combustible
      case 'Banco 1 Corto': return _fuelTrimB1SNotifier; //'0106', // Ajuste de combustible banco 1 corto plazo
      case 'Banco 1 Largo': return _fuelTrimB1LNotifier; //'0107', // Ajuste de combustible banco 1 largo plazo
      case 'Banco 2 Corto': return _fuelTrimB2SNotifier; //'0108', // Ajuste de combustible banco 2 corto plazo
      case 'Banco 2 Largo': return _fuelTrimB2LNotifier; //'0109', // Ajuste de combustible banco 2 largo plazo       
      default: return null;

    //'0134', // Sensores de oxígeno presentes
    }
  }

  Widget _buildGaugeBySensor(String sensorName, double value) {
    switch (sensorName) {
      case 'Velocidad':
        return SpeedometerPage.speedometer(value: value);
      case 'RPM':
        return SpeedometerPage.rpm(value: value);
      // case 'Temp. Refrigerante':
      //   return SpeedometerPage.speedometer(value: value);
      // case 'Carga del motor':
      //   return SpeedometerPage.rpm(value: value);
      // case 'Avance encendido':
      //   return SpeedometerPage.rpm(value: value);
      default:
        return const Center(child: Text('Gauge no disponible'));
    }
  }

  Map<String, dynamic> _getSensorConfig(String title) {
    switch (title) {
      case 'Velocidad':
        return {'unit': 'km/h', 'maxValue': 240.0};
      case 'RPM':
        return {'unit': 'RPM', 'maxValue': 8000.0};
      case 'Temp. Refrigerante':
        return {'unit': '°C', 'maxValue': 150.0};
      case 'Carga del motor':
        return {'unit': 'CM', 'maxValue': 240.0};
      case 'Avance encendido':
        return {'unit': 'AE', 'maxValue': 8000.0};
      case 'MAF (g/s)':
        return {'unit': 'g/s', 'maxValue': 240.0};
      case 'Presión Colector (kPa)':
        return {'unit': 'kPa', 'maxValue': 8000.0};
      case 'AFR Comandado':
        return {'unit': 'AFR', 'maxValue': 150.0};
      // case 'Sensores O2 Activos':
      //   return {'unit': '', 'maxValue': 150.0};
      case 'Nivel Combustible':
        return {'unit': 'NC', 'maxValue': 240.0};
      case 'Presión Combustible':
        return {'unit': 'PC', 'maxValue': 8000.0};
      case 'Presión Riel':
        return {'unit': 'PR', 'maxValue': 240.0};
      case 'Consumo':
        return {'unit': 'C', 'maxValue': 8000.0};
      case 'Banco 1 Corto':
        return {'unit': 'B1C', 'maxValue': 150.0};
      case 'Banco 1 Largo':
        return {'unit': 'B1L', 'maxValue': 240.0};
      case 'Banco 2 Corto':
        return {'unit': 'B2C', 'maxValue': 8000.0};
      case 'Banco 2 Largo':
        return {'unit': 'B2L', 'maxValue': 8000.0};
      default:
        return {'unit': '', 'maxValue': 100.0};
    }
  }

  Future<void> _getVin() async {
    if (!_isConnected || _connection == null || _isFetchingVin) return;

    setState(() {
      _isFetchingVin = true;
      _vin = 'Buscando VIN...';
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Obteniendo VIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_vin),
            SizedBox(height: 20),
            // CircularProgressIndicator(),
          ],
        ),
      ),
    );

    try {
      bool vinFound = false;
      final maxAttempts = _vinCommands.length;
      int attempts = 0;

      while (!vinFound && attempts < maxAttempts) {
        _sendCommand(_vinCommands[_currentVinCommandIndex]);
        await Future.delayed(Duration(seconds: 3));

        if (_vin.length >= 17 &&
            _vin != 'No disponible' &&
            _vin != 'Buscando VIN...') {
          vinFound = true;
        } else {
          _currentVinCommandIndex =
              (_currentVinCommandIndex + 1) % _vinCommands.length;
          attempts++;
        }
      }

      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('VIN del Vehículo'),
          content: Text(
            _vin.length >= 17 ? _vin : 'No se pudo obtener el VIN',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Error obteniendo VIN: $e");
      Navigator.of(context).pop();
      _showError("Error al obtener el VIN");
    } finally {
      setState(() => _isFetchingVin = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showDeviceList(BuildContext context) {
    //pruebas sin obd
    // if (_mockMode) {
    //   showDialog(
    //     context: context,
    //     builder: (context) => AlertDialog(
    //       title: Text('Modo Simulación'),
    //       content: Text('Usando datos de prueba'),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.pop(context),
    //           child: Text('Cerrar'),
    //         ),
    //       ],
    //     ),
    //   );
    //   return;
    // }
    //pruebas sin obd
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dispositivos Bluetooth'),
          content: _connection != null && _connection!.isConnected
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Conectado a: ${_device?.name ?? 'Desconocido'}'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        await _connection!.close();
                        _connection = null;
                        _device = null;
                        Navigator.pop(context);
                      },
                      child: const Text('Desconectar'),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _devicesList.map((device) {
                    return ListTile(
                      title: Text(device.name ?? "Sin nombre"),
                      subtitle: Text(device.address),
                      onTap: () async {
                        try {
                          BluetoothConnection connection =
                              await BluetoothConnection.toAddress(device.address);
                          _connection = connection;
                          _device = device;
                          Navigator.pop(context);
                        } catch (e) {
                          print('Error al conectar: $e');
                        }
                      },
                    );
                  }).toList(),
                ),
        );
      },
    );
  }

  void _updateSensors() {
    _sensors = [
      {
        'nombre': 'Velocidad',
        'valor': _speed,
        'unidad': 'km/h',
      },
      {
        'nombre': 'RPM',
        'valor': _rpm,
        'unidad': 'RPM',
      },
      {
        'nombre': 'Temp. Refrigerante',
        'valor': _coolantTemp,
        'unidad': '°C',
      },
      {
        'nombre': 'Carga del motor',
        'valor': _engineLoad,
        'unidad': '%',
      },
      {
        'nombre': 'Avance encendido',
        'valor': _ignitionAdvance,
        'unidad': '°',
      },
      {
        'nombre': 'Flujo aire masivo',
        'valor': _maf,
        'unidad': 'g/s',
      },
      {
        'nombre': 'Presión colector admisión',
        'valor': _intakeManifoldPressure,
        'unidad': 'kPa',
      },
      for (int i = 0; i < _o2Voltage.length; i++)
        if (_o2Voltage[i] > 0)
          {
            'nombre': 'Sensor O2 ${i + 1} (V)',
            'valor': _o2Voltage[i],
            'unidad': 'V',
          },
      for (int i = 0; i < _o2AFR.length; i++)
        if (_o2AFR[i] > 0)
          {
            'nombre': 'Sensor O2 ${i + 1} (AFR)',
            'valor': _o2AFR[i],
            'unidad': 'AFR',
          },
      {
        'nombre': 'AFR Comandado',
        'valor': _commandedAFR,
        'unidad': '',
      },
      // {
      //   'nombre': 'Sensores O2 Activos',
      //   'valor': _o2SensorsPresent,
      //   'unidad': '',
      // },
      {
        'nombre': 'Nivel Combustible',
        'valor': _fuelLevel,
        'unidad': '%',
      },
      {
        'nombre': 'Presión Combustible',
        'valor': _fuelPressure,
        'unidad': 'kPa',
      },
      {
        'nombre': 'Presión Riel',
        'valor': _fuelRailPressure,
        'unidad': 'kpa',
      },
      {
        'nombre': 'Consumo',
        'valor': _fuelRate,
        'unidad': 'L/h',
      },
      {
        'nombre': 'Banco 1 Corto',
        'valor': _fuelTrimBank1ShortTerm,
        'unidad': '%',
      },
      {
        'nombre': 'Banco 1 Largo',
        'valor': _fuelTrimBank1LongTerm,
        'unidad': '%',
      },
      {
        'nombre': 'Banco 2 Corto',
        'valor': _fuelTrimBank2ShortTerm,
        'unidad': '%',
      },
      {
        'nombre': 'Banco 2 Largo',
        'valor': _fuelTrimBank2LongTerm,
        'unidad': '%',
      },
    ];
    
    _sensorsNotifier.value = _sensors;
  }

  void _handleSensorTap(String sensorName, BuildContext context) {
    switch (sensorName) {
      case 'Velocidad': 
        _showSpeedometerDialog(context, _speed);
        break;
      case 'RPM':
        _showRpmDialog(context, _rpm);
      case 'Temp. Refrigerante':
        _showengineLoadDialog(context, _engineLoad);
      case 'Carga del motor':
        _showcoolTempDialog(context, _coolantTemp);
      case 'Avance encendido':
        _showignitionAdvanceDialog(context, _ignitionAdvance);
      case 'Flujo aire masivo':
        _showmafDialog(context, _maf);
      case 'Presión colector admisión':
        _showintakeMPialog(context, _intakeManifoldPressure);
      // case 'Sensores O2 Activos':
      //   _showO2SensorsDialog(context); ///
      case 'Sensor O2 1 (V)':
        _showO2VoltageDialog(context, 1, _o2Voltage[0]);
      case 'Sensor O2 1 (AFR)':
        _showO2AFRDialog(context, 1, _o2AFR[0]);
      case 'Sensor O2 2 (V)':
        _showO2VoltageDialog(context, 2, _o2Voltage[1]);
      case 'Sensor O2 2 (AFR)':
        _showO2AFRDialog(context, 2, _o2AFR[1]);
      case 'Sensor O2 3 (V)':
        _showO2VoltageDialog(context, 3, _o2Voltage[2]);
      case 'Sensor O2 3 (AFR)':
        _showO2AFRDialog(context, 3, _o2AFR[2]);
      case 'Sensor O2 4 (V)':
        _showO2VoltageDialog(context, 4, _o2Voltage[3]);
      case 'Sensor O2 4 (AFR)':
        _showO2AFRDialog(context, 4, _o2AFR[3]);
      case 'AFR Comandado':
        _showcommandedAFRDialog(context, _commandedAFR);
      case 'Nivel Combustible':
        _showfuelLevelDialog(context, _fuelLevel);
      case 'Presión Combustible':
        _showfuelPDialog(context, _fuelPressure);
      case 'Presión Riel':
        _showfuelRPDialog(context, _fuelRailPressure);
      case 'Consumo':
        _showfuelRialog(context, _fuelRate);
      case 'Banco 1 Corto':
        _showfuelB1SDialog(context, _fuelTrimBank1ShortTerm);
      case 'Banco 1 Largo':
        _showfuelB1LDialog(context, _fuelTrimBank1LongTerm);
      case 'Banco 2 Corto':
        _showfuelB2SDialog(context, _fuelTrimBank2ShortTerm);
      case 'Banco 2 Largo':
        _showfuelB2LDialog(context, _fuelTrimBank2LongTerm);
        break;
      // Agrega más casos según necesites
    }
  }

  void _showSpeedometerDialog(BuildContext context, double speed) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor, width: 2),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: SensorCard(
          title: 'Velocidad',
          value: speed.toString(),
        ),
      ),
    );
  }
  void _showRpmDialog(BuildContext context, double rpm) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor, width: 2),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: SensorCard(
          title: 'RPM',
          value: rpm.toString(),
        ),
      ),
    );
  }
  void _showcoolTempDialog(BuildContext context, double coolantTemp) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor, width: 2),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: SensorCard(
          title: 'Temp. Refrigerante',
          value: coolantTemp.toString(),
        ),
      ),
    );
  }
  void _showengineLoadDialog(BuildContext context, double engineLoad) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor, width: 2),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: SensorCard(
          title: 'Carga del motor',
          value: engineLoad.toString(),
        ),
      ),
    );
  }
  void _showignitionAdvanceDialog(BuildContext context, double ignitionAdvance) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor, width: 2),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: SensorCard(
          title: 'Avance encendido',
          value: ignitionAdvance.toString(),
        ),
      ),
    );
  }
  void _showmafDialog(BuildContext context, double _maf) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor, width: 2),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: SensorCard(
          title: 'Flujo aire masivo',
          value: _maf.toString(),
        ),
      ),
    );
  }

  void _showintakeMPialog(BuildContext context, double _intakeManifoldPressure) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor, width: 2),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: SensorCard(
          title: 'Presión colector admisión',
          value: _intakeManifoldPressure.toString(),
        ),
      ),
    );
  }

  // void _showO2SensorsDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     barrierColor: Colors.black54,
  //     builder: (_) => Dialog(
  //       backgroundColor: Colors.black,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         side: BorderSide(color: primaryColor, width: 2),
  //       ),
  //       insetPadding: const EdgeInsets.all(20),
  //       child: Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'Sensores O2 Activos',
  //               style: TextStyle(
  //                 color: primaryColor,
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             SizedBox(height: 10),
  //             Text(
  //               _o2SensorsPresent,
  //               style: TextStyle(color: Colors.white, fontSize: 16),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _showO2VoltageDialog(BuildContext context, int sensorNumber, double voltage) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor, width: 2),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: SensorCard(
          title: 'Sensor O2 $sensorNumber (V)',
          value: '${voltage.toStringAsFixed(2)} V',
        ),
      ),
    );
  }

  void _showO2AFRDialog(BuildContext context, int sensorNumber, double afr) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor, width: 2),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: SensorCard(
          title: 'Sensor O2 $sensorNumber (AFR)',
          value: '${afr.toStringAsFixed(1)} AFR',
        ),
      ),
    );
  }

  void _showcommandedAFRDialog(BuildContext context, double _commandedAFR) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor, width: 2),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: SensorCard(
          title: 'AFR Comandado',
          value: _commandedAFR.toString(),
        ),
      ),
    );
  }

  void _showfuelLevelDialog(BuildContext context, double _fuelLevel) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor, width: 2),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: SensorCard(
          title: 'Nivel Combustible',
          value: _fuelLevel.toString(),
        ),
      ),
    );
  }

  void _showfuelPDialog(BuildContext context, double _fuelPressure) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor, width: 2),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: SensorCard(
          title: 'Presión Combustible',
          value: _fuelPressure.toString(),
        ),
      ),
    );
  }

  void _showfuelRPDialog(BuildContext context, double _fuelRailPressure) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor, width: 2),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: SensorCard(
          title: 'Presión Riel',
          value: _fuelRailPressure.toString(),
        ),
      ),
    );
  }

  void _showfuelRialog(BuildContext context, double _fuelRate) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor, width: 2),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: SensorCard(
          title: 'Consumo',
          value: _fuelRate.toString(),
        ),
      ),
    );
  }

  void _showfuelB1SDialog(BuildContext context, double _fuelTrimBank1ShortTerm) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor, width: 2),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: SensorCard(
          title: 'Banco 1 Corto',
          value: _fuelTrimBank1ShortTerm.toString(),
        ),
      ),
    );
  }

  void _showfuelB1LDialog(BuildContext context, double _fuelTrimBank1LongTerm) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor, width: 2),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: SensorCard(
          title: 'Banco 1 Largo',
          value: _fuelTrimBank1LongTerm.toString(),
        ),
      ),
    );
  }

  void _showfuelB2SDialog(BuildContext context, double _fuelTrimBank2ShortTerm) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor, width: 2),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: SensorCard(
          title: 'Banco 2 Corto',
          value: _fuelTrimBank2ShortTerm.toString(),
        ),
      ),
    );
  }

  void _showfuelB2LDialog(BuildContext context, double _fuelTrimBank2LongTerm) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor, width: 2),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: SensorCard(
          title: 'Banco 2 Largo',
          value: _fuelTrimBank2LongTerm.toString(),
        ),
      ),
    );
  }


  @override
  void dispose() {
    homeController.dispose();
    batteryAnimatedController.dispose();
    tempratureAnimationController.dispose();
    tyresAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // this animation need listnable
      animation: Listenable.merge([
        homeController,
        batteryAnimatedController,
        tempratureAnimationController,
        tyresAnimationController,
        carShiftLeftAnimation,
      ]),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
        title: const Text("Inicio"),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () => _showDeviceList(context),
            tooltip: "Conectar Bluetooth",
          )
        ],
      ),
        bottomNavigationBar: ButtomNavBar(
          selectedButtom: homeController.selectedButtom,
          onTap: (index) {
            // condition to start animation
            // battery screen animation
            if (index == 1) {
              batteryAnimatedController.forward();
            } else if (homeController.selectedButtom == 1 && index != 1) {
              batteryAnimatedController.reverse(from: 0.2);
            }
            // end battery screen contion
            ///
            ///temprature screen condition start
            if (index == 2) {
              tempratureAnimationController.forward();
            } else if (homeController.selectedButtom == 2 && index != 2) {
              tempratureAnimationController.reverse(from: 0.2);
            }

            /// temp screen end here
            ///
            /// tyres start here
            ///
            if (index == 3) {
              tyresAnimationController.forward();
            } else if (homeController.selectedButtom == 3 && index != 3) {
              tyresAnimationController.reverse();
            }
            homeController.showTyresController(index);
            homeController.tyresStatusController(index);

            ///
            homeController.selectedButtonsNavBarChange(index);
          },
        ),
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            // 1) CALCULA variables ANTES de la lista de widgets:
            final halfWidth = constraints.maxWidth / 2;
            final shiftRight = halfWidth * carShiftAnimation.value;
            final shiftLeft = halfWidth * carShiftLeftAnimation.value;

            // 2) Decide el offset en base al botón activo:
            double leftOffset;
            if (homeController.selectedButtom == 2) {
              leftOffset = shiftRight; // Temperatura → derecha
            } else if (homeController.selectedButtom == 1) {
              leftOffset = -shiftLeft; // Índice 1 → izquierda
            } else {
              leftOffset = 0; // Cualquier otro → centrado
            }
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                ),
                Positioned(
                  left: leftOffset,
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: constraints.maxHeight * 0.1,
                    ),
                    child: SvgPicture.asset(
                      ///
                      "assets/icons/Car.svg",
                      width: double.infinity,
                    ),
                  ),
                ),
                if (homeController.selectedButtom == 0)
                  Positioned.fill(
                    child: Opacity(
                      opacity: 1.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 0),
                        child: DoorLock(),
                      ),
                    ),
                  ),

                /// Battery screen start here
                ///
                // Opacity(
                //   opacity: batteryAnimation.value,
                //   child: SvgPicture.asset(
                //     "assets/icons/Battery.svg",
                //     width: constraints.maxWidth * 0.46,
                //   ),
                // ),
                Positioned(
                  top: 50 * (1 - batteryStatusAnimation.value),
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  child: Opacity(
                    opacity: batteryStatusAnimation.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: BatteryStatus(constraints: constraints),
                      ),
                    ),
                  ),
                ),

                /// Battery Screen end here
                ///
                /// temprature screen start here
                ///
                Positioned(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  top: 60 * (1 - tempratureShowInfoAnimation.value),
                  child: Opacity(
                    opacity: tempratureShowInfoAnimation.value,
                    child: TempDetails(homeController: homeController),
                  ),
                ),

                Positioned(
                  right: -180 * (1 - temCoolGlowAnimation.value),
                  child: AnimatedSwitcher(
                    duration: defaultDuration,
                    child: homeController.isCoolSelected
                        ? Image.asset(
                            "assets/images/Cool_glow_2.png",
                            width: 200,
                            key: UniqueKey(),
                          )
                        : Image.asset(
                            "assets/images/Hot_glow_4.png",
                            width: 200,
                            key: UniqueKey(),
                          ),
                  ),
                ),

                /// temprature screen end here
                ///
                /// tyre screen start here
                ///
                if (homeController.isTyresStatus)
                Positioned.fill(
                  child: Opacity(
                    opacity: 1.0,
                    child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _sensorsNotifier,
                      builder: (context, sensors, _) {
                        final sensoresFiltrados = sensors.where((sensor) => [
                          "Velocidad",
                          "RPM",
                          "Temp. Refrigerante",
                          "Avance encendido",
                          "Carga del motor",
                          "Avance encendido",
                          "Flujo aire masivo",
                          "Presión colector admisión",
                          // "Sensores O2 Activos", ///
                          "Sensor O2 1 (V)", 
                          "Sensor O2 1 (AFR)", 
                          "Sensor O2 2 (V)", 
                          "Sensor O2 2 (AFR)",
                          "AFR Comandado", ///
                          "Nivel Combustible",
                          "Presión Combustible",
                          "Presión Riel",
                          "Consumo",
                          "Banco 1 Corto",
                          "Banco 1 Largo",
                          "Banco 2 Corto",
                          "Banco 2 Largo",
                        ].contains(sensor['nombre'])).toList();

                        return GridView.builder(
                          padding: const EdgeInsets.all(8),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15,
                            childAspectRatio: constraints.maxWidth / constraints.maxHeight / 0.7,
                          ),
                          itemCount: sensoresFiltrados.length,
                          itemBuilder: (context, index) {
                            final sensor = sensoresFiltrados[index];
                            return ScaleTransition(
                              scale: tyresAnimation[index % tyresAnimation.length],
                              child: InkWell(
                                onTap: () => _showSensorDialog(
                                  context,
                                  sensor['nombre'], // Pasar el nombre del sensor
                                  sensor['valor'].toDouble(),
                                ),
                                child: SensorCard(
                                  title: sensor['nombre'],
                                  value: '${sensor['valor'].toStringAsFixed(1)} ${sensor['unidad']}',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                /// tyre screen end here
                ///
                ///
              ],
            );
          }),
        ),
      ),
    );
  }
}
