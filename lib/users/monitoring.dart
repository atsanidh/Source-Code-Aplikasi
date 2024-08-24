import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesData {
  final String month;
  final int sales;

  SalesData(this.month, this.sales);
}

final List<SalesData> data = [];

class AllData {
  final String month;
  final String sales;

  AllData(this.month, this.sales);
}

class Monitoring extends StatefulWidget {
  @override
  _MonitoringState createState() => _MonitoringState();
}

Future<List<SalesData>> fetchData(Map<String, dynamic> userMap) async {
  List<SalesData> data = [];
  List<String> hari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  for (var map in userMap.values) {
    map.forEach((key, value) {
      if (hari.contains(key)) {
        data.add(SalesData(key, int.parse(value.toString())));
      }
    });
  }
  return data;
}

Future<List<AllData>> fetchAllData(Map<String, dynamic> userMap) async {
  List<AllData> alldata = [];

  List<String> hari = [
    'volt',
    'ampere',
    'watt',
    'kwh',
    'kwhToken',
  ];

  for (var map in userMap.values) {
    map.forEach((key, value) {
      if (hari.contains(key)) {
        alldata.add(AllData(key, value.toString()));
      }
    });
  }
  alldata.sort((a, b) {
    if (a.month == b.month) {
      // If the "detail" fields are the same, sort by "day" from Sunday
      return DateTime.parse(a.month).weekday - DateTime.parse(b.month).weekday;
    } else {
      // Sort by "detail" field
      return a.month.compareTo(b.month);
    }
  });

  alldata.sort((a, b) {
    int indexA = hari.indexOf(a.month);
    int indexB = hari.indexOf(b.month);
    return indexA.compareTo(indexB);
  });
  print(alldata);
  return alldata;
}

class _MonitoringState extends State<Monitoring> {
  List<SalesData> data = [];
  List<AllData> alldata = [];

  Map<String, dynamic> userMap = {};
  var kamar = "";

  void _initRTDB() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var init = prefs.getString('user');
    print(init);

    setState(() {
      kamar = init.toString();
    });

    final DatabaseReference _databaseReference =
        FirebaseDatabase.instance.ref();
    _databaseReference
        .child('Listrik')
        .orderByChild('id')
        .equalTo(init)
        .onValue
        .listen((event) {
      userMap = Map<String, dynamic>.from(
          event.snapshot.value as Map<dynamic, dynamic>);
      fetchData(userMap).then((fetchedData) {
        setState(() {
          data = fetchedData;
        });
      });

      fetchAllData(userMap).then((fetchedData) {
        setState(() {
          alldata = fetchedData;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initRTDB();
  }

  @override
  Widget build(BuildContext context) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    );

    double kwhI = 0;
    double kwhT = 0;
    double kwhS = 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.lightBlue,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue,
        ),
        padding: EdgeInsets.only(top: 12),
        child: Column(
          children: [
            Text(
              '${kamar.toUpperCase()}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 48,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: alldata.map((data) {
                    if (data.month == "kwh") {
                      kwhI = double.parse(data.sales);
                    }
                    if (data.month == "kwhToken") {
                      kwhT = double.parse(data.sales);
                      kwhS = kwhT - kwhI;
                    }
                    double parsedDouble =
                        double.parse(data.sales); // Convert string to double
                    int convertedInt = parsedDouble.toInt();
                    return Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: data.month == 'volt' ||
                              data.month == 'ampere' ||
                              data.month == 'watt' ||
                              data.month == 'kwh' ||
                              data.month == 'kwhToken'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  data.month == 'volt'
                                      ? "Voltage"
                                      : data.month == 'ampere'
                                          ? "Current"
                                          : data.month == 'kwhToken'
                                              ? "Sisa Token"
                                              : data.month == 'kwh'
                                                  ? "KWH"
                                                  : "Daya",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  data.month == 'volt'
                                      ? "${data.sales} V"
                                      : data.month == 'ampere'
                                          ? "${data.sales} A"
                                          : data.month == 'watt'
                                              ? "${data.sales} Watt"
                                              : data.month == 'kwh'
                                                  ? "${data.sales} kWh"
                                                  : "${currencyFormatter.format(kwhS)} kWh",
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  data.month,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  data.sales,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    );
                  }).toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
