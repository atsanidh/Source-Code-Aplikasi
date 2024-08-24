import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:monitoringlistrik/admin/home.dart';
import 'package:monitoringlistrik/admin/monitoring.dart';
import 'package:monitoringlistrik/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApproveTransaksiAdmin extends StatefulWidget {
  @override
  _ApproveTransaksiAdminState createState() => _ApproveTransaksiAdminState();
}

class _ApproveTransaksiAdminState extends State<ApproveTransaksiAdmin> {
  Map<String, dynamic>? data = {};
  @override
  void initState() {
    super.initState();
    loaddata();
  }

  void loaddata() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final DatabaseReference _databaseReference =
        FirebaseDatabase.instance.ref();
    final DatabaseEvent event = await _databaseReference
        .child('Transaksi_Listrik')
        .orderByChild('id')
        .once();

    Map<String, dynamic> userMap = Map<String, dynamic>.from(
        event.snapshot.value as Map<dynamic, dynamic>);
    data = userMap;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          iconSize: 40,
          color: Colors.white,
          padding: EdgeInsets.all(15),
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.lightBlue,
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.lightBlue,
        ),
        child: Column(
          children: [
            Expanded(child: KamarList(kamarIds: data)),
          ],
        ),
      ),
    );
  }
}

class KamarList extends StatelessWidget {
  Map<String, dynamic>? kamarIds;
  KamarList({required this.kamarIds});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: kamarIds!.entries.map((entry) {
          String id = entry.key; // Get the key
          dynamic value =
              entry.value; // Get the value (you can specify the type if known)
          return value['status'] == 1
              ? KamarView(id: id, value: value)
              : Container(); // Create KamarView with id and value
        }).toList(),
      ),
    );
  }
}

class KamarView extends StatelessWidget {
  final String id;
  final dynamic value; // Specify the type if known
  late FirebaseDatabase _database;

  KamarView({required this.id, required this.value});

  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle the click event
        if (id == 'Kamar1' || id == 'Kamar2') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MonitoringAdmin(id: id)),
          );
        } else {
          Fluttertoast.showToast(
            msg: "Sedang Dalam Pengembangan",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      },
      child: Container(
        margin: EdgeInsets.all(24),
        padding: EdgeInsets.all(14),
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    Text(
                      value['User'],
                      style: TextStyle(
                        fontSize: 32,
                      ),
                    ),
                    Text(
                      "Rp. ${currencyFormatter.format(int.parse(value['harga']))}",
                      style: TextStyle(
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    iconSize: 40,
                    padding: EdgeInsets.only(left: 15),
                    icon: Icon(Icons.check),
                    onPressed: () async {
                      Map<String, dynamic> userMap = {};
                      _database = FirebaseDatabase.instance;

                      final DatabaseReference _databaseReference =
                          FirebaseDatabase.instance.ref();
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      final DatabaseEvent event = await _databaseReference
                          .child('Listrik')
                          .child(value['User'])
                          .once();

                      userMap = Map<String, dynamic>.from(
                          event.snapshot.value as Map<dynamic, dynamic>);
                      final ref = _database
                          .reference()
                          .child('Listrik')
                          .child(value['User']);

                      double totkwh =
                          double.parse(userMap['kwhToken'].toString()) +
                              double.parse(value['total_transaksi'].toString());
                      print(double.parse(userMap['kwhToken'].toString()));
                      print(double.parse(value['total_transaksi'].toString()));
                      print(totkwh);
                      await ref.update({
                        'kwhToken': totkwh,
                      });
                      final ref1 = _database
                          .reference()
                          .child('Transaksi_Listrik')
                          .child(id);
                      await ref1.update({
                        'status': 2,
                      });
                      Fluttertoast.showToast(
                        msg: "Transaksi Berhasil Proses",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomeAdmin()),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                  IconButton(
                    iconSize: 40,
                    icon: Icon(Icons.close),
                    onPressed: () async {
                      _database = FirebaseDatabase.instance;

                      final ref1 = _database
                          .reference()
                          .child('Transaksi_Listrik')
                          .child(id);
                      await ref1.update({
                        'status': 3,
                      });
                      Fluttertoast.showToast(
                        msg: "Transaksi Berhasil di Tolak",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomeAdmin()),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
