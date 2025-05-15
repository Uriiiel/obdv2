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
  double _coolantTemp = 0.0;
  double _rpm = 0.0;
  double _engineLoad = 0.0;
  double _ignitionAdvance = 0.0;
  double _speed = 0.0;
  double _maf = 0.0;
  double _intakeManifoldPressure = 0.0;

  Timer? _commandTimer;
  int _currentCommandIndex = 0;
  // Define tus comandos OBD:
  final List<String> _obdCommands = [
    '0105', // Temperatura refrigerante
    '010C', // RPM motor
    '0104', // Carga del motor
    '010E', // Avance de encendido
    '010D', // Velocidad del vehículo
    '0110', // Flujo de aire masivo (MAF)
    '010B', // Presión del colector de admisión
  ];

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

  void _ensureConnection() {
    if (!_isConnected) {
      showDialog(
        context: context,
        barrierDismissible: false, // ¡no deja cerrar tocando afuera!
        builder: (_) => AlertDialog(
          title: const Text('Conectar OBD'),
          content: const Text(
              'Debes conectar el dispositivo OBD por Bluetooth para continuar.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showDeviceList(context); // abre la lista de dispositivos
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
    if (_isConnecting) return;

    setState(() => _isConnecting = true);

    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        _device = device;
        _isConnected = true;
        _isConnecting = false;
        homeController.showTyresController(3);
      });

      // 1) Cierra el diálogo modal de conexión (si existe)
      Navigator.of(context, rootNavigator: true).pop();

      // 2) Inicia la escucha y los envíos periódicos
      _startDataListening();
      _startAutoUpdate();
    } catch (error) {
      setState(() => _isConnecting = false);
      _showError("Error al conectar: ${error.toString()}");
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
      } catch (e) {
        print("Error procesando temperatura: $e");
      }
    } else if (message.startsWith('410C') && message.length >= 8) {
      // RPM motor (010C)
      try {
        int rpmValue = int.parse(message.substring(4, 8), radix: 16);
        setState(() => _rpm = rpmValue / 4.0);
      } catch (e) {
        print("Error procesando RPM: $e");
      }
    } else if (message.startsWith('4104') && message.length >= 6) {
      // Carga del motor (0104)
      try {
        int loadValue = int.parse(message.substring(4, 6), radix: 16);
        setState(() => _engineLoad = (loadValue * 100 / 255).toDouble());
      } catch (e) {
        print("Error procesando carga del motor: $e");
      }
    } else if (message.startsWith('410E') && message.length >= 6) {
      // Avance de encendido (010E)
      try {
        int advanceValue = int.parse(message.substring(4, 6), radix: 16) - 64;
        setState(() => _ignitionAdvance = advanceValue.toDouble());
      } catch (e) {
        print("Error procesando avance de encendido: $e");
      }
    } else if (message.startsWith('410D') && message.length >= 6) {
      // Velocidad del vehículo (010D)
      try {
        int speedValue = int.parse(message.substring(4, 6), radix: 16);
        setState(() => _speed = speedValue.toDouble());
      } catch (e) {
        print("Error procesando velocidad: $e");
      }
    } else if (message.startsWith('4110') && message.length >= 8) {
      // Flujo de aire masivo (0110)
      try {
        int mafValue = int.parse(message.substring(4, 8), radix: 16);
        setState(() => _maf = mafValue / 100.0); // Convertir a g/s
      } catch (e) {
        print("Error procesando MAF: $e");
      }
    } else if (message.startsWith('410B') && message.length >= 6) {
      // Presión del colector de admisión (010B)
      try {
        int pressureValue = int.parse(message.substring(4, 6), radix: 16);
        setState(() => _intakeManifoldPressure = pressureValue.toDouble());
      } catch (e) {
        print("Error procesando presión del colector: $e");
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
  }

  void _sendCommand(String command) {
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
            CircularProgressIndicator(),
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
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Dispositivos Bluetooth', style: TextStyle(fontSize: 20)),
            Expanded(
              child: _devicesList.isEmpty
                  ? Center(
                      child: Text('No se encontraron dispositivos'),
                    )
                  : ListView.builder(
                      itemCount: _devicesList.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(
                          _devicesList[index].name ?? 'Desconocido',
                        ),
                        subtitle: Text(_devicesList[index].address),
                        onTap: () {
                          Navigator.pop(context);
                          _connectToDevice(_devicesList[index]);
                        },
                      ),
                    ),
            ),
            ElevatedButton(
              onPressed: _getPairedDevices,
              child: Text('Actualizar lista'),
            ),
          ],
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                          childAspectRatio: 1.2,
                          children: [
                            SensorCard(
                              title: 'RPM',
                              value: _rpm.toStringAsFixed(0),
                            ),
                            SensorCard(
                              title: 'Velocidad',
                              value: '${_speed.toStringAsFixed(0)} km/h',
                            ),
                            SensorCard(
                              title: 'Temp. Refrigerante',
                              value: '${_coolantTemp.toStringAsFixed(1)}°C',
                            ),
                            SensorCard(
                              title: 'Carga Motor',
                              value: '${_engineLoad.toStringAsFixed(1)}%',
                            ),
                            SensorCard(
                              title: 'Avance Encendido',
                              value: '${_ignitionAdvance.toStringAsFixed(1)}°',
                            ),
                            SensorCard(
                              title: 'Flujo Aire',
                              value: '${_maf.toStringAsFixed(2)} g/s',
                            ),
                            SensorCard(
                              title: 'Presión Colector',
                              value:
                                  '${_intakeManifoldPressure.toStringAsFixed(1)} kPa',
                            ),
                            if (_vin != 'No disponible')
                              SensorCard(
                                title: 'VIN',
                                value: _vin,
                              ),
                          ],
                        ),
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
