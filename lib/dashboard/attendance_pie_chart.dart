import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class AttendancePieChart extends StatelessWidget {
  final int present;
  final int absent;
  final int leave;
  final int halfDay;
  final int workingDays;

  AttendancePieChart({
    required this.present,
    required this.absent,
    required this.leave,
    required this.halfDay,
    required this.workingDays,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, double> dataMap = {
      "Present": present.toDouble(),
      "Absent": absent.toDouble(),
      "Leave": leave.toDouble(),
      "Half Day": halfDay.toDouble(),
    };

    final List<Color> colorList = [
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.blue,
    ];

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "📊 Monthly Attendance ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                TextSpan(
                  text: "(Working Days: $workingDays)",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          PieChart(
            dataMap: dataMap,
            chartType: ChartType.disc,
            chartRadius:
                MediaQuery.of(context).size.width / 2.6, // slightly smaller
            colorList: colorList,
            chartValuesOptions: ChartValuesOptions(
              showChartValueBackground: false,
              decimalPlaces: 0,
              showChartValuesInPercentage: false, // shows count instead
              chartValueStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            legendOptions: LegendOptions(
              legendPosition: LegendPosition.right,
              showLegendsInRow: false,
              legendTextStyle: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
