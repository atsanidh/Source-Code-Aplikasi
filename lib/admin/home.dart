import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:monitoringlistrik/admin/approve_transaksi.dart';
import 'package:monitoringlistrik/admin/monitoring.dart';
import 'package:monitoringlistrik/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeAdmin extends StatefulWidget {
  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  List<String> data = <String>[];
  @override
  void initState() {
    super.initState();
    loaddata();
  }

  void loaddata() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final DatabaseReference _databaseReference =
        FirebaseDatabase.instance.ref();
    final DatabaseEvent event =
        await _databaseReference.child('Listrik').orderByChild('id').once();

    final Map<String, dynamic> userMap = Map<String, dynamic>.from(
        event.snapshot.value as Map<dynamic, dynamic>);
    data = userMap.keys.toList();
    data.add('Kamar3');
    data.add('Kamar4');
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
          icon: Icon(Icons.shopping_cart),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ApproveTransaksiAdmin()),
            );
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
            Container(
              margin: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              height: 120,
              alignment: Alignment.center,
              width: double.infinity,
              child: Center(
                child: Text(
                  'Monitoring dan Kontrolling pengguna kos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(child: KamarList(kamarIds: data)),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.all(12),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.clear();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text('Log Out'),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class KamarList extends StatelessWidget {
  List<String> kamarIds = <String>[];
  KamarList({required this.kamarIds});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: kamarIds.map((id) => KamarView(id: id)).toList(),
      ),
    );
  }
}

class KamarView extends StatelessWidget {
  final String id;

  KamarView({required this.id});

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
        }else {
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
      } ,
      child: Container(
        margin: EdgeInsets.all(24),
        padding: EdgeInsets.all(14),
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                id,
                style: TextStyle(
                  fontSize: 32,
                ),
              ),
              Icon(
                Icons.bed,
                size: 56,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
