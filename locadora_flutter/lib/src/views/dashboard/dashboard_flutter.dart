import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
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
              int total = data.reduce((a, b) => a + b);

              return Column(
                children: [
                  Text(
                    "Relação de livros alugados",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height:20),
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: (data[0] / total) * 100,
                            title: "Alugados: ${data[0]}",
                            color: Colors.blue,
                            radius: 50,
                          ),
                          PieChartSectionData(
                            value: (data[1] / total) * 100,
                            title: "Atrasados: ${data[1]}",
                            color: Colors.red,
                            radius: 50,
                          ),
                          PieChartSectionData(
                            value: (data[2] / total) * 100,
                            title: "No prazo: ${data[2]}",
                            color: Colors.green,
                            radius: 50,
                          ),
                          PieChartSectionData(
                            value: (data[3] / total) * 100,
                            title: "Atraso Entregue: ${data[3]}",
                            color: Colors.orange,
                            radius: 50,
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
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
