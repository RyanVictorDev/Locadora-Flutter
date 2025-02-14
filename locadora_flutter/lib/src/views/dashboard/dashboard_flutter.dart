import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:locadora_flutter/src/models/more_rented_book_model.dart';
import 'package:locadora_flutter/src/models/rents_per_renters_model.dart';
import 'package:locadora_flutter/src/services/dashboard_service.dart';

class DashboardFlutter extends StatefulWidget {
  @override
  _DashboardFlutterState createState() => _DashboardFlutterState();
}

class _DashboardFlutterState extends State<DashboardFlutter> {
  final _dashboardService = DashboardService();

  late Future<int> rentsQuantity;
  late Future<int> rentsLateQuantity;
  late Future<int> deliveredInTimeQuantity;
  late Future<int> deliveredWithDelayQuantity;
  late Future<List<MoreRentedBookModel>> mostRentedBooks;
  late Future<List<RentsPerRentersModel>> rentsPerRentersFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadRentsPerRenters();
  }

  void _loadData() {
    setState(() {
      rentsQuantity = _dashboardService.getRentsQuantity(numberOfMonths: 1);
      rentsLateQuantity =
          _dashboardService.getRentsLateQuantity(numberOfMonths: 1);
      deliveredInTimeQuantity =
          _dashboardService.getDeliveredInTimeQuantity(numberOfMonths: 1);
      deliveredWithDelayQuantity =
          _dashboardService.getDeliveredWithDelayQuantity(numberOfMonths: 1);
      mostRentedBooks = _dashboardService.getMostRentedBooks(numberOfMonths: 1);
    });
  }

  void _loadRentsPerRenters() {
    setState(() {
      rentsPerRentersFuture = DashboardService().fetchRentsPerRenters(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: Text(
            'Dashboard',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<int>>(
          future: Future.wait([
            rentsQuantity,
            rentsLateQuantity,
            deliveredInTimeQuantity,
            deliveredWithDelayQuantity
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Erro ao carregar os dados: ${snapshot.error}",
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              );
            } else {
              List<int> data = snapshot.data!;
              return Column(
                children: [
                  Text(
                    "Relação de livros alugados",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        barGroups: [
                          BarChartGroupData(x: 0, barRods: [
                            BarChartRodData(
                                toY: data[0].toDouble(), color: Colors.blue)
                          ]),
                          BarChartGroupData(x: 1, barRods: [
                            BarChartRodData(
                                toY: data[1].toDouble(), color: Colors.red)
                          ]),
                          BarChartGroupData(x: 2, barRods: [
                            BarChartRodData(
                                toY: data[2].toDouble(), color: Colors.green)
                          ]),
                          BarChartGroupData(x: 3, barRods: [
                            BarChartRodData(
                                toY: data[3].toDouble(), color: Colors.orange)
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
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                              reservedSize:
                                  60,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Livros mais alugados",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<List<MoreRentedBookModel>>(
                      future: mostRentedBooks,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                                "Erro ao carregar os dados dos livros mais alugados"),
                          );
                        } else {
                          List<MoreRentedBookModel> booksData = snapshot.data!;
                          int total = booksData.fold(
                              0, (sum, book) => sum + book.totalRents);
                          return PieChart(
                            PieChartData(
                              sections: booksData.map((book) {
                                return PieChartSectionData(
                                  value: (book.totalRents / total) * 100,
                                  title: "${book.name}: ${book.totalRents}", titleStyle: TextStyle(fontWeight: FontWeight.bold),
                                  radius: 50,
                                  color: Colors.accents[
                                      booksData.indexOf(book) %
                                          Colors.primaries.length],
                                );
                              }).toList(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                                  SizedBox(height: 10),
                  Expanded(
                    child: FutureBuilder<List<RentsPerRentersModel>>(
                      future: rentsPerRentersFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Erro ao carregar dados'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('Nenhum dado disponível'));
                        }

                        final rentsPerRenters = snapshot.data!;
                        return ListView.builder(
                          itemCount: rentsPerRenters.length,
                          itemBuilder: (context, index) {
                            final rentsPerRenter = rentsPerRenters[index];
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(rentsPerRenter.name, style: TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle:Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Aluguéis ativos: ${rentsPerRenter.rentsActive}'),
                                    Text('Total de alugueis: ${rentsPerRenter.rentsQuantity}'),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                ),
                                Divider(),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
