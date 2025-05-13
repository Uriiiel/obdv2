import 'package:flutter/material.dart';
import 'package:obdv2/pages/dashboard/dashComb_page.dart';
import 'package:obdv2/pages/dashboard/dashOx_page.dart';
import 'package:obdv2/pages/dashboard/dashboard_page.dart';
import 'package:obdv2/pages/home_page.dart';

final Color colorPrimary = Color(0xFF000000);
final Color colorSecondary = Color(0xFF3F3F3F);
final Color backgroundColor = Color(0xFF282728);

class HomeDash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SENSORES',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: colorPrimary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage(user: null)),
            );
          },
        ),
      ),
      backgroundColor: backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Tamaños ajustables para los GIFs
          double gifWidth = 150.0;
          double gifHeight = 150.0;

          // Ancho de los botones basado en el espacio disponible
          double buttonWidth = constraints.maxWidth * 0.28;
          double buttonHeight = constraints.maxHeight * 0.25;

          return Center(
            // Envuelve todo en un Center
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Centra verticalmente
                  children: [
                    IntrinsicWidth(
                      // Asegura que el Row solo ocupe el espacio necesario
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Centra horizontalmente
                        mainAxisSize:
                            MainAxisSize.min, // Ocupa solo el espacio necesario
                        children: [
                          _HomeButton(
                            gifAsset: 'assets/images/engranaje.gif',
                            label: 'Sensores del motor',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SpeedometerPage()),
                              );
                            },
                            width: buttonWidth,
                            height: buttonHeight,
                            gifWidth: gifWidth,
                            gifHeight: gifHeight,
                          ),
                          SizedBox(width: 16), // Espacio entre botones
                          _HomeButton(
                            gifAsset: 'assets/images/200w.gif',
                            label: 'Sensores de oxígeno',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DashboardOxPage()),
                              );
                            },
                            width: buttonWidth,
                            height: buttonHeight,
                            gifWidth: gifWidth,
                            gifHeight: gifHeight,
                          ),
                          SizedBox(width: 16), // Espacio entre botones
                          _HomeButton(
                            gifAsset: 'assets/images/gas.gif',
                            label: 'Sensores de combustible',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DashboardCombPage()),
                              );
                            },
                            width: buttonWidth,
                            height: buttonHeight,
                            gifWidth: gifWidth,
                            gifHeight: gifHeight,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final String gifAsset;
  final String label;
  final VoidCallback onTap;
  final double width;
  final double height;
  final double gifWidth;
  final double gifHeight;

  const _HomeButton({
    required this.gifAsset,
    required this.label,
    required this.onTap,
    required this.width,
    required this.height,
    required this.gifWidth,
    required this.gifHeight,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorSecondary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              spreadRadius: 1,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              gifAsset,
              width: gifWidth, // Usa el ancho personalizado
              height: gifHeight, // Usa el alto personalizado
              fit: BoxFit.contain,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (frame == null) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                }
                return child;
              },
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
