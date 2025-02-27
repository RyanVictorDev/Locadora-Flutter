import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatelessWidget {
  final List<int> data;

  const BarChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(toY: data[0].toDouble(), color: Colors.blue)
          ]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(toY: data[1].toDouble(), color: Colors.red)
          ]),
          BarChartGroupData(x: 2, barRods: [
            BarChartRodData(toY: data[2].toDouble(), color: Colors.green)
          ]),
          BarChartGroupData(x: 3, barRods: [
            BarChartRodData(toY: data[3].toDouble(), color: Colors.orange)
          ]),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                List<String> labels = [
                  "Total de Aluguéis",
                  "Atrasados",
                  "No Prazo",
                  "Com Atraso"
                ];

                return SideTitleWidget(
                  space: 10,
                  meta: meta,
                  child: Text(
                    labels[value.toInt()],
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              reservedSize: 60,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
