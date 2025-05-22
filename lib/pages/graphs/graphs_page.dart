import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

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
  late ZoomPanBehavior _zoomPanBehavior;
  late TrackballBehavior _trackballBehavior;
  int _xValue = 0;
  final int windowSize = 50;
  final int maxDataPoints = 1000;

  // Colores para un tema oscuro más cohesivo y profesional
  static const Color _primaryContainerColor = Color(0xFF0166B3);
  static const Color _secondaryContainerColor = Color(0xFF709DCE);
  static const Color _primaryTextColor = Colors.black;
  static const Color _secondaryTextColor = Color(0xFFFFFFFF);
  static const Color _accentColor = Color(0xFFFFFFFF);
  static const Color _gridLineColor = Colors.black12;
  static const Color _axisLineColor = Colors.black12;

  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_updateChart);

    _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enableSelectionZooming: true,
      enablePinching: true,
      zoomMode: ZoomMode.x,
      maximumZoomLevel: 0.1,
    );

    _trackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.longPress, // O ActivationMode.tap
      lineWidth: 1,
      lineColor: _accentColor.withOpacity(0.7),
      lineType: TrackballLineType.vertical,
      tooltipSettings: InteractiveTooltip(
        enable: true,
        color: _secondaryContainerColor.withOpacity(0.9),
        borderColor: _accentColor,
        borderWidth: 1,
        textStyle: TextStyle(color: _primaryTextColor, fontSize: 12),
        //format: 'Muestra: point.x\nValor: point.yValue', // point.yValue para formato
        format: 'x: point.x\ny: point.y'
      ),
      markerSettings: const TrackballMarkerSettings(
        markerVisibility: TrackballVisibilityMode.auto,
        height: 8,
        width: 8,
        color: _accentColor,
        borderColor: _primaryContainerColor,
        borderWidth: 1,
      ),
    );
  }

  void _updateChart() {
    if (!mounted) return;
    final newValue = widget.notifier.value;
    setState(() {
      _xValue++;
      chartData.add(ChartData(_xValue, newValue));
      if (chartData.length > maxDataPoints) {
        chartData.removeRange(0, chartData.length - maxDataPoints);
      }
    });
  }

  double get _yAxisMax {
    try {
      return double.parse(widget.minMax.split(' - ').last);
    } catch (e) {
      return 100.0;
    }
  }

  double get _yAxisMin {
    final parts = widget.minMax.split(' - ');
    if (parts.length == 2) {
      final min = double.tryParse(parts.first.trim());
      return min ?? 0.0;
    }
    return 0.0;
  }
  double get _visibleMinimum {
    if (chartData.isEmpty) return 0;
    //return _xValue > windowSize ? (_xValue - windowSize).toDouble() : chartData.first.x.toDouble();
    return chartData.length >= windowSize
    ? (_xValue - windowSize).toDouble()
    : (chartData.isNotEmpty ? chartData.first.x.toDouble() : 0);
  }

  double get _visibleMaximum => _xValue.toDouble();


  @override
  void dispose() {
    widget.notifier.removeListener(_updateChart);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: _primaryContainerColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.sensorName,
                style: TextStyle(
                  color: _secondaryTextColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SfCartesianChart(
                  zoomPanBehavior: _zoomPanBehavior,
                  trackballBehavior: _trackballBehavior,
                  // plotAreaBorderWidth: 0,
                  plotAreaBackgroundColor: _secondaryContainerColor,
                  margin: const EdgeInsets.only(top: 10, right: 5),
                  primaryXAxis: NumericAxis(
                    autoScrollingMode: AutoScrollingMode.end,
                    autoScrollingDelta: 10,
                  ),

                  primaryYAxis: NumericAxis(
                    minimum: _yAxisMin,
                    maximum: _yAxisMax,
                    numberFormat: NumberFormat.compact()..maximumFractionDigits = 2,
                    labelStyle: TextStyle(color: _secondaryTextColor, fontSize: 11),
                    axisLine: AxisLine(color: _axisLineColor, width: 1),
                    majorGridLines: MajorGridLines(
                      color: _gridLineColor,
                      width: 0.8,
                      // dashArray: <double>[5,5],
                    ),
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                    interval: (_yAxisMax - _yAxisMin) / 5,
                  ),

                  series: <SplineSeries<ChartData, int>>[
                    SplineSeries<ChartData, int>(
                      dataSource: chartData,
                      cardinalSplineTension: 0.1,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                      //name: widget.sensorName,
                      animationDuration: 200,
                      color: _accentColor,
                      width: 3.0,
                      // gradient: LinearGradient(
                      //   colors: <Color>[_accentColor.withOpacity(0.5), _accentColor],
                      //   stops: <double>[0.2, 0.9],
                      //   begin: Alignment.bottomCenter,
                      //   end: Alignment.topCenter,
                      // ),
                      markerSettings: const MarkerSettings(
                        isVisible: false,
                        // Si los activas, considera hacerlos más sutiles:
                        // height: 5,
                        // width: 5,
                        // shape: DataMarkerType.circle,
                        // borderColor: _accentColor,
                        // color: _secondaryContainerColor,
                        // borderWidth: 1,
                      ),
                      // Para un look más "lleno", puedes usar SplineAreaSeries o AreaSeries
                      // y añadir un gradiente al área.
                      // Ejemplo con área y gradiente:
                      // type: 'Area', // LineSeries a CartesianSeries
                      // opacity: 0.3,
                      // borderColor: _accentColor,
                      // borderWidth: 2,
                      // gradient: LinearGradient(
                      //   colors: [_accentColor.withOpacity(0.1), _accentColor.withOpacity(0.4), _accentColor.withOpacity(0.8)],
                      //   stops: const [0.0, 0.5, 1.0],
                      //   begin: Alignment.bottomCenter,
                      //   end: Alignment.topCenter,
                      // ),
                    )
                  ],
                  // tooltipBehavior: TooltipBehavior(
                  //   enable: true,
                  //   color: _secondaryContainerColor.withOpacity(0.9),
                  //   borderColor: _accentColor,
                  //   borderWidth: 1,
                  //   textStyle: TextStyle(color: _primaryTextColor, fontSize: 12),
                  //   format: 'Muestra: point.x\nValor: point.y',
                  //   header: '',
                  //   canShowMarker: false,
                  //   shadowColor: Colors.black.withOpacity(0.5),
                  //   elevation: 4,
                  // ),
                  // borderColor: _axisLineColor,
                  // borderWidth: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final int x;
  final double y;

  ChartData(this.x, this.y);
}