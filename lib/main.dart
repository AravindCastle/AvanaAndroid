import 'dart:async';
import 'package:avana_academy/messagescreen.dart';
import 'package:avana_academy/screens/login.dart';
import 'package:avana_academy/userList.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

import 'addUser.dart';

void main() => runApp(AvanaHome());

class AvanaHome extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Avana Academy',
      routes: {
        "/login":(context) => LoginPage(),
        "/messagePage" :(context) => MessagePage(),
        "/userlist": (context) => userListPage(),
        "/adduser":(context) => AddUserPage()
      },

      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: AvanaHomePage(title: 'Avana Academy'),
    );
  }
}

class AvanaHomePage extends StatefulWidget {
  AvanaHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _AvanaHomePageState createState() => _AvanaHomePageState();
}

class _AvanaHomePageState extends State<AvanaHomePage> {
  
  bool isUserLogged=false;
  
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     checkUserLogged();
  }

   void checkUserLogged() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userId')) {
      String userId = prefs.getString("userId");     
      DocumentSnapshot userDetails = await Firestore.instance
          .collection('userdata')
          .document(userId)
          .get();          
      if (userDetails.data.length > 0) {
          bool activeState=userDetails.data["isactive"];
          int membershipDate=userDetails.data["membershipdate"];
          int currDate=new DateTime.now().millisecondsSinceEpoch;
          isUserLogged=(currDate-membershipDate) > 31540000000?false:activeState;          
          
      }
    }
    if(isUserLogged){
      Navigator.pushNamed(context, "/login");
    }
    else{
      Navigator.pushNamed(context, "/messagePage");    
    }
  }

  

 
  @override
  Widget build(BuildContext context) {
     
     return Scaffold();
      
  }
}
