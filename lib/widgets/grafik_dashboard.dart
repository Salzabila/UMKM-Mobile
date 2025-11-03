import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GrafikDashboard extends StatelessWidget {
  final List<double> dataPendapatanMingguan;

  const GrafikDashboard({
    super.key,
    required this.dataPendapatanMingguan,
  });

  // ==========================================================
  // PERBAIKAN DI SINI: SESUAIKAN DENGAN API fl_chart TERBARU
  // ==========================================================
  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff757575),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Sn';
        break;
      case 1:
        text = 'Sl';
        break;
      case 2:
        text = 'Rb';
        break;
      case 3:
        text = 'Km';
        break;
      case 4:
        text = 'Jm';
        break;
      case 5:
        text = 'Sb';
        break;
      case 6:
        text = 'Mg';
        break;
      default:
        return Container();
    }
    // Fungsi ini sekarang hanya mengembalikan Text
    return Text(text, style: style, textAlign: TextAlign.center);
  }

  @override
  Widget build(BuildContext context) {
    // Ubah data double menjadi FlSpot
    final spots = dataPendapatanMingguan.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.only(right: 18, left: 12, top: 24, bottom: 12),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            // ==========================================================
            // PERBAIKAN DI SINI: STRUKTUR titlesData YANG BARU
            // ==========================================================
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  interval: 1, // Tampilkan semua label hari
                  getTitlesWidget: getTitles, // Panggil fungsi helper
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 6,
            minY: 0,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Theme.of(context).primaryColor,
                barWidth: 5,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}