import 'dart:math';
import 'dart:io';
import 'package:obdv2/core/constants.dart';
import 'package:obdv2/core/home_controller.dart';
import 'package:obdv2/core/model/tyres_model.dart';
import 'package:obdv2/pages/dashboard/dashboard_page.dart';
import 'package:obdv2/pages/graphs/graphs_page.dart';
import 'package:obdv2/screens/widgets/battery_status.dart';
import 'package:obdv2/screens/widgets/button_nav_bar.dart';
import 'package:obdv2/screens/widgets/door_lock.dart';
import 'package:obdv2/screens/widgets/temp_details.dart';
import 'package:obdv2/screens/widgets/tyres_list.dart';
import 'package:obdv2/screens/widgets/tyres_psi_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:collection/collection.dart';
import 'package:obdv2/pages/login_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final Map<String, List<double>> sensorHistory = {
    'Voltaje': [],
    'Temp. Refrigerante': [],
    'Carga del motor': [],
    'Nivel Combustible': [],
    'Presión Combustible': [],
    'Consumo': [],
    'Sensor O2 1 (V) [0]': [],
    'Sensor O2 1 (AFR) [0]': [],
    'Sensor O2 2 (V) [1]': [],
    'Sensor O2 2 (AFR) [1]': [],
    'Sensor O2 3 (V) [2]': [],
    'Sensor O2 3 (AFR) [2]': [],
    'Sensor O2 4 (V) [3]': [],
    'Sensor O2 4 (AFR) [3]': [],
  };

  //pruebas sin obd
  bool _mockMode = true;
  //pruebas sin obd
  final _formKey = GlobalKey<FormState>();

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
  double _voltage = 0.0;

  // Variables para sensores de oxígeno
  List<double> _o2Voltage = [0.0, 0.0, 0.0, 0.0];
  List<double> _o2AFR = [0.0, 0.0, 0.0, 0.0];
  double _commandedAFR = 0.0;
  //String _o2SensorsPresent = 'Desconocido';

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
  // double _catalizadorB1S1 = 0.0;
  // double _catalizadorB1S2 = 0.0;
  // double _catalizadorB2S1 = 0.0;
  // double _catalizadorB2S2 = 0.0;

  final ValueNotifier<double> _speedNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _rpmNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _cooltempNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _engineNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _ignitionNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _mafNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _intakeMPNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _voltageNotifier = ValueNotifier(0.0);

  final ValueNotifier<List<double>> _o2VNotifier =
      ValueNotifier([0.0, 0.0, 0.0, 0.0]);
  final ValueNotifier<List<double>> _o2AFRNotifier =
      ValueNotifier([0.0, 0.0, 0.0, 0.0]);
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

  // final ValueNotifier<double> _catB1S1Notifier = ValueNotifier(0.0);
  // final ValueNotifier<double> _catB1S2Notifier = ValueNotifier(0.0);
  // final ValueNotifier<double> _catB2S1Notifier = ValueNotifier(0.0);
  // final ValueNotifier<double> _catB2S2Notifier = ValueNotifier(0.0);

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
    '0142', // Voltaje del motor
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
    // '013C', // Catalizador de temperatura B1S1
    // '013D', // Catalizador de temperatura B2S1
    // '013E', // Catalizador de temperatura B1S2
    // '01EF', // Catalizador de temperatura B2S2
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
    _requestPermissions();
    sensorHistory['Voltaje'] = [];
    sensorHistory['Carga del motor'] = [];
    sensorHistory['Nivel Combustible'] = [];
    sensorHistory['Presión Combustible'] = [];
    sensorHistory['Consumo'] = [];
    for (int i = 0; i < 4; i++) {
      sensorHistory['Sensor O2 ${i + 1} (V)'] = [];
      sensorHistory['Sensor O2 ${i + 1} (AFR)'] = [];
    }
    //pruebas sin obd

    if (_mockMode) {
      _isConnected = true; // Simular conexión exitosa
      _startMockDataGeneration();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureConnection();
      });
      _checkBluetoothState();
    }

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

  //pruebas sin obd
  void _startMockDataGeneration() {
    Timer.periodic(Duration(milliseconds: 2000), (timer) {
      if (!_mockMode) {
        timer.cancel();
        return;
      }

      final random = Random();
      // Genera valores aleatorios para TODOS los sensores
      final newSpeed = random.nextDouble() * 200;
      final newRpm = random.nextDouble() * 8000;
      final newVoltaje = random.nextDouble() * 20;
      final newTemp = random.nextDouble() * 105;
      final newO2Voltage = List.generate(4, (index) => random.nextDouble() * 5);
      final newO2AFR = List.generate(4, (index) => random.nextDouble() * 20);

      final newCM = random.nextDouble() * 100;
      final newAE = random.nextDouble() * 40;
      final newFAM = random.nextDouble() * 20;
      final newPCA = random.nextDouble() * 100;
      final newAFR = random.nextDouble() * 20;
      final newNC = random.nextDouble() * 100;
      final newPC = random.nextDouble() * 400;
      final newPR = random.nextDouble() * 1500;
      final newC = random.nextDouble() * 20;
      final newB1S = random.nextDouble() * 10;
      final newB1L = random.nextDouble() * 10;
      final newB2S = random.nextDouble() * 10;
      final newB2L = random.nextDouble() * 10;

      // Actualiza sensorHistory
      _onSensorDataReceived('Voltaje', newVoltaje);
      _onSensorDataReceived('Temp. Refrigerante', newTemp);
      for (int i = 0; i < 4; i++) {
        _onSensorDataReceived('Sensor O2 ${i + 1} (V)', newO2Voltage[i]);
        _onSensorDataReceived('Sensor O2 ${i + 1} (AFR)', newO2AFR[i]);
      }

      // Actualiza ValueNotifiers y estado
      setState(() {
        _speed = newSpeed;
        _rpm = newRpm;
        _voltage = newVoltaje;
        _o2Voltage = newO2Voltage;
        _o2AFR = newO2AFR;
        _coolantTemp = newTemp;
        _engineLoad = newCM;
        _ignitionAdvance = newAE;
        _maf = newFAM;
        _intakeManifoldPressure = newPCA;
        _commandedAFR = newAFR;
        _fuelLevel = newNC;
        _fuelPressure = newPC;
        _fuelRailPressure = newPR;
        _fuelRate = newC;
        _fuelTrimBank1ShortTerm = newB1S;
        _fuelTrimBank1LongTerm = newB1L;
        _fuelTrimBank2ShortTerm = newB2S;
        _fuelTrimBank2LongTerm = newB2L;
      });

      _speedNotifier.value = newSpeed;
      _rpmNotifier.value = newRpm;
      _voltageNotifier.value = newVoltaje;
      _cooltempNotifier.value = newTemp;
      _o2VNotifier.value = newO2Voltage;
      _o2AFRNotifier.value = newO2AFR;
      _engineNotifier.value = newCM;
      _ignitionNotifier.value = newAE;
      _mafNotifier.value = newFAM;
      _intakeMPNotifier.value = newPCA;
      _commandedAFRNotifier.value = newAFR;
      _fuelLevelNotifier.value = newNC;
      _fuelPressureNotifier.value = newPC;
      _fuelRailPNotifier.value = newPR;
      _fuelRateNotifier.value = newC;
      _fuelTrimB1SNotifier.value = newB1S;
      _fuelTrimB1LNotifier.value = newB1L;
      _fuelTrimB2SNotifier.value = newB2S;
      _fuelTrimB2LNotifier.value = newB2L;

      //print(_voltage);
      print(_coolantTemp);

      _updateSensors();
    });
  }

  Future<void> _requestPermissions() async {
    // BLUETOOTH CONNECT (Android 12+)
    var bluetoothConnectStatus = await Permission.bluetoothConnect.request();

    if (bluetoothConnectStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permiso de Bluetooth concedido.')),
      );
    } else if (bluetoothConnectStatus.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permiso de Bluetooth denegado.')),
      );
    } else if (bluetoothConnectStatus.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Permiso de Bluetooth denegado permanentemente. Por favor, habilítalo en la configuración.'),
        ),
      );
      openAppSettings();
    }

    // NEARBY DEVICES (Android 12+)
    var nearbyStatus = await Permission.nearbyWifiDevices.request();

    if (nearbyStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permiso de dispositivos cercanos concedido.')),
      );
    } else if (nearbyStatus.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permiso de dispositivos cercanos denegado.')),
      );
    } else if (nearbyStatus.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Permiso de dispositivos cercanos denegado permanentemente. Por favor, habilítalo en la configuración.'),
        ),
      );
      openAppSettings();
    }
    // LOCATION (IMPORTANTE PARA ESCANEOS EN ALGUNAS VERSIONES)
    var locationStatus = await Permission.location.request();

    if (locationStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permiso de ubicación concedido.')),
      );
    } else if (locationStatus.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permiso de ubicación denegado.')),
      );
    } else if (locationStatus.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Permiso de ubicación denegado permanentemente. Habilítalo en la configuración.'),
        ),
      );
      openAppSettings();
    }
  }

  Future<void> generarYGuardarPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
          build: (context) => [
                pw.Center(
                  child: pw.Text(
                    'Informe de Diagnóstico OBDII',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Fecha y Hora del Informe: ${DateTime.now().toLocal().toString().split(' ')[0]} ${DateTime.now().toLocal().hour.toString().padLeft(2, '0')}:${DateTime.now().toLocal().minute.toString().padLeft(2, '0')}:${DateTime.now().toLocal().second.toString().padLeft(2, '0')}',
                ),
                pw.SizedBox(height: 20),
                // --- Título de Sección: Sensores del Motor ---
                pw.Text('SENSORES DEL MOTOR',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5), // Espacio pequeño entre título y tabla

                // --- Tabla de Sensores del Motor ---
                pw.Table(
                  border: pw.TableBorder.all(width: 0.5),
                  columnWidths: {
                    0: pw.FlexColumnWidth(4), // Columna para la etiqueta
                    1: pw.FlexColumnWidth(6), // Columna para el valor
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('Velocidad:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 6,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('$_speed km/h'),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('RPM:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 6,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('$_rpm RPM'),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('Temp. Refrigerante:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 6,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('$_coolantTemp °C'),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('Carga del Motor:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 6,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('$_engineLoad %'),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('Avance Encendido:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 6,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('$_ignitionAdvance °'),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('Flujo MAF:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 6,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('$_maf g/s'),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('Presión Múltiple Admisión:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 6,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('$_intakeManifoldPressure kPa'),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('Voltaje Batería:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 6,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('$_voltage V'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),

                // --- Título de Sección: Sensores de Oxígeno ---
                pw.Text('SENSORES DE OXÍGENO',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5), // Espacio pequeño entre título y tabla

                // --- Tabla de Sensores de Oxígeno ---
                pw.Table(
                  border: pw.TableBorder.all(width: 0.5),
                  columnWidths: {
                    0: pw.FlexColumnWidth(4),
                    1: pw.FlexColumnWidth(6),
                  },
                  children: [
                    for (int i = 0; i < _o2Voltage.length; i++)
                      pw.TableRow(
                        children: [
                          pw.Expanded(
                            flex: 4,
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 5),
                              child: pw.Text('O2 Sensor ${i + 1} Voltaje:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                            ),
                          ),
                          pw.Expanded(
                            flex: 6,
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 5),
                              child: pw.Text('${_o2Voltage[i]} V'),
                            ),
                          ),
                        ],
                      ),
                    for (int i = 0; i < _o2AFR.length; i++)
                      pw.TableRow(
                        children: [
                          pw.Expanded(
                            flex: 4,
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 5),
                              child: pw.Text('O2 Sensor ${i + 1} AFR:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                            ),
                          ),
                          pw.Expanded(
                            flex: 6,
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 5),
                              child: pw.Text('${_o2AFR[i]}'),
                            ),
                          ),
                        ],
                      ),
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('AFR Comandado:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 6,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('$_commandedAFR'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),

                // --- Título de Sección: Sistema de Combustible ---
                pw.Text('SISTEMA DE COMBUSTIBLE',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5), // Espacio pequeño entre título y tabla

                // --- Tabla de Sistema de Combustible ---
                pw.Table(
                  border: pw.TableBorder.all(width: 0.5),
                  columnWidths: {
                    0: pw.FlexColumnWidth(4),
                    1: pw.FlexColumnWidth(6),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('Nivel de Combustible:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 6,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('$_fuelLevel %'),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('Presión de Combustible:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 6,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('$_fuelPressure kPa'),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('Presión Riel Combustible:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 6,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('$_fuelRailPressure kPa'),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('Tasa de Consumo:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 6,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('$_fuelRate L/h'),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('Ajuste Comb. Corto Plazo B1:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 6,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('$_fuelTrimBank1ShortTerm %'),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('Ajuste Comb. Largo Plazo B1:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 6,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('$_fuelTrimBank1LongTerm %'),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('Ajuste Comb. Corto Plazo B2:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 6,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('$_fuelTrimBank2ShortTerm %'),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('Ajuste Comb. Largo Plazo B2:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 6,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 5),
                            child: pw.Text('$_fuelTrimBank2LongTerm %'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                pw.Text(
                  'Nota: Los valores mostrados son instantáneas del diagnóstico al momento de la generación del informe.',
                  style: pw.TextStyle(
                      fontSize: 10, fontStyle: pw.FontStyle.italic),
                ),
              ]),
    );
    // Solicitar permisos de almacenamiento externo
    var status = await Permission.storage.request();
    if (status.isGranted) {
      // Obtener el directorio de Descargas
      final now = DateTime.now();
      final dateTimeFormatted = "${now.year}-"
          "${now.month.toString().padLeft(2, '0')}-"
          "${now.day.toString().padLeft(2, '0')}_"
          "${now.hour.toString().padLeft(2, '0')}-"
          "${now.minute.toString().padLeft(2, '0')}-"
          "${now.second.toString().padLeft(2, '0')}";
      final filename = "analisis_informe_obd_$dateTimeFormatted.pdf";

      final downloadsDir = Directory('/storage/emulated/0/Download');
      final file = File("${downloadsDir.path}/$filename");

      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF guardado en: ${file.path}')),
      );
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permiso de almacenamiento denegado.')),
      );
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Permiso de almacenamiento denegado permanentemente. Por favor, habilítalo en la configuración de la aplicación.')),
      );
      openAppSettings();
    }
  }
  //pruebas sin obd

  void _ensureConnection() {
    //pruebas sin obd
    if (!_mockMode && !_isConnected) {
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
    if (_mockMode) return;
    //pruebas sin obd
    if (_isConnecting) return;

    // Verificamos que sea un OBD (opcionalmente con un nombre que lo indique)
    if (!(device.name?.toLowerCase().contains("obd") ?? false)) {
      _showError(
          "Este dispositivo no parece ser un OBD. Selecciona uno válido.");
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
      _voltage = 0.0;
      _vin = 'No disponible';
      _isFetchingVin = false;

      // Resetear sensores O2
      _o2Voltage = [0.0, 0.0, 0.0, 0.0];
      _o2AFR = [0.0, 0.0, 0.0, 0.0];
      _commandedAFR = 0.0;
      //_o2SensorsPresent = 'Desconocido';
      // Resetear sensores de combustible
      _fuelLevel = 0.0;
      _fuelPressure = 0.0;
      _fuelRailPressure = 0.0;
      _fuelRate = 0.0;
      _fuelTrimBank1ShortTerm = 0.0;
      _fuelTrimBank1LongTerm = 0.0;
      _fuelTrimBank2ShortTerm = 0.0;
      _fuelTrimBank2LongTerm = 0.0;
      // _catalizadorB1S1 = 0.0;
      // _catalizadorB1S2 = 0.0;
      // _catalizadorB2S1 = 0.0;
      // _catalizadorB2S2 = 0.0;
    });
  }

  // Diálogo de información del VIN
  Future<void> _showVinDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hola'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
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

  void _onSensorDataReceived(String key, double value) {
    setState(() {
      sensorHistory[key] = [
        ...sensorHistory[key]!,
        value
      ]; // Agrega nuevo valor
      if (sensorHistory[key]!.length > 50) {
        sensorHistory[key]!.removeAt(0); // Mantén máximo 50 valores
      }
    });
  }

  void _enviarDatoAFirebaseMotor(String nombreDato, dynamic valor) {
    final DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('SensoresMotor')
        .child(nombreDato);
    ref.set(valor).then((_) {
      print('Dato "$nombreDato" enviado correctamente: $valor');
    }).catchError((error) {
      print('Error al enviar "$nombreDato": $error');
    });
  }

  void _enviarDatoAFirebaseOxigeno(String nombreDato, dynamic valor) {
    final DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('SensoresOxigeno')
        .child(nombreDato);
    ref.set(valor).then((_) {
      print('Dato "$nombreDato" enviado correctamente: $valor');
    }).catchError((error) {
      print('Error al enviar "$nombreDato": $error');
    });
  }

  void _enviarDatoAFirebaseCombustible(String nombreDato, dynamic valor) {
    final DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('SensoresCombustible')
        .child(nombreDato);
    ref.set(valor).then((_) {
      print('Dato "$nombreDato" enviado correctamente: $valor');
    }).catchError((error) {
      print('Error al enviar "$nombreDato": $error');
    });
  }

  void _processMessage(String message) {
    message = message.replaceAll(RegExp(r'[\r\n\s]'), '').toUpperCase();
    if (message.startsWith('410C') && message.length >= 8) {
      try {
        final rpmHex = message.substring(4, 8);
        final rpmValue = int.parse(rpmHex, radix: 16) / 4.0;
        setState(() => _rpm = rpmValue);
        _rpmNotifier.value = rpmValue;
        _enviarDatoAFirebaseMotor('RPM', rpmValue);
      } catch (e) {
        print("Error procesando RPM: $e");
      }
    } else if (message.startsWith('4105') && message.length >= 6) {
      // Temperatura refrigerante (0105)
      try {
        double tempValue = int.parse(message.substring(4, 6), radix: 16) - 40;
        _onSensorDataReceived('Temp. Refrigerante', tempValue);
        setState(() => _coolantTemp = tempValue.toDouble());
        _coolantTemp = tempValue.toDouble();
        _enviarDatoAFirebaseMotor('TempRef', _coolantTemp);
      } catch (e) {
        print("Error procesando temperatura: $e");
      }
    }
    // else if (message.startsWith('413C') && message.length >= 6) {
    //   // Temperatura Catalizador B1S1 (013C)
    //   try {
    //     double tempValue = int.parse(message.substring(4, 6), radix: 16) - 40;
    //     _onSensorDataReceived('Cat. B1S1', tempValue);
    //     setState(() => _catalizadorB1S1 = tempValue);
    //     _catB1S1Notifier.value = tempValue.toDouble();
    //     _enviarDatoAFirebaseMotor('CatB1S1', _catalizadorB1S1);
    //   } catch (e) {
    //     print("Error procesando Cat. B1S1: $e");
    //   }
    // }
    // else if (message.startsWith('413D') && message.length >= 6) {
    //   // Temperatura Catalizador B2S1 (013D)
    //   try {
    //     double tempValue = int.parse(message.substring(4, 6), radix: 16) - 40;
    //     _onSensorDataReceived('Cat. B2S1', tempValue);
    //     setState(() => _catalizadorB2S1 = tempValue);
    //     _catB2S1Notifier.value = tempValue.toDouble();
    //     _enviarDatoAFirebaseMotor('CatB2S1', _catalizadorB2S1);
    //   } catch (e) {
    //     print("Error procesando Cat. B2S1: $e");
    //   }
    // }
    // else if (message.startsWith('413E') && message.length >= 6) {
    //   // Temperatura Catalizador B1S2 (013E)
    //   try {
    //     double tempValue = int.parse(message.substring(4, 6), radix: 16) - 40;
    //     _onSensorDataReceived('Cat. B1S2', tempValue);
    //     setState(() => _catalizadorB1S2 = tempValue);
    //     _catB1S2Notifier.value = tempValue.toDouble();
    //     _enviarDatoAFirebaseMotor('CatB1S2', _catalizadorB1S2);
    //   } catch (e) {
    //     print("Error procesando Cat. B1S2: $e");
    //   }
    // }
    // else if (message.startsWith('41EF') && message.length >= 6) {
    //   // Temperatura Catalizador B2S2 (01EF)
    //   try {
    //     double tempValue = int.parse(message.substring(4, 6), radix: 16) - 40;
    //     _onSensorDataReceived('Cat. B2S2', tempValue);
    //     setState(() => _catalizadorB2S2 = tempValue);
    //     _catB2S2Notifier.value = tempValue.toDouble();
    //     _enviarDatoAFirebaseMotor('CatB2S2', _catalizadorB2S2);
    //   } catch (e) {
    //     print("Error procesando Cat. B2S2: $e");
    //   }
    // }

    else if (message.startsWith('4104') && message.length >= 6) {
      // Carga del motor (0104)
      try {
        int loadValue = int.parse(message.substring(4, 6), radix: 16);
        _onSensorDataReceived('Carga del motor', loadValue.toDouble());
        setState(() => _engineLoad = (loadValue * 100 / 255).toDouble());
        _engineNotifier.value = loadValue.toDouble();
        _enviarDatoAFirebaseMotor('Carga del motor', _engineLoad);
      } catch (e) {
        print("Error procesando carga del motor: $e");
      }
    } else if (message.startsWith('410E') && message.length >= 6) {
      // Avance de encendido (010E)
      try {
        int advanceValue = int.parse(message.substring(4, 6), radix: 16) - 64;
        setState(() => _ignitionAdvance = advanceValue.toDouble());
        _ignitionNotifier.value = advanceValue.toDouble();
        _enviarDatoAFirebaseMotor('Avance encendido', _ignitionAdvance);
      } catch (e) {
        print("Error procesando avance de encendido: $e");
      }
    } else if (message.startsWith('410D') && message.length >= 6) {
      // Velocidad del vehículo (010D)
      try {
        int speedValue = int.parse(message.substring(4, 6), radix: 16);
        setState(() => _speed = speedValue.toDouble());
        _speedNotifier.value = speedValue.toDouble();
        _enviarDatoAFirebaseMotor('Velocidad', _speed);
      } catch (e) {
        print("Error procesando velocidad: $e");
      }
    } else if (message.startsWith('4110') && message.length >= 8) {
      // Flujo de aire masivo (0110)
      try {
        int mafValue = int.parse(message.substring(4, 8), radix: 16);
        setState(() => _maf = mafValue / 100.0); // Convertir a g/s
        _mafNotifier.value = mafValue.toDouble();
        _enviarDatoAFirebaseMotor('Flujo aire masivo', _maf);
      } catch (e) {
        print("Error procesando MAF: $e");
      }
    } else if (message.startsWith('410B') && message.length >= 6) {
      // Presión del colector de admisión (010B)
      try {
        int pressureValue = int.parse(message.substring(4, 6), radix: 16);
        setState(() => _intakeManifoldPressure = pressureValue.toDouble());
        _intakeMPNotifier.value = pressureValue.toDouble();
        _enviarDatoAFirebaseMotor(
            'Presión colector admisión', _intakeManifoldPressure);
      } catch (e) {
        print("Error procesando presión del colector: $e");
      }
    } else if (message.startsWith('4142') && message.length >= 6) {
      // Voltaje del motor (0142)
      try {
        double voltage = int.parse(message.substring(4, 6), radix: 16) / 10.0;
        _onSensorDataReceived('Voltaje', voltage);
        setState(() => _voltage = voltage);
        _voltageNotifier.value = voltage.toDouble();
        _enviarDatoAFirebaseMotor('Voltaje', _voltage);
      } catch (e) {
        print("Error procesando voltaje: $e");
      }
    }
    //SENSORES OXIGENO
    else if (message.startsWith('4114') && message.length >= 8) {
      // Sensor O2 1 (0114)
      try {
        double voltage = int.parse(message.substring(4, 6), radix: 16) / 200.0;
        double afr =
            int.parse(message.substring(6, 8), radix: 16) / 32768.0 * 14.7;
        _onSensorDataReceived('Sensor O2 1 (V) [0]', voltage);
        _onSensorDataReceived('Sensor O2 1 (AFR) [0]', afr);
        setState(() {
          _o2Voltage[0] = voltage;
          _o2AFR[0] = afr;
          _enviarDatoAFirebaseOxigeno("voltajeOxi1", voltage);
          _enviarDatoAFirebaseOxigeno("AFROxi1", afr);
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
        _onSensorDataReceived('Sensor O2 2 (V) [1]', voltage);
        _onSensorDataReceived('Sensor O2 2 (AFR) [1]', afr);
        setState(() {
          _o2Voltage[1] = voltage;
          _o2AFR[1] = afr;
          _enviarDatoAFirebaseOxigeno("voltajeOxi2", voltage);
          _enviarDatoAFirebaseOxigeno("AFROxi2", afr);
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
        _onSensorDataReceived('Sensor O2 3 (V) [4]', voltage);
        _onSensorDataReceived('Sensor O2 3 (AFR) [4]', afr);
        setState(() {
          _o2Voltage[2] = voltage;
          _o2AFR[2] = afr;
          _enviarDatoAFirebaseOxigeno("voltajeOxi3", voltage);
          _enviarDatoAFirebaseOxigeno("AFROxi3", afr);
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
        _onSensorDataReceived('Sensor O2 4 (V) [3]', voltage);
        _onSensorDataReceived('Sensor O2 4 (AFR) [3]', afr);
        setState(() {
          _o2Voltage[3] = voltage;
          _o2AFR[3] = afr;
          _enviarDatoAFirebaseOxigeno("voltajeOxi4", voltage);
          _enviarDatoAFirebaseOxigeno("AFROxi4", afr);
          _o2VNotifier.value = List.from(_o2Voltage);
          _o2AFRNotifier.value = List.from(_o2AFR);
        });
      } catch (e) {
        print("Error procesando sensor O2 4: $e");
      }
    } else if (message.startsWith('4124') && message.length >= 6) {
      // Relación aire-combustible comandada (0124)
      try {
        double afr =
            int.parse(message.substring(4, 6), radix: 16) / 32768.0 * 14.7;
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
        _onSensorDataReceived('Nivel de combustible', level.toDouble());
        setState(() => _fuelLevel = level.toDouble());
        _fuelLevelNotifier.value = level.toDouble();
        _enviarDatoAFirebaseCombustible("Nivel de combustible", _fuelLevel);
      } catch (e) {
        print("Error procesando nivel de combustible: $e");
      }
    } else if (message.startsWith('410A') && message.length >= 6) {
      // Presión de combustible (010A)
      try {
        int pressure = int.parse(message.substring(4, 6), radix: 16) * 3;
        _onSensorDataReceived('Presion combustible', pressure.toDouble());
        setState(() => _fuelPressure = pressure.toDouble());
        _fuelPressureNotifier.value = pressure.toDouble();
        _enviarDatoAFirebaseCombustible("Presion combustible", _fuelPressure);
      } catch (e) {
        print("Error procesando presión de combustible: $e");
      }
    } else if (message.startsWith('4122') && message.length >= 8) {
      // Presión del riel de combustible (0122)
      try {
        double pressure = int.parse(message.substring(4, 8), radix: 16) * 0.079;
        setState(() => _fuelRailPressure = pressure.toDouble());
        _fuelRailPNotifier.value = pressure.toDouble();
        _enviarDatoAFirebaseCombustible("Presion riel", _fuelPressure);
      } catch (e) {
        print("Error procesando presión del riel: $e");
      }
    } else if (message.startsWith('415E') && message.length >= 8) {
      // Tasa de consumo de combustible (015E)
      try {
        double rate = int.parse(message.substring(4, 8), radix: 16) * 0.05;
        _onSensorDataReceived('Tasa combustible', rate);
        setState(() => _fuelRate = rate);
        _fuelRateNotifier.value = rate.toDouble();
        _enviarDatoAFirebaseCombustible("Tasa combustible", _fuelRate);
      } catch (e) {
        print("Error procesando tasa de combustible: $e");
      }
    } else if (message.startsWith('4106') && message.length >= 6) {
      // Ajuste de combustible banco 1 corto plazo (0106)
      try {
        int trim = int.parse(message.substring(4, 6), radix: 16) - 128;
        setState(() => _fuelTrimBank1ShortTerm = trim.toDouble());
        _fuelTrimB1SNotifier.value = trim.toDouble();
        _enviarDatoAFirebaseCombustible(
            "Banco 1 corto", _fuelTrimBank1ShortTerm);
      } catch (e) {
        print("Error procesando ajuste banco 1 corto plazo: $e");
      }
    } else if (message.startsWith('4107') && message.length >= 6) {
      // Ajuste de combustible banco 1 largo plazo (0107)
      try {
        int trim = int.parse(message.substring(4, 6), radix: 16) - 128;
        setState(() => _fuelTrimBank1LongTerm = trim.toDouble());
        _fuelTrimB1LNotifier.value = trim.toDouble();
        _enviarDatoAFirebaseCombustible(
            "Banco 1 largo", _fuelTrimBank1LongTerm);
      } catch (e) {
        print("Error procesando ajuste banco 1 largo plazo: $e");
      }
    } else if (message.startsWith('4108') && message.length >= 6) {
      // Ajuste de combustible banco 2 corto plazo (0108)
      try {
        int trim = int.parse(message.substring(4, 6), radix: 16) - 128;
        setState(() => _fuelTrimBank2ShortTerm = trim.toDouble());
        _fuelTrimB2SNotifier.value = trim.toDouble();
        _enviarDatoAFirebaseCombustible(
            "Banco 2 corto", _fuelTrimBank2ShortTerm);
      } catch (e) {
        print("Error procesando ajuste banco 2 corto plazo: $e");
      }
    } else if (message.startsWith('4109') && message.length >= 6) {
      // Ajuste de combustible banco 2 largo plazo (0109)
      try {
        int trim = int.parse(message.substring(4, 6), radix: 16) - 128;
        setState(() => _fuelTrimBank2LongTerm = trim.toDouble());
        _fuelTrimB2LNotifier.value = trim.toDouble();
        _enviarDatoAFirebaseCombustible(
            "Banco 2 largo", _fuelTrimBank2LongTerm);
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
    if (_mockMode) return;
    //pruebas sin obd
    if (_isConnected && _connection != null) {
      command = '$command\r';
      _connection!.output.add(Uint8List.fromList(utf8.encode(command)));
    }
  }

  void _startAutoUpdate() {
    _commandTimer?.cancel();
    _commandTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (_isConnected && _connection != null) {
        _sendCommand(_obdCommands[_currentCommandIndex]);
        _currentCommandIndex = (_currentCommandIndex + 1) % _obdCommands.length;
      } else {
        timer.cancel();
      }
    });
  }

  void _showSensorDialog(
      BuildContext context, String sensorName, double initialValue) {
    final notifier = _getNotifierForSensor(sensorName);
    if (notifier == null) return;

    showDialog(
      context: context,
      builder: (_) => ValueListenableBuilder<double>(
        valueListenable: notifier,
        builder: (context, value, _) => Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFF0166B3), width: 2),
          ),
          child: DefaultTabController(
            length: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TabBar(
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blueAccent,
                  tabs: [
                    Tab(icon: Icon(Icons.speed)),
                    Tab(icon: Icon(Icons.info)),
                    Tab(icon: Icon(Icons.show_chart)),
                  ],
                ),
                SizedBox(
                  height: 500,
                  width: 350,
                  child: TabBarView(
                    children: [
                      _getGaugeWidget(sensorName, value),
                      _getSensorInfoWidget(sensorName, value),
                      _getFutureChartWidget(sensorName, notifier),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ValueNotifier<double>? _getNotifierForSensor(String sensorName) {
    switch (sensorName) {
      case 'Velocidad':
        return _speedNotifier; //'010D', // Velocidad del vehículo
      case 'RPM':
        return _rpmNotifier; // '010C', // RPM motor
      case 'Temp. Refrigerante':
        return _cooltempNotifier; //'0105', Temperatura refrigerante
      case 'Carga del motor':
        return _engineNotifier; //'0104', // Carga del motor
      case 'Avance encendido':
        return _ignitionNotifier; //'010E', // Avance de encendido
      case 'Flujo aire masivo':
        return _mafNotifier; //'0110', // Flujo de aire masivo (MAF)
      case 'Presión colector admisión':
        return _intakeMPNotifier; //'010B', // Presión del colector de admisión
      case 'Voltaje':
        return _voltageNotifier;
      case 'AFR Comandado':
        return _commandedAFRNotifier; //'0124', // Relación aire-combustible comandada
      // case 'Sensores O2 Activos': return _o2SPNotifier.to;
      case 'Sensor O2 1 (V) [0]':
        return ValueNotifier(
            _o2VNotifier.value[0]); //'0114', // Sensor O2 1 - Voltaje y AFR
      case 'Sensor O2 1 (AFR) [0]':
        return ValueNotifier(_o2AFRNotifier.value[0]);
      case 'Sensor O2 2 (V) [1]':
        return ValueNotifier(
            _o2VNotifier.value[1]); //'0115', // Sensor O2 2 - Voltaje y AFR
      case 'Sensor O2 2 (AFR) [1]':
        return ValueNotifier(_o2AFRNotifier.value[1]);
      case 'Sensor O2 3 (V) [2]':
        return ValueNotifier(
            _o2VNotifier.value[2]); //'0116', // Sensor O2 3 - Voltaje y AFR
      case 'Sensor O2 3 (AFR) [2]':
        return ValueNotifier(_o2AFRNotifier.value[2]);
      case 'Sensor O2 4 (V) [3]':
        return ValueNotifier(
            _o2VNotifier.value[3]); //'0117', // Sensor O2 4 - Voltaje y AFR
      case 'Sensor O2 4 (AFR) [3]':
        return ValueNotifier(_o2AFRNotifier.value[3]);
      case 'Nivel Combustible':
        return _fuelLevelNotifier; //'012F', // Nivel de combustible
      case 'Presión Combustible':
        return _fuelPressureNotifier; //'010A', // Presión de combustible
      case 'Presión Riel':
        return _fuelRailPNotifier; //'0122', // Presión del riel de combustible
      case 'Consumo':
        return _fuelRateNotifier; //'015E', // Tasa de consumo de combustible
      case 'Banco 1 Corto':
        return _fuelTrimB1SNotifier; //'0106', // Ajuste de combustible banco 1 corto plazo
      case 'Banco 1 Largo':
        return _fuelTrimB1LNotifier; //'0107', // Ajuste de combustible banco 1 largo plazo
      case 'Banco 2 Corto':
        return _fuelTrimB2SNotifier; //'0108', // Ajuste de combustible banco 2 corto plazo
      case 'Banco 2 Largo':
        return _fuelTrimB2LNotifier; //'0109', // Ajuste de combustible banco 2 largo plazo
      // case 'CatB1S1':
      //   return _catB1S1Notifier;
      // case 'CatB1S2':
      //   return _catB1S2Notifier;
      // case 'CatB2S1':
      //   return _catB2S1Notifier;
      // case 'CatB2S2':
      //   return _catB2S2Notifier;
      default:
        return null;

      //'0134', // Sensores de oxígeno presentes
    }
  }

  // Widget _buildGaugeBySensor(String sensorName, double value) {
  //   final gaugeWidget = _getGaugeWidget(sensorName, value);
  //   final infoWidget = _getSensorInfoWidget(sensorName, value);
  //   final chartWidget = _getFutureChartWidget();

  //   return Dialog(
  //     backgroundColor: Colors.black.withOpacity(0.9),
  //     insetPadding: const EdgeInsets.all(20),
  //     shape: RoundedRectangleBorder(
  //       side: BorderSide(color: primaryColor, width: 2),
  //     ),
  //     child: DefaultTabController(
  //       length: 3,
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const TabBar(
  //             labelColor: Colors.white,
  //             unselectedLabelColor: Colors.grey,
  //             indicatorColor: Colors.blueAccent,
  //             tabs: [
  //               Tab(icon: Icon(Icons.speed), text: 'Dashboard'),
  //               Tab(icon: Icon(Icons.info_outline), text: 'Info'),
  //               Tab(icon: Icon(Icons.show_chart), text: 'Gráfico'),
  //             ],
  //           ),
  //           SizedBox(
  //             height: 500,
  //             width: 350,
  //             child: TabBarView(
  //               children: [
  //                 gaugeWidget,
  //                 infoWidget,
  //                 chartWidget,
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildBatteryDetail(String label, String value,
      {bool big = false, String unit = 'V'}) {
    final isValid = double.tryParse(value) != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(0.8),
            fontSize: 16,
          ),
        ),
        Text(
          isValid ? "$value $unit" : "--",
          style: TextStyle(
            fontSize: big ? 70 : 25,
            fontWeight: FontWeight.bold,
            color: isValid ? Colors.black : Colors.red,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTempDetail(String label, String sensorKey, {bool big = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(0.8),
            fontSize: 16,
          ),
        ),
        Text(
          sensorHistory[sensorKey]?.isNotEmpty == true
              ? "${sensorHistory[sensorKey]!.last.toStringAsFixed(1)} °C"
              : "0.0 °C",
          style: TextStyle(
            fontSize: big ? 70 : 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 15),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Método para construir filas de información del VIN
  Widget _buildVinInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  // Método para chips de características
  Widget _buildFeatureChip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Chip(
        backgroundColor: Colors.blueGrey[600],
        label: Text(text, style: const TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _getGaugeWidget(String sensorName, double value) {
    switch (sensorName) {
      case 'Velocidad':
        return SpeedometerPage.speedometer(value: value);
      case 'RPM':
        return SpeedometerPage.rpm(value: value);
      case 'Temp. Refrigerante':
        return SpeedometerPage.tempR(value: value);
      case 'Carga del motor':
        return SpeedometerPage.cargaMotor(value: value);
      case 'Avance encendido':
        return SpeedometerPage.avanceEncentido(value: value);
      case 'Flujo aire masivo':
        return SpeedometerPage.flujoAir(value: value);
      case 'Presión colector admisión':
        return SpeedometerPage.presionCA(value: value);
      case 'Voltaje':
        return SpeedometerPage.voltaje(value: value);
      case 'AFR Comandado':
        return SpeedometerPage.sensorO21V(value: value);
      case 'Sensor O2 1 (V) [0]':
        return SpeedometerPage.sensorO21AFR(value: value);
      case 'Sensor O2 1 (AFR) [0]':
        return SpeedometerPage.sensorO22V(value: value);
      case 'Sensor O2 2 (V) [1]':
        return SpeedometerPage.sensorO22AFR(value: value);
      case 'Sensor O2 2 (AFR) [1]':
        return SpeedometerPage.sensorO23V(value: value);
      case 'Sensor O2 3 (V) [2]':
        return SpeedometerPage.sensorO23AFR(value: value);
      case 'Sensor O2 3 (AFR) [2]':
        return SpeedometerPage.sensorO24V(value: value);
      case 'Sensor O2 4 (V) [3]':
        return SpeedometerPage.sensorO24AFR(value: value);
      case 'Sensor O2 4 (AFR) [3]':
        return SpeedometerPage.afrC(value: value);
      case 'Nivel Combustible':
        return SpeedometerPage.nivelC(value: value);
      case 'Presión Combustible':
        return SpeedometerPage.presionC(value: value);
      case 'Presión Riel':
        return SpeedometerPage.presionR(value: value);
      case 'Consumo':
        return SpeedometerPage.consumo(value: value);
      case 'Banco 1 Corto':
        return SpeedometerPage.banco1C(value: value);
      case 'Banco 1 Largo':
        return SpeedometerPage.banco1L(value: value);
      case 'Banco 2 Corto':
        return SpeedometerPage.banco2C(value: value);
      case 'Banco 2 Largo':
        return SpeedometerPage.banco2L(value: value);
      // case 'CatB1S1':
      //   return SpeedometerPage.catB1S1(value: value);
      // case 'CatB1S2':
      //   return SpeedometerPage.catB1S2(value: value);
      // case 'CatB2S1':
      //   return SpeedometerPage.catB2S1(value: value);
      // case 'CatB2S2':
      //   return SpeedometerPage.catB2S2(value: value);
      default:
        return const Center(
            child: Text('Gauge no disponible',
                style: TextStyle(color: Colors.white)));
    }
  }

  Widget _getSensorInfoWidget(String sensorName, double value) {
    String descripcion =
        sensorDescriptions[sensorName] ?? 'Sin descripción disponible.';
    String minMax = sensorMinMax[sensorName] ?? 'Sin rangos disponibles.';
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nombre',
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text('$sensorName',
              style: const TextStyle(color: Colors.black, fontSize: 18)),
          const SizedBox(height: 8),
          Text('Valor actual',
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text('${value.toStringAsFixed(1)}',
              style: const TextStyle(color: Colors.black, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Descripción',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text(
            '$descripcion',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          const Text('Rango promedio',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text(
            '$minMax',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _getFutureChartWidget(
      String sensorName, ValueNotifier<double> notifier) {
    // return SensorLineChart(
    //   sensorName: "Velocidad",
    //   notifier: _speedNotifier,
    //   minMax: sensorMinMaxChart[sensorName] ?? '0 - 240',
    // );
    switch (sensorName) {
      case 'Velocidad':
        return SensorLineChart(
          sensorName: "Velocidad",
          notifier: _speedNotifier,
          minMax: '0 - 240',
        );
      case 'RPM':
        return SensorLineChart(
          sensorName: "RPM",
          notifier: _rpmNotifier,
          minMax: '0 - 8000',
        );
      case 'Temp. Refrigerante':
        return SensorLineChart(
          sensorName: "Temp. Refrigerante",
          notifier: _cooltempNotifier,
          minMax: '0 - 150',
        );
      case 'Carga del motor':
        return SensorLineChart(
          sensorName: "Carga del motor",
          notifier: _engineNotifier,
          minMax: '0 - 100',
        );
      case 'Avance encendido':
        return SensorLineChart(
          sensorName: "Avance encendido",
          notifier: _ignitionNotifier,
          minMax: '-10 - 40',
        );
      case 'Flujo aire masivo':
        return SensorLineChart(
          sensorName: "Flujo aire masivo",
          notifier: _mafNotifier,
          minMax: '0 - 20',
        );
      case 'Presión colector admisión':
        return SensorLineChart(
          sensorName: "Presión colector admisión",
          notifier: _intakeMPNotifier,
          minMax: '0 - 100',
        );
      case 'Voltaje':
        return SensorLineChart(
          sensorName: "Voltaje",
          notifier: _voltageNotifier,
          minMax: '0 - 15',
        );
      case 'AFR Comandado':
        return SensorLineChart(
          sensorName: "AFR Comandado",
          notifier: _commandedAFRNotifier,
          minMax: '0 - 20',
        );
      case 'Sensor O2 1 (V) [0]':
        return SensorLineChart(
          sensorName: "Sensor O2 1 (V) [0]",
          notifier: ValueNotifier(_o2VNotifier.value[0]),
          minMax: '0.1 - 0.9',
        );
      case 'Sensor O2 1 (AFR) [0]':
        return SensorLineChart(
          sensorName: "Sensor O2 1 (AFR) [0]",
          notifier: ValueNotifier(_o2AFRNotifier.value[0]),
          minMax: '0 - 16',
        );
      case 'Sensor O2 2 (V) [1]':
        return SensorLineChart(
          sensorName: "Sensor O2 2 (V) [1]",
          notifier: ValueNotifier(_o2VNotifier.value[1]),
          minMax: '0.1 - 0.9',
        );
      case 'Sensor O2 2 (AFR) [1]':
        return SensorLineChart(
          sensorName: "Sensor O2 2 (AFR) [1]",
          notifier: ValueNotifier(_o2AFRNotifier.value[1]),
          minMax: '0 - 16',
        );
      case 'Sensor O2 3 (V) [2]':
        return SensorLineChart(
          sensorName: "Sensor O2 3 (V) [2]",
          notifier: ValueNotifier(_o2VNotifier.value[2]),
          minMax: '0.1 - 0.9',
        );
      case 'Sensor O2 3 (AFR) [2]':
        return SensorLineChart(
          sensorName: "Sensor O2 3 (AFR) [2]",
          notifier: ValueNotifier(_o2AFRNotifier.value[2]),
          minMax: '0 - 16',
        );
      case 'Sensor O2 4 (V) [3]':
        return SensorLineChart(
          sensorName: "Sensor O2 4 (V) [3]",
          notifier: ValueNotifier(_o2VNotifier.value[3]),
          minMax: '0.1 - 0.9',
        );
      case 'Sensor O2 4 (AFR) [3]':
        return SensorLineChart(
          sensorName: "Sensor O2 4 (AFR) [3]",
          notifier: ValueNotifier(_o2AFRNotifier.value[3]),
          minMax: '0 - 20',
        );
      case 'Nivel Combustible':
        return SensorLineChart(
          sensorName: "Nivel Combustible",
          notifier: _fuelLevelNotifier,
          minMax: '0 - 100',
        );
      case 'Presión Combustible':
        return SensorLineChart(
          sensorName: "Presión Combustible",
          notifier: _fuelPressureNotifier,
          minMax: '0 - 400',
        );
      case 'Presión Riel':
        return SensorLineChart(
          sensorName: "Presión Riel",
          notifier: _fuelRailPNotifier,
          minMax: '0 - 2000',
        );
      case 'Consumo':
        return SensorLineChart(
          sensorName: "Consumo",
          notifier: _fuelRateNotifier,
          minMax: '1 - 20',
        );
      case 'Banco 1 Corto':
        return SensorLineChart(
          sensorName: "Banco 1 Corto",
          notifier: _fuelTrimB1SNotifier,
          minMax: '-10 - 10',
        );
      case 'Banco 1 Largo':
        return SensorLineChart(
          sensorName: "Banco 1 Largo",
          notifier: _fuelTrimB1LNotifier,
          minMax: '-10 - 10',
        );
      case 'Banco 2 Corto':
        return SensorLineChart(
          sensorName: "Banco 2 Corto",
          notifier: _fuelTrimB2SNotifier,
          minMax: '-10 - 10',
        );
      case 'Banco 2 Largo':
        return SensorLineChart(
          sensorName: "Banco 1 Largo",
          notifier: _fuelTrimB2LNotifier,
          minMax: '-10 - 10',
        );
      // case 'CatB1S1':
      //   return SensorLineChart(
      //     sensorName: "CatB1S1",
      //     notifier: _catB1S1Notifier,
      //     minMax: '300 - 950',
      //   );
      // case 'CatB1S2':
      //   return SensorLineChart(
      //     sensorName: "CatB1S2",
      //     notifier: _catB1S2Notifier,
      //     minMax: '200 - 650',
      //   );
      // case 'CatB2S1':
      //   return SensorLineChart(
      //     sensorName: "CatB2S1",
      //     notifier: _catB2S1Notifier,
      //     minMax: '300 - 950',
      //   );
      // case 'CatB2S2':
      //   return SensorLineChart(
      //     sensorName: "CatB2S2",
      //     notifier: _catB2S2Notifier,
      //     minMax: '200 - 650',
      //   );
      default:
        return const Center(
            child: Text('Grafica no disponible',
                style: TextStyle(color: Colors.white)));
    }
  }

  // final Map<String, String> sensorMinMaxChart = {
  //   'Velocidad': '0 - 240',
  //   'RPM': '0 - 8000',
  //   'Temp. Refrigerante': '0 - 150',
  //   'Carga del motor': '0 - 100',
  //   'Avance encendido': '-10 - 40',
  //   'Flujo aire masivo': '0 - 20',
  //   'Presión colector admisión': '0 - 100',
  //   'Voltaje': '0 - 15',
  //   'Sensor O2 1 (V) [0]': '0.1 - 0.9',
  //   'Sensor O2 1 (AFR) [0]': '0 - 16',
  //   'Sensor O2 2 (V) [1]': '0.1 - 0.9',
  //   'Sensor O2 2 (AFR) [1]': '0 - 16',
  //   'Sensor O2 3 (V) [2]': '0.1 - 0.9',
  //   'Sensor O2 3 (AFR) [2]': '016',
  //   'Sensor O2 4 (V) [3]': '0.1 - 0.9',
  //   'Sensor O2 4 (AFR) [3]': '0 - 16',
  //   'AFR Comandado': '0 - 20',
  //   'Nivel Combustible': '0 - 100',
  //   'Presión Combustible': '0 - 400',
  //   'Presión Riel': '0 - 2000',
  //   'Consumo': '1 - 20',
  //   'Banco 1 Corto': '-10 - 10',
  //   'Banco 1 Largo': '-10 - 10',
  //   'Banco 2 Corto': '-10 - 10',
  //   'Banco 2 Largo': '-10 - 10',
  // };

  final Map<String, String> sensorDescriptions = {
    'Velocidad': 'Mide la velocidad del vehículo.',
    'RPM':
        'Detecta las revoluciones por minuto del motor. Indica qué tan rápido está girando el motor.',
    'Temp. Refrigerante':
        'Mide la temperatura del refrigerante del motor. Es crucial para evitar sobrecalentamientos.',
    'Carga del motor': 'Mide cuánta carga (demanda) está soportando el motor.',
    'Avance encendido':
        'Indica cuántos grados antes del punto muerto superior se produce la chispa de encendido.',
    'Flujo aire masivo':
        'Mide la masa de aire que entra al motor. Es esencial para calcular la cantidad de combustible a inyectar.',
    'Presión colector admisión':
        'Detecta la presión en el múltiple de admisión. Útil para calcular la carga del motor.',
    'Voltaje':
        'El voltaje automotriz es la cantidad de electricidad que fluye a través de un vehículo. Es una de las partes más importantes del sistema eléctrico de un automóvil, ya que es responsable de proporcionar energía a todos los componentes eléctricos y electrónicos del vehículo',
    'Sensor O2 1 (V) [0]':
        'Mide la cantidad de oxígeno en los gases de escape antes del catalizador (banco 1, sensor 1).',
    'Sensor O2 1 (AFR) [0]':
        'Air-Fuel Ratio (AFR) o relación aire/combustible estimada del sensor 1.',
    'Sensor O2 2 (V) [1]':
        'Sensor después del catalizador (banco 1, sensor 2), verifica la eficiencia del mismo.',
    'Sensor O2 2 (AFR) [1]':
        'AFR medida después del catalizador (menos variable que la del sensor 1).',
    'Sensor O2 3 (V) [2]':
        'Sensor adicional en banco 2 (si existe motor en V o configuración dual).',
    'Sensor O2 3 (AFR) [2]': 'AFR para banco 2, sensor 1.',
    'Sensor O2 4 (V) [3]': 'Posiblemente el postcatalizador del banco 2.',
    'Sensor O2 4 (AFR) [3]': 'AFR para banco 2, sensor 2.',
    'AFR Comandado':
        'La relación aire-combustible (AFR) es la relación de masa entre la cantidad de aire y la cantidad de combustible mezclado en la cámara de combustión de un vehículo',
    'Nivel Combustible':
        'Muestra el porcentaje de combustible restante en el tanque.',
    'Presión Combustible':
        'Indica la presión del combustible antes de inyectarse.',
    'Presión Riel':
        'Presión en el riel de combustible (common rail). Crítica en inyección directa.',
    'Consumo': 'Cantidad de combustible inyectado por segundo o ciclo.',
    'Banco 1 Corto':
        'Ajuste de corto plazo al AFR del banco 1 (adaptación inmediata).',
    'Banco 1 Largo': 'Ajuste de largo plazo al AFR del banco 1 (aprendizaje).',
    'Banco 2 Corto': 'Ajuste de corto plazo al AFR del banco 2.',
    'Banco 2 Largo': 'Ajuste de largo plazo al AFR del banco 2.',
    // 'CatB1S1': 'Mide la temperatura de los gases de escape antes de entrar al núcleo catalítico. Valores altos (>850°C) indican riesgo de fusión del catalizador.',
    // 'CatB1S2': 'Monitorea la temperatura después de la reacción catalítica. Una diferencia <50°C entre B1S1 y B1S2 sugiere catalizador ineficiente.',
    // 'CatB2S1': 'Equivalente al B1S1 pero para el segundo banco. Usado en motores con doble escape para cumplir normas EURO/USD.',
    // 'CatB2S2': 'Compara la eficiencia entre bancos. En motores balanceados, B1S2 y B2S2 deben tener lecturas similares (±30°C).',
  };
  final Map<String, String> sensorMinMax = {
    'Velocidad': '0 - 240 km/h (depende del vehículo)',
    'RPM': '600 - 7000 rpm',
    'Temp. Refrigerante': '70°C - 105°C',
    'Carga del motor': '0% - 100%',
    'Avance encendido': '-10° - 100° (en grados de avance)',
    'Flujo aire masivo': '2 - 20 g/s (ralentí a aceleración moderada)',
    'Presión colector admisión': '20 - 100 kPa',
    'Voltaje': '12.5V - 12.9V',
    'Sensor O2 1 (V) [0]': '0.1 - 0.9 V',
    'Sensor O2 1 (AFR) [0]':
        '14.7:1 (estequiométrica), típicamente entre 12 - 16:1',
    'Sensor O2 2 (V) [1]': '0.1 - 0.9 V',
    'Sensor O2 2 (AFR) [1]': '14.5 - 15.0:1',
    'Sensor O2 3 (V) [2]': '0.1 - 0.9 V',
    'Sensor O2 3 (AFR) [2]': '12 - 16:1',
    'Sensor O2 4 (V) [3]': '0.1 - 0.9 V',
    'Sensor O2 4 (AFR) [3]': '14.5 - 15.0:1',
    'AFR Comandado': '20:1',
    'Nivel Combustible': '0% - 100%',
    'Presión Combustible': '250 - 400 kPa',
    'Presión Riel': '500 - 1500 kPa o más',
    'Consumo': '1 - 20 mg/combustión (varía mucho)',
    'Banco 1 Corto': '-10% a +10%',
    'Banco 1 Largo': '-10% a +10%',
    'Banco 2 Corto': '-10% a +10%',
    'Banco 2 Largo': '-10% a +10%',
    // 'CatB1S1': '500°C - 800°C',
    // 'CatB1S2': '300°C - 500°C',
    // 'CatB2S1': '500°C - 800°C',
    // 'CatB2S2': '300°C - 500°C',
  };

  Map<String, dynamic> _getSensorConfig(String title) {
    switch (title) {
      case 'Velocidad':
        return {'unit': 'km/h', 'maxValue': 240.0};
      case 'RPM':
        return {'unit': 'RPM', 'maxValue': 8000.0};
      case 'Temp. Refrigerante':
        return {'unit': '°C', 'maxValue': 150.0};
      case 'Carga del motor':
        return {'unit': '%', 'maxValue': 100.0};
      case 'Avance encendido':
        return {'unit': '°', 'maxValue': 40.0};
      case 'Flujo aire masivo':
        return {'unit': 'g/s', 'maxValue': 20.0};
      case 'Presión colector admisión':
        return {'unit': 'kPa', 'maxValue': 100.0};
      case 'Voltaje':
        return {'unit': 'V', 'maxValue': 16};

      case 'Sensor O2 1 (V) [0]':
        return {'unit': 'Volts%', 'maxValue': 1};
      case 'Sensor O2 1 (AFR) [0]':
        return {'unit': 'Volts%', 'maxValue': 16};
      case 'Sensor O2 2 (V) [1]':
        return {'unit': 'Volts%', 'maxValue': 1};
      case 'Sensor O2 2 (AFR) [1]':
        return {'unit': 'Volts%', 'maxValue': 15};
      case 'Sensor O2 3 (V) [2]':
        return {'unit': 'Volts%', 'maxValue': 1};
      case 'Sensor O2 3 (AFR) [2]':
        return {'unit': 'Volts%', 'maxValue': 16};
      case 'Sensor O2 4 (V) [3]':
        return {'unit': 'Volts%', 'maxValue': 1};
      case 'Sensor O2 4 (AFR) [3]':
        return {'unit': 'Volts%', 'maxValue': 15};

      case 'AFR Comandado':
        return {'unit': 'AFR', 'maxValue': 16};
      // case 'Sensores O2 Activos':
      //   return {'unit': '', 'maxValue': 150.0};
      case 'Nivel Combustible':
        return {'unit': '%', 'maxValue': 100.0};
      case 'Presión Combustible':
        return {'unit': 'kPa', 'maxValue': 400.0};
      case 'Presión Riel':
        return {'unit': 'kPa', 'maxValue': 2000.0};
      case 'Consumo':
        return {'unit': 'L/h', 'maxValue': 40.0};
      case 'Banco 1 Corto':
        return {'unit': '%', 'maxValue': 10.0};
      case 'Banco 1 Largo':
        return {'unit': '%', 'maxValue': 10.0};
      case 'Banco 2 Corto':
        return {'unit': '%', 'maxValue': 10.0};
      case 'Banco 2 Largo':
        return {'unit': '%', 'maxValue': 10.0};
      // case 'CatB1S1':
      //   return {'unit': '°C', 'maxValue': 950.0};
      // case 'CatB1S2':
      //   return {'unit': '°C', 'maxValue': 650.0};
      // case 'CatB2S1':
      //   return {'unit': '°C', 'maxValue': 950.0};
      // case 'CatB2S2':
      //   return {'unit': '°C', 'maxValue': 650.0};
      default:
        return {'unit': '%', 'maxValue': 100.0};
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
    if (_mockMode) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Modo Simulación'),
          content: Text('Usando datos de prueba'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
      return;
    }
    //pruebas sin obd
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dispositivos Bluetooth'),
          content: _connection != null && _connection!.isConnected
              ? SingleChildScrollView(
                  // Agregado
                  child: Column(
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
                  ),
                )
              : SingleChildScrollView(
                  // Agregado
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _devicesList.map((device) {
                      return ListTile(
                        title: Text(device.name ?? "Sin nombre"),
                        subtitle: Text(device.address),
                        onTap: () async {
                          try {
                            BluetoothConnection connection =
                                await BluetoothConnection.toAddress(
                                    device.address);
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
      {
        'nombre': 'Voltaje',
        'valor': _voltage,
        'unidad': 'V',
      },
      {
        'nombre': 'Sensor O2 1 (V) [0]',
        'valor': _o2Voltage[0],
        'unidad': 'V',
      },
      {
        'nombre': 'Sensor O2 1 (AFR) [0]',
        'valor': _o2AFR[0],
        'unidad': 'AFR',
      },
      {
        'nombre': 'Sensor O2 2 (V) [1]',
        'valor': _o2Voltage[1],
        'unidad': 'V',
      },
      {
        'nombre': 'Sensor O2 2 (AFR) [1]',
        'valor': _o2AFR[1],
        'unidad': 'AFR',
      },
      {
        'nombre': 'Sensor O2 3 (V) [2]',
        'valor': _o2Voltage[2],
        'unidad': 'V',
      },
      {
        'nombre': 'Sensor O2 3 (AFR) [2]',
        'valor': _o2AFR[2],
        'unidad': 'AFR',
      },
      {
        'nombre': 'Sensor O2 4 (V) [3]',
        'valor': _o2Voltage[3],
        'unidad': 'V',
      },
      {
        'nombre': 'Sensor O2 4 (AFR) [3]',
        'valor': _o2AFR[3],
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
      // {
      //   'nombre': 'CatB1S1',
      //   'valor': _catalizadorB1S1,
      //   'unidad': '°C',
      // },
      // {
      //   'nombre': 'CatB1S2',
      //   'valor': _catalizadorB1S2,
      //   'unidad': '°C',
      // },
      // {
      //   'nombre': 'CatB2S1',
      //   'valor': _catalizadorB2S1,
      //   'unidad': '°C',
      // },
      // {
      //   'nombre': 'CatB2S2',
      //   'valor': _catalizadorB2S2,
      //   'unidad': '°C',
      // },
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
      case 'Voltaje':
        _showVoltajeDialog(context, _voltage);
      // case 'Sensores O2 Activos':
      //   _showO2SensorsDialog(context); ///
      case 'Sensor O2 1 (V) [0]':
        _showO2VoltageO21Dialog(context, _o2Voltage);
      case 'Sensor O2 1 (AFR) [0]':
        _showO2AFR021Dialog(context, _o2AFR);
      case 'Sensor O2 2 (V) [1]':
        _showO2VoltageO22Dialog(context, _o2Voltage);
      case 'Sensor O2 2 (AFR) [1]':
        _showO2AFR022Dialog(context, _o2AFR);
      case 'Sensor O2 3 (V) [2]':
        _showO2VoltageO23Dialog(context, _o2Voltage);
      case 'Sensor O2 3 (AFR) [2]':
        _showO2AFR023Dialog(context, _o2AFR);
      case 'Sensor O2 4 (V) [3]':
        _showO2VoltageO24Dialog(context, _o2Voltage);
      case 'Sensor O2 4 (AFR) [3]':
        _showO2AFR024Dialog(context, _o2AFR);

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
        // case 'CatB1S1':
        //   _showCatB1S1Dialog(context, _catalizadorB1S1);
        // case 'CatB1S2':
        //   _showCatB1S2Dialog(context, _catalizadorB1S2);
        // case 'CatB2S1':
        //   _showCatB2S1Dialog(context, _catalizadorB2S1);
        // case 'CatB2S2':
        //   _showCatB2S2Dialog(context, _catalizadorB2S2);
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

  void _showignitionAdvanceDialog(
      BuildContext context, double ignitionAdvance) {
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

  void _showintakeMPialog(
      BuildContext context, double _intakeManifoldPressure) {
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

  void _showVoltajeDialog(BuildContext context, double _voltage) {
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
          title: 'Voltaje',
          value: _voltage.toString(),
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

  void _showO2VoltageO21Dialog(BuildContext context, List _o2Voltage) {
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
          title: 'Sensor O2 1 (V) [0]',
          value: _o2Voltage[0].toString(),
        ),
      ),
    );
  }

  void _showO2VoltageO22Dialog(BuildContext context, List _o2Voltage) {
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
          title: 'Sensor O2 2 (V) [1]',
          value: _o2Voltage[1].toString(),
        ),
      ),
    );
  }

  void _showO2VoltageO23Dialog(BuildContext context, List _o2Voltage) {
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
          title: 'Sensor O2 3 (V) [2]',
          value: _o2Voltage[2].toString(),
        ),
      ),
    );
  }

  void _showO2VoltageO24Dialog(BuildContext context, List _o2Voltage) {
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
          title: 'Sensor O2 4 (V) [3]',
          value: _o2Voltage[3].toString(),
        ),
      ),
    );
  }

  void _showO2AFR021Dialog(BuildContext context, List _o2AFR) {
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
          title: 'Sensor O2 1 (AFR) [0]',
          value: _o2AFR[0].toString(),
        ),
      ),
    );
  }

  void _showO2AFR022Dialog(BuildContext context, List _o2AFR) {
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
          title: 'Sensor O2 2 (AFR) [1]',
          value: _o2AFR[1].toString(),
        ),
      ),
    );
  }

  void _showO2AFR023Dialog(BuildContext context, List _o2AFR) {
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
          title: 'Sensor O2 3 (AFR) [2]',
          value: _o2AFR[2].toString(),
        ),
      ),
    );
  }

  void _showO2AFR024Dialog(BuildContext context, List _o2AFR) {
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
          title: 'Sensor O2 4 (AFR) [3]',
          value: _o2AFR[3].toString(),
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

  void _showfuelB1SDialog(
      BuildContext context, double _fuelTrimBank1ShortTerm) {
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

  void _showfuelB2SDialog(
      BuildContext context, double _fuelTrimBank2ShortTerm) {
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
      barrierColor: const Color.fromARGB(137, 255, 255, 255),
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

  void _showCatB1S1Dialog(BuildContext context, double _catalizadorB1S1) {
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
          title: 'CatB1S1',
          value: _catalizadorB1S1.toString(),
        ),
      ),
    );
  }

  void _showCatB1S2Dialog(BuildContext context, double _catalizadorB1S2) {
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
          title: 'CatB1S2',
          value: _catalizadorB1S2.toString(),
        ),
      ),
    );
  }

  void _showCatB2S1Dialog(BuildContext context, double _catalizadorB2S1) {
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
          title: 'CatB2S1',
          value: _catalizadorB2S1.toString(),
        ),
      ),
    );
  }

  void _showCatB2S2Dialog(BuildContext context, double _catalizadorB2S2) {
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
          title: 'CatB2S2',
          value: _catalizadorB2S2.toString(),
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
              icon: const Icon(Icons.document_scanner),
              onPressed: () async {
                await generarYGuardarPDF(); // Nueva función
              },
              tooltip: "Generar PDF",
            ),
            IconButton(
              icon: const Icon(Icons.bluetooth),
              onPressed: () => _showDeviceList(context),
              tooltip: "Conectar Bluetooth",
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "Cerrar Sesión",
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: ButtomNavBar(
            selectedButtom: homeController.selectedButtom,
            onTap: (index) {
              if (homeController.selectedButtom != index) {
                // Animaciones al cambiar de pestaña
                if (homeController.selectedButtom == 1) {
                  batteryAnimatedController.reverse(from: 0.2);
                } else if (index == 1) {
                  batteryAnimatedController.forward();
                }

                if (homeController.selectedButtom == 2) {
                  tempratureAnimationController.reverse(from: 0.2);
                } else if (index == 2) {
                  tempratureAnimationController.forward();
                }

                if (homeController.selectedButtom == 3) {
                  tyresAnimationController.reverse();
                } else if (index == 3) {
                  tyresAnimationController.forward();
                }

                homeController.showTyresController(index);
                homeController.tyresStatusController(index);
                homeController.selectedButtonsNavBarChange(index);
              } else {
                // Opcional: manejar doble toque en el mismo botón
                // por ejemplo, reiniciar la animación o recargar datos
                if (index == 3) {
                  tyresAnimationController.forward(from: 0.0);
                  // puedes forzar un setState o emitir un evento si necesitas que algo se recargue
                }
              }
            }),
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
                      "assets/icons/Car.svg",
                      width: double.infinity,
                    ),
                  ),
                ),

                if (homeController.selectedButtom == 0) ...[
                  Positioned.fill(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Image.asset(
                              //   'assets/gifs/autazo.gif',
                              //   height: 180,
                              //   fit: BoxFit.contain,
                              // ),
                              // const SizedBox(height: 30),
                              Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(
                                      color: Colors.blueAccent, width: 1),
                                ),
                                color: Colors.black.withOpacity(0.3),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Diagnostico OBDII',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 15),
                                      _buildInfoRow(Icons.speed,
                                          'Monitoreo en Tiempo Real'),
                                      _buildInfoRow(Icons.graphic_eq,
                                          'Análisis Profesional'),
                                      _buildInfoRow(
                                          Icons.security, 'Sistema Seguro'),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                /// Battery screen start here
                ///
                // Opacity(
                //   opacity: batteryAnimation.value,
                //   child: SvgPicture.asset(
                //     "assets/icons/Battery.svg",
                //     width: constraints.maxWidth * 0.46,
                //   ),
                // ),

                // Positioned(
                //   top: 50 * (1 - batteryStatusAnimation.value),
                //   height: constraints.maxHeight,
                //   width: constraints.maxWidth,
                //   child: Opacity(
                //     opacity: batteryStatusAnimation.value,
                //     child: Padding(
                //       padding: const EdgeInsets.symmetric(horizontal: 32.0),
                //       child: Align(
                //         alignment: Alignment.centerRight,
                //         child: BatteryStatus(
                //           constraints: constraints,
                //           voltage: sensorHistory['Voltaje']?.isNotEmpty == true
                //               ? sensorHistory['Voltaje']!.last.toStringAsFixed(2)
                //               : '...',
                //           oxygenValues: {
                //             for (var key in sensorHistory.keys)
                //               if (key.startsWith('Sensor O2'))
                //                 key: sensorHistory[key]!.isNotEmpty
                //                     ? sensorHistory[key]!.last.toStringAsFixed(2)
                //                     : '...',
                //           },
                //         ),
                //       ),
                //     ),
                //   ),
                // ),

                /// Battery Screen start here
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
                        child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: SingleChildScrollView(
                            // <-- Widget clave
                            child: Column(
                              mainAxisSize: MainAxisSize.min, // <-- Importante
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildBatteryDetail(
                                  'Voltaje',
                                  sensorHistory['Voltaje']?.isNotEmpty == true
                                      ? sensorHistory['Voltaje']!
                                          .last
                                          .toStringAsFixed(2)
                                      : '0.00',
                                  big: true,
                                ),
                                const SizedBox(height: 20),
                                for (int i = 0; i < 4; i++) ...[
                                  _buildBatteryDetail(
                                    'Sensor O2 ${i + 1} (V)',
                                    sensorHistory['Sensor O2 ${i + 1} (V)']
                                                ?.isNotEmpty ==
                                            true
                                        ? sensorHistory[
                                                'Sensor O2 ${i + 1} (V)']!
                                            .last
                                            .toStringAsFixed(2)
                                        : '0.00',
                                    unit: 'V',
                                    big: false,
                                  ),
                                  _buildBatteryDetail(
                                    'Sensor O2 ${i + 1} (AFR)',
                                    sensorHistory['Sensor O2 ${i + 1} (AFR)']
                                                ?.isNotEmpty ==
                                            true
                                        ? sensorHistory[
                                                'Sensor O2 ${i + 1} (AFR)']!
                                            .last
                                            .toStringAsFixed(2)
                                        : '0.00',
                                    unit: 'AFR',
                                    big: false,
                                  ),
                                  if (i < 3)
                                    const SizedBox(
                                        height: 10), // Espaciado entre sensores
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                /// Battery Screen end here

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
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTempDetail(
                              'Temperatura Refrigerante',
                              'Temp. Refrigerante',
                              big: true,
                            ),
                            _buildTempDetail(
                              'Carga del motor',
                              'Carga del motor',
                              big: false,
                            ),
                            _buildTempDetail(
                              'Nivel Combustible',
                              'Nivel Combustible',
                              big: false,
                            ),
                            _buildTempDetail(
                              'Presión Combustible',
                              'Presión Combustible',
                              big: false,
                            ),
                            _buildTempDetail(
                              'Tasa de Consumo',
                              'Consumo',
                              big: false,
                            ),

                            // _buildTempDetail(
                            //   'Catalizador B1S1',
                            //   'CatB1S1',
                            //   big: false,
                            // ),
                            // _buildTempDetail(
                            //   'Catalizador B1S2',
                            //   'CatB1S2',
                            //   big: false,
                            // ),
                            // _buildTempDetail(
                            //   'Catalizador B2S1',
                            //   'CatB2S1',
                            //   big: false,
                            // ),
                            // _buildTempDetail(
                            //   'Catalizador B2S2',
                            //   'CatB2S2',
                            //   big: false,
                            // ),
                          ],
                        ),
                      ),
                    ),
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
                          final sensoresFiltrados = sensors
                              .where((sensor) => [
                                    "Velocidad",
                                    "RPM",
                                    "Temp. Refrigerante",
                                    "Avance encendido",
                                    "Carga del motor",
                                    "Flujo aire masivo",
                                    "Presión colector admisión",
                                    "Voltaje",
                                    // "Sensores O2 Activos", ///
                                    "Sensor O2 1 (V) [0]",
                                    "Sensor O2 1 (AFR) [0]",
                                    "Sensor O2 2 (V) [1]",
                                    "Sensor O2 2 (AFR) [1]",
                                    "Sensor O2 3 (V) [2]",
                                    "Sensor O2 3 (AFR) [2]",
                                    "Sensor O2 4 (V) [3]",
                                    "Sensor O2 4 (AFR) [3]",
                                    "AFR Comandado",

                                    ///
                                    "Nivel Combustible",
                                    "Presión Combustible",
                                    "Presión Riel",
                                    "Consumo",
                                    "Banco 1 Corto",
                                    "Banco 1 Largo",
                                    "Banco 2 Corto",
                                    "Banco 2 Largo",
                                    // "CatB1S1",
                                    // "CatB1S2",
                                    // "CatB2S1",
                                    // "CatB2S2"
                                  ].contains(sensor['nombre']))
                              .toList();

                          return GridView.builder(
                            padding: const EdgeInsets.all(8),
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 15,
                              crossAxisSpacing: 15,
                              childAspectRatio: constraints.maxWidth /
                                  constraints.maxHeight /
                                  0.7,
                            ),
                            itemCount: sensoresFiltrados.length,
                            itemBuilder: (context, index) {
                              final sensor = sensoresFiltrados[index];
                              return ScaleTransition(
                                scale: tyresAnimation[
                                    index % tyresAnimation.length],
                                child: InkWell(
                                  onTap: () => _showSensorDialog(
                                    context,
                                    sensor[
                                        'nombre'], // Pasar el nombre del sensor
                                    sensor['valor'].toDouble(),
                                  ),
                                  child: SensorCard(
                                    title: sensor['nombre'],
                                    value:
                                        '${sensor['valor'].toStringAsFixed(1)} ${sensor['unidad']}',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
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
                          final sensoresFiltrados = sensors
                              .where((sensor) => [
                                    "Velocidad",
                                    "RPM",
                                    "Temp. Refrigerante",
                                    "Avance encendido",
                                    "Carga del motor",
                                    "Flujo aire masivo",
                                    "Presión colector admisión",
                                    "Voltaje",
                                    // "Sensores O2 Activos", ///
                                    "Sensor O2 1 (V) [0]",
                                    "Sensor O2 1 (AFR) [0]",
                                    "Sensor O2 2 (V) [1]",
                                    "Sensor O2 2 (AFR) [1]",
                                    "Sensor O2 3 (V) [2]",
                                    "Sensor O2 3 (AFR) [2]",
                                    "Sensor O2 4 (V) [3]",
                                    "Sensor O2 4 (AFR) [3]",
                                    "AFR Comandado",

                                    ///
                                    "Nivel Combustible",
                                    "Presión Combustible",
                                    "Presión Riel",
                                    "Consumo",
                                    "Banco 1 Corto",
                                    "Banco 1 Largo",
                                    "Banco 2 Corto",
                                    "Banco 2 Largo",
                                    // "CatB1S1",
                                    // "CatB1S2",
                                    // "CatB2S1",
                                    // "CatB2S2"
                                  ].contains(sensor['nombre']))
                              .toList();

                          return GridView.builder(
                            padding: const EdgeInsets.all(8),
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 15,
                              crossAxisSpacing: 15,
                              childAspectRatio: constraints.maxWidth /
                                  constraints.maxHeight /
                                  0.7,
                            ),
                            itemCount: sensoresFiltrados.length,
                            itemBuilder: (context, index) {
                              final sensor = sensoresFiltrados[index];
                              return ScaleTransition(
                                scale: tyresAnimation[
                                    index % tyresAnimation.length],
                                child: InkWell(
                                  onTap: () => _showSensorDialog(
                                    context,
                                    sensor[
                                        'nombre'], // Pasar el nombre del sensor
                                    sensor['valor'].toDouble(),
                                  ),
                                  child: SensorCard(
                                    title: sensor['nombre'],
                                    value:
                                        '${sensor['valor'].toStringAsFixed(1)} ${sensor['unidad']}',
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
