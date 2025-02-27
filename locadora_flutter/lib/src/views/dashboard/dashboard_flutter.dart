import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:locadora_flutter/src/components/app_title.dart';
import 'package:locadora_flutter/src/components/bar_chart.dart';
import 'package:locadora_flutter/src/components/pie_chart.dart';
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
        title: AppTitle(title: 'Dashboard'),
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
                    child: BarChartWidget(data: data)
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
                          int total = booksData.fold(0, (sum, book) => sum + book.totalRents);
                          return PieChartWidget(booksData: booksData, total: total,);
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
