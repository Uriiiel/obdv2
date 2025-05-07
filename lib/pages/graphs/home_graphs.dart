import 'package:flutter/material.dart';
import 'package:obdv2/pages/graphs/graphcomb_page.dart';
import 'package:obdv2/pages/graphs/graphox_page.dart';
import 'package:obdv2/pages/graphs/graphs_page.dart';

final Color colorPrimary = Color(0xFF007AFF); // Azul principal
final Color colorSecondary = Color(0xFF1E90FF); // Azul más claro

class HomeGraphs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GRÁFICOS',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: colorPrimary,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double buttonWidth = constraints.maxWidth * 0.8;
          double buttonHeight = constraints.maxHeight * 0.15;

          return Center(
            child: SingleChildScrollView(
              // Evita desbordamiento
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _HomeButton(
                      icon: Icons.settings,
                      label: 'Gráficos del motor',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RealTimeLineChart()),
                        );
                      },
                      width: buttonWidth,
                      height: buttonHeight,
                    ),
                    SizedBox(height: 16),
                    _HomeButton(
                      icon: Icons.air,
                      label: 'Gráficos de oxígeno',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GraphoxPage()),
                        );
                      },
                      width: buttonWidth,
                      height: buttonHeight,
                    ),
                    SizedBox(height: 16),
                    _HomeButton(
                      icon: Icons.oil_barrel,
                      label: 'Gráficos de combustible',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GraphcombPage()),
                        );
                      },
                      width: buttonWidth,
                      height: buttonHeight,
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
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double width;
  final double height;

  const _HomeButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.width,
    required this.height,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(16),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
