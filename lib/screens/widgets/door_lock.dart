import 'package:flutter/material.dart';
import 'package:obdv2/screens/widgets/comb_card.dart';

class DoorLock extends StatelessWidget {
  const DoorLock({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Márgenes iguales a HomeScreen
      final horizontalMargin = 1.0;
      final usableWidth = constraints.maxWidth - horizontalMargin * 2;
      const desiredCardHeight = 205.0;
      // Calcula el ancho de cada card
      final cardWidth = (usableWidth - 2 * 20) / 3;
      final aspect = cardWidth / desiredCardHeight;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 8),
        child: StreamBuilder<List<CombCard>>(
          stream: SensorService().streamSensores(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }


            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return Center(
            //     child: Image.asset(
            //       'assets/gifs/tyre.gif',
            //       width: 100,
            //       height: 100,
            //       fit: BoxFit.contain,
            //     ),
            //   );
            // }


            final datos = snapshot.data!
                .where((s) => [
                      "Consumo instantáneo de combustible",
                      "Estado del sistema de combustible",
                      "Nivel de combustible",
                      "Porcentaje etanol en combustible",
                      "Presion Riel combustible directa",
                      "Presion Riel combustible relativa",
                      "Presión de la bomba de combustible",
                      "Tipo combustible",
                    ].contains(s.nombre))
                .toList();

            return GridView.builder(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 22,
                crossAxisSpacing: 20,
                childAspectRatio: aspect,
              ),
              itemCount: datos.length,
              itemBuilder: (context, i) {
                return SensorCard(
                  isBottomTwoTyres: i >= datos.length - 3,
                  sensorData: datos[i],
                );
              },
            );
          },
        ),
      );
    });
  }
}
