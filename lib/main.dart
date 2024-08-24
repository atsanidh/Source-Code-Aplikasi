import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:monitoringlistrik/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:monitoringlistrik/users/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'admin/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize("ec600c20-34cc-4c8e-9dc1-4008aab72619");
    OneSignal.Notifications.requestPermission(true);
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var init = prefs.getString('user');
    print(init);
    if (init == 'admin') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeAdmin()),
        (Route<dynamic> route) => false,
      );
    } else if (init != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeUsers()),
        (Route<dynamic> route) => false,
      );
    }
    ;
    // You can also store and retrieve other data, such as user type
    setState(() {});
  }

  Future<void> _login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username == 'admin' && password == 'admin') {
      prefs.setString('user', 'admin');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeAdmin()),
      );
    } else if(username == 'admin' && password != 'admin'){
      Fluttertoast.showToast(msg: "Password salah!");
    } else {
      final DatabaseEvent event = await _databaseReference
          .child('data_user')
          .orderByChild('user')
          .equalTo(username)
          .once();
      if (event.snapshot.exists) {
        final Map<String, dynamic> userMap = Map<String, dynamic>.from(
            event.snapshot.value as Map<dynamic, dynamic>);
        final user =
            userMap.values.firstWhere((user) => user['user'] == username);
        print(password);
        if (user['pwd'] == password) {
          prefs.setString('user', user['user']);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeUsers()),
          );
        } else {
          Fluttertoast.showToast(msg: "Password salah!");
          setState(() {
            _errorMessage = 'Incorrect password';
          });
        }
      } else {
        Fluttertoast.showToast(msg: "Username tidak ditemukan!");
        setState(() {
          _errorMessage = 'User not found';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue,
        ),
        child: Container(
          padding: EdgeInsets.only(top: 60),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Selamat Datang',
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'di Kos Srigading',
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 32),
                      Text(
                        'Username',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                              hintText: 'Username',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Password',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ElevatedButton(
                    onPressed: _login,
                    child: Text('Log In'),
                  ),
                ),
                // SizedBox(height: 16),
                // Container(
                //   width: double.infinity,
                //   padding: const EdgeInsets.symmetric(horizontal: 32),
                //   child: ElevatedButton(
                //     onPressed: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(builder: (context) => SignUpPage()),
                //       );
                //     },
                //     child: Text('Sign Up'),
                //   ),
                // ),
                SizedBox(height: 16),
                // if (_errorMessage.isNotEmpty)
                //   Text(
                //     _errorMessage,
                //     style: TextStyle(color: Colors.red),
                //   ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
