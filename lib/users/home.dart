import 'package:flutter/material.dart';
import 'package:monitoringlistrik/users/topup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'monitoring.dart';

class HomeUsers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue,
        ),
        padding: EdgeInsets.only(top: 80),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Icon(Icons.flash_on_rounded, color: Colors.white, size: 300),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Monitoring()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shadowColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: Container(
                            height: 120,
                            width: 120,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons
                                      .manage_search, // Using built-in Material icon
                                  size: 50.0,
                                  color: Colors.blue,
                                ),
                                Text('Monitoring')
                              ],
                            )),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shadowColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TopUp()),
                          );
                        },
                        child: Container(
                            height: 120,
                            width: 120,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons
                                      .attach_money_sharp, // Using built-in Material icon
                                  size: 50.0,
                                  color: Colors.blue,
                                ),
                                Text('Billing')
                              ],
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
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
          ],
        ),
      ),
    );
  }
}
