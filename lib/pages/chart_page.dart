import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/constants/colors_constants.dart';
import 'package:project/constants/db_constants.dart';
import 'package:project/public_pages/customAppBar.dart';
import 'package:project/public_pages/navbar.dart';
import 'package:project/services/alert_service.dart';
import 'package:project/services/firebase_service.dart';
import 'package:project/services/localStorage_service.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  @override
  initState() {
    getUserInfo();
    super.initState();
  }

  final _firebaseService = FirebaseService(DbConstants.portfoyTable);
  final _localStorageService = LocalStorageService();
  List<Map<String, dynamic>> chartDatas = [];

  Future<void> getUserInfo() async {
    var result = await _localStorageService.refreshPage();
    if (result != null) {
      setState(() {
        _firebaseService.loginUser = result;
        getAllData();
      });
    }
  }

  Future<void> getAllData() async {
    var datas = await _firebaseService.response
        .where('userId', isEqualTo: _firebaseService.currentUser!.id)
        .get();

    setState(() {
      chartDatas = datas.docs.map((doc) {
        return {'name': doc['name'], 'quantity': doc['quantity']};
      }).toList();
    });

    print(chartDatas);
  }

  final List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.amber,
    Colors.teal,
    Colors.indigo,
    Colors.lime
  ];

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> sections = chartDatas
        .asMap()
        .map((index, data) {
          Color color = colors[index % colors.length];
          return MapEntry(
            index,
            PieChartSectionData(
              titleStyle: TextStyle(color: Colors.white, fontSize: 20),
              value: data['quantity'].toDouble(),
              title: data['name'],
              showTitle: true,
              radius: 70,
              color: color,
            ),
          );
        })
        .values
        .toList();

    List<BarChartGroupData> barGroups = chartDatas
        .asMap()
        .map((index, data) {
          return MapEntry(
            index,
            BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  fromY: 0,
                  toY: data['quantity'].toDouble(),
                  width: 10,
                  color: ColorConstants.generalColor,
                ),
              ],
            ),
          );
        })
        .values
        .toList();

    return Scaffold(
      drawer: const Navbar(),
      appBar: const CustomAppBar(
        title: 'Grafik',
        titleColor: Colors.white,
        backgroundColor: ColorConstants.generalColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 10,
              child: Container(
                height: 50,
                width: MediaQuery.sizeOf(context).width,
                color: Colors.white,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Icon(
                        Icons.info,
                        color: ColorConstants.generalColor,
                        size: 25,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        textAlign: TextAlign.center,
                        'Hisselerinizin Adet bazında Grafiği',
                        style: TextStyle(
                            color: ColorConstants.generalColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              child: Center(
            child: PieChart(PieChartData(sections: sections)),
          ))
        ],
      ),
    );
  }
}

//  DefaultTabController(
//                 length: 2,
//                 initialIndex: 0,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: <Widget>[
//                     const TabBar(
//                       dividerColor: Colors.black,
//                       indicatorColor: ColorConstants.generalColor,
//                       labelColor: ColorConstants.generalColor,
//                       unselectedLabelColor: Colors.black,
//                       tabs: [
//                         Tab(text: 'Grafik 1'),
//                         Tab(text: 'Grafik 2'),
//                       ],
//                     ),
//                     Expanded(
//                       child: TabBarView(
//                         children: <Widget>[
//                           Padding(
//                             padding: const EdgeInsets.all(20),
//                             child: Center(
//                               child: PieChart(PieChartData(sections: sections)),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(50),
//                             child: Center(
//                               child: BarChart(
//                                 BarChartData(
//                                   borderData: FlBorderData(
//                                     border: const Border(
//                                       top: BorderSide.none,
//                                       right: BorderSide.none,
//                                       left: BorderSide(width: 1),
//                                       bottom: BorderSide(width: 1),
//                                     ),
//                                   ),
//                                   groupsSpace: 10,
//                                   barGroups: barGroups,
//                                   titlesData: FlTitlesData(
//                                     bottomTitles: AxisTitles(
//                                       sideTitles: SideTitles(
//                                         showTitles: true,
//                                         getTitlesWidget:
//                                             (double value, TitleMeta meta) {
//                                           return SideTitleWidget(
//                                             axisSide: meta.axisSide,
//                                             child: Text(
//                                               chartDatas[value.toInt()]['name'],
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),