import 'dart:async';
import 'dart:io';
import 'package:avana_academy/MessageEditor.dart';
import 'package:avana_academy/messageView.dart';
import 'package:avana_academy/messagescreen.dart';
import 'package:avana_academy/userDetailsPage.dart';
import 'package:avana_academy/userList.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
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
      home: SplashScreen.navigate(
        name: 'assets/splashScreen.flr',
        next: (context) => AvanaHomePage(title: 'Avana Academy'),
        until: () => Future.delayed(Duration(seconds: 1)),
        startAnimation: 'splash',
        loopAnimation:"splash",
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
      ),            
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
   final FirebaseMessaging _fcm = FirebaseMessaging();
      StreamSubscription iosSubscription;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     checkUserLogged();
     _fcm.subscribeToTopic("all");
     if (Platform.isIOS) {
            iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
                // save the token  OR subscribe to a topic here
            });

            _fcm.requestNotificationPermissions(IosNotificationSettings());
        }
        _fcm.configure(
          onMessage: (Map<String, dynamic> message) async {
            print("onMessage: $message");
           /*
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                        content: ListTile(
                        title: Text(message['notification']['title']),
                        subtitle: Text(message['notification']['body']),
                        ),
                        actions: <Widget>[
                        FlatButton(
                            child: Text('Ok'),
                            onPressed: () => Navigator.of(context).pop(),
                        ),
                    ],
                ),
            );
            */
        },
        onLaunch: (Map<String, dynamic> message) async {
            print("onLaunch: $message");
            // TODO optional
        },
        onResume: (Map<String, dynamic> message) async {
            print("onResume: $message");
            // TODO optional
        },
      );
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
     MediaQueryData md=MediaQuery.of(context);
     return Scaffold(
       body: new Container(   
         child:FlareActor('assets/splashScreen.flr', animation: 'splash')
       ),
     );
      
  }
}
