import 'dart:async';
import 'package:avana_academy/MessageEditor.dart';
import 'package:avana_academy/Utils.dart';
import 'package:avana_academy/messageView.dart';
import 'package:avana_academy/messagescreen.dart';
import 'package:avana_academy/userDetailsPage.dart';
import 'package:avana_academy/userList.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

import 'addUser.dart';
import 'login.dart';

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
        "/adduser":(context) => AddUserPage(),
        "/userdetailpage" :(context) =>UserDetailsPage(),
        "/messageeditor" :(context) => MessageEditor(),
        "/messageview" :(context) => MessageViewScreen()
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
        primarySwatch: MaterialColor(
            Color.fromRGBO(183, 28, 28, 1).value,
            {
              50: Color.fromRGBO(183, 28, 28, 0) ,
              100: Color.fromRGBO(183, 28, 28, .1),
              200: Color.fromRGBO(183, 28, 28, .2),
              300: Color.fromRGBO(183, 28, 28, .3),
              400: Color.fromRGBO(183, 28, 28, .4),
              500: Color.fromRGBO(183, 28, 28, .5),
              600: Color.fromRGBO(183, 28, 28, .6),
              700: Color.fromRGBO(183, 28, 28, .7),
              800: Color.fromRGBO(183, 28, 28, .8),
              900: Color.fromRGBO(183, 28, 28, .9)
            }
          ),
        secondaryHeaderColor: MaterialColor(
            Color.fromRGBO(117,117,117, 1).value,
            {
              50: Color.fromRGBO(117,117,117, 0) ,
              100: Color.fromRGBO(117,117,117, .1),
              200: Color.fromRGBO(117,117,117, .2),
              300: Color.fromRGBO(117,117,117, .3),
              400: Color.fromRGBO(117,117,117, .4),
              500: Color.fromRGBO(117,117,117, .5),
              600: Color.fromRGBO(117,117,117, .6),
              700: Color.fromRGBO(117,117,117, .7),
              800: Color.fromRGBO(117,117,117, .8),
              900: Color.fromRGBO(117,117,117, .9)
            }
          ),          
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
    if(!isUserLogged){
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
