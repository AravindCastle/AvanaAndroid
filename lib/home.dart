import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'Utils.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MediaQueryData medQry = null;
  SharedPreferences prefs;
  String userName = "";
  int userRole = 1;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Utils.getAllComments();
  }

  void getUserName() async {
    prefs = await SharedPreferences.getInstance();
    if (this.mounted) {
      setState(() {
        userName = prefs.getString("name");
        userRole = prefs.getInt("role");
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget build(BuildContext context) {
    getUserName();
    medQry = MediaQuery.of(context);
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            leading: Icon(Icons.account_circle),
            title: Text('Home'),
          ),
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: CircularProgressIndicator(strokeWidth: 3)),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                title: Text('Home'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business),
                title: Text('Message'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                title: Text('Users'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                title: Text('Resources'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                title: Text('More'),
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.amber[800],
            onTap: _onItemTapped,
          ),
        ));
  }
}
