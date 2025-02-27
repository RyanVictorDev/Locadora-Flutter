import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:locadora_flutter/src/models/more_rented_book_model.dart';

class PieChartWidget extends StatelessWidget {
  final List<MoreRentedBookModel> booksData;
  final int total;

  const PieChartWidget({super.key, required this.booksData, required this.total});

  @override
  Widget build(BuildContext context) {
    if (booksData.isEmpty) {
      return Center(child: Text("Nenhum dado disponível"));
    }

    // int total = booksData.fold(0, (sum, book) => sum + book.totalRents);

    return PieChart(
      PieChartData(
        sections: booksData.asMap().entries.map((entry) {
          int index = entry.key;
          MoreRentedBookModel book = entry.value;

          return PieChartSectionData(
            value: (book.totalRents / total) * 100,
            title: "${book.name}: ${book.totalRents}",
            titleStyle: const TextStyle(fontWeight: FontWeight.bold),
            radius: 50,
            color: Colors.accents[index % Colors.accents.length],
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}
