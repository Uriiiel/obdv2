import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SensorLineChart extends StatefulWidget {
  final String sensorName;
  final ValueNotifier<double> notifier;
  final String minMax;

  const SensorLineChart({
    super.key,
    required this.sensorName,
    required this.notifier,
    required this.minMax,
  });

  @override
  State<SensorLineChart> createState() => _SensorLineChartState();
}

class _SensorLineChartState extends State<SensorLineChart> {
  List<ChartData> chartData = [];
  
  @override
  void initState() {
    super.initState();
    // Registrar el listener directamente
    widget.notifier.addListener(_updateChart);
  }

  void _updateChart() {
    final newValue = widget.notifier.value;
    setState(() {
      chartData.add(ChartData(chartData.length, newValue));
      if (chartData.length > 50) {
        chartData.removeAt(0);
      }
    });
  }

  double get _yAxisMax {
    final parts = widget.minMax.split(' - ');
    return double.tryParse(parts.last) ?? 100.0;
  }

  double get _yAxisMin {
    final parts = widget.minMax.split(' - ');
    return double.tryParse(parts.first) ?? 0.0;
  }

  @override
  void dispose() {
    // Importante: Remover el listener al destruir el widget
    widget.notifier.removeListener(_updateChart);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            widget.sensorName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: NumericAxis(
                title: const AxisTitle(text: 'Muestras'),
                labelStyle: const TextStyle(color: Colors.white70),
                axisLine: const AxisLine(color: Colors.white70),
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(text: widget.sensorName),
                minimum: _yAxisMin,
                maximum: _yAxisMax,
                labelStyle: const TextStyle(color: Colors.white70),
                axisLine: const AxisLine(color: Colors.white70),
              ),
              series: <LineSeries<ChartData, int>>[
                LineSeries<ChartData, int>(
                  dataSource: chartData,
                  xValueMapper: (data, _) => data.x,
                  yValueMapper: (data, _) => data.y,
                  color: Colors.blueAccent,
                  width: 2,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final int x;
  final double y;

  ChartData(this.x, this.y);
}