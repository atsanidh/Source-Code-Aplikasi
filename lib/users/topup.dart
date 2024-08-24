import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:monitoringlistrik/users/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TopUp());
}

class TopUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billing App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BillingPage(),
    );
  }
}

class BillingPage extends StatefulWidget {
  @override
  _BillingPageState createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '13.43');
  final _paymentMethodController = TextEditingController();
  final _transactionIdController = TextEditingController();

  String _selectedPaymentMethod = '1';
  String _selectedPaymentPrice = '20000';
  String _transactionId = '';
  String _response = '';

  // Midtrans _midtrans;
  MidtransSDK? _midtrans;

  late FirebaseDatabase _database;

  @override
  void initState() {
    super.initState();
    // _midtrans = Midtrans(
    //   clientKey: 'YOUR_CLIENT_KEY',
    //   serverKey: 'YOUR_SERVER_KEY',
    //   environment: MidtransEnvironment.sandbox,
    // );
    initSDK();
    _database = FirebaseDatabase.instance;
  }

  void initSDK() async {
    _midtrans = await MidtransSDK.init(
      config: MidtransConfig(
        clientKey: "SB-Mid-client-wk7DoWv-jUiEr8KE",
        merchantBaseUrl:
            "https://midtransmonitoringpdam.000webhostapp.com/midtrans.php/",
        // colorTheme: ColorTheme(
        //   colorPrimary: Theme.of(context).colorScheme.secondary,
        //   colorPrimaryDark: Theme.of(context).colorScheme.secondary,
        //   colorSecondary: Theme.of(context).colorScheme.secondary,
        // ),
      ),
    );
    _midtrans?.setUIKitCustomSetting(
      skipCustomerDetailsPages: true,
    );
    _midtrans!.setTransactionFinishedCallback((result) {
      print(result.toJson());
    });
  }

  // @override
  // void dispose() {
  //   _midtrans?.removeTransactionFinishedCallback();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeUsers()),
            );
          },
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.lightBlue,
        ),
        padding: EdgeInsets.all(16.0),
        child: Container(
          height: 430,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Pembelian Token (Rp)',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                DropdownButtonFormField(
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                  value: _selectedPaymentPrice,
                  items: [
                    DropdownMenuItem(
                      child: Text('Rp. 20.000'),
                      value: '20000',
                    ),
                    DropdownMenuItem(
                      child: Text('Rp. 50.000'),
                      value: '50000',
                    ),
                    DropdownMenuItem(
                      child: Text('Rp. 100.000'),
                      value: '100000',
                    ),
                    DropdownMenuItem(
                      child: Text('Rp. 200.000'),
                      value: '200000',
                    ),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _selectedPaymentPrice = value!;
                      switch (value) {
                        case '200000':
                          _amountController.text = '167.94';
                        case '100000':
                          _amountController.text = '67.17';
                        case '50000':
                          _amountController.text = '33.58';
                        default:
                          _amountController.text = '13.43';
                      }
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Jumlah Token (KWh)',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                TextFormField(
                  enabled: false,
                  controller: _amountController,
                  decoration: InputDecoration(
                    hintText: 'Jumlah Token (KWh)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the amount';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Text(
                  'Metode Pembayaran',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                DropdownButtonFormField(
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                  value: _selectedPaymentMethod,
                  items: [
                    DropdownMenuItem(
                      child: Text('Midtrans'),
                      value: '1',
                    ),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: () async {
                    var url = Uri.parse(
                        'https://app.sandbox.midtrans.com/snap/v1/transactions');
                    Map<String, dynamic> requestBody = {
                      "transaction_details": {
                        "order_id": "Transaksi ${DateTime.now()}",
                        "gross_amount": _selectedPaymentPrice
                      }
                    };
                    var headers = <String, String>{
                      'Content-Type': 'application/json',
                      'accept': 'application/json',
                      'Authorization':
                          'Basic U0ItTWlkLXNlcnZlci1NU2l3WnlOVktEenNxaDdxT0tXRjNOT1Q6',
                    };
                    String requestBodyJson = jsonEncode(requestBody);

                    var response = await http.post(url,
                        headers: headers, body: requestBodyJson);
                    var token = '';
                    if (response.statusCode == 201) {
                      // Request successful, parse the response
                      var data = response.body;
                      // Process the data as needed
                      token = jsonDecode(data)['token'];
                    } else {
                      // Request failed
                      print(
                          'Request failed with status: ${response.statusCode}');
                    }
                    _midtrans?.startPaymentUiFlow(
                      token: token,
                    );

                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final amount = _amountController.text;
                      final paymentMethod = _paymentMethodController.text;

                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      var init = prefs.getString('user');
                      Map<String, dynamic> userMap = {};

                      final DatabaseReference _databaseReference =
                          FirebaseDatabase.instance.ref();
                      final DatabaseEvent event = await _databaseReference
                          .child('Listrik')
                          .orderByChild('id')
                          .equalTo(init)
                          .once();
                      userMap = Map<String, dynamic>.from(
                          event.snapshot.value as Map<dynamic, dynamic>);
                      double totkwh = double.parse(_amountController.text);
                      Map<String, dynamic> user = {
                        'User': userMap.keys.first,
                        'status': 1,
                        'harga': _selectedPaymentPrice,
                        'total_transaksi': totkwh,
                      };
                      _databaseReference
                          .child('Transaksi_Listrik')
                          .push()
                          .set(user)
                          .then((_) {
                        print("Data inserted successfully.");
                      }).catchError((error) {
                        print("Failed to insert data: $error");
                      });
                      Fluttertoast.showToast(
                        msg: "Tunggu Transaksi Anda sedang di Proses",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomeUsers()),
                        (Route<dynamic> route) => false,
                      );
                      // Show the transaction ID
                      // setState(() {
                      //   _transactionId = transactionId;
                      // });
                    }
                  },
                  child: Text('Request Pembelian'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
