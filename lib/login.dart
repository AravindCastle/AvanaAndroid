import 'dart:ffi';

import 'package:avana_academy/Utils.dart';
import 'package:avana_academy/home.dart';
import 'package:avana_academy/messagescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  TextEditingController emailField = new TextEditingController();
  TextEditingController passwordField = new TextEditingController();
  MediaQueryData medQry = null;
  Route _moveToHome() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Future<Void> handleSignIn(BuildContext context) async {
    bool isActive = false;
    if (this.mounted) {
      setState(() {
        isLoading = true;
      });
    }
    if (!Utils.validateLogin(emailField.text, passwordField.text)) {
      final snackBar = SnackBar(content: Text('Invalid Email or Password ! '));
      Scaffold.of(context).showSnackBar(snackBar);
    } else {
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.clear();
        final QuerySnapshot userDetails = await Firestore.instance
            .collection('userdata')
            .where("email", isEqualTo: emailField.text)
            .where("password", isEqualTo: passwordField.text.trim())
            .getDocuments();
        final List<DocumentSnapshot> documents = userDetails.documents;
        if (documents.length > 0) {
          int membershipDate = documents[0]["membershipdate"];
          Utils.userRole = documents[0]["userrole"];
          Utils.userName = documents[0]["username"];
          Utils.userEmail = documents[0]["email"];
          Utils.userId = documents[0].documentID;

          int currDate = new DateTime.now().millisecondsSinceEpoch;
          isActive = membershipDate - currDate > 31540000000
              ? false
              : documents[0]["isactive"];

          if (isActive) {
            prefs.setString("userId", documents[0].documentID);
            prefs.setString("name", documents[0]["username"]);
            prefs.setInt("role", documents[0]["userrole"]);
            Navigator.of(context).push(_moveToHome());
          } else {
            final snackBar = SnackBar(content: Text('Membership Expired ! '));
            Scaffold.of(context).showSnackBar(snackBar);
          }
        } else {
          final snackBar =
              SnackBar(content: Text('Invalid email or password '));
          Scaffold.of(context).showSnackBar(snackBar);
        }
      } catch (Exception) {
        print(Exception);
      }
    }
    if (this.mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget build(BuildContext context) {
    medQry = MediaQuery.of(context);
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            body: Material(
                child: new Container(
                    height: medQry.size.height,
                    width: medQry.size.width,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: Image.asset("assets/loginbg.png").image,
                            fit: BoxFit.cover)),
                    child: SingleChildScrollView(
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              20, medQry.size.height * .12, 20, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 5,
                                child: isLoading
                                    ? LinearProgressIndicator()
                                    : SizedBox(),
                              ),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      medQry.size.width * .06, 0, 0, 0),
                                  child: Container(
                                    height: medQry.size.height * .25,
                                    width: medQry.size.width * .90,
                                    padding: EdgeInsets.only(
                                        left: medQry.size.width * .02,
                                        right: medQry.size.width * .03,
                                        top: medQry.size.width * .03,
                                        bottom: medQry.size.width * .03),
                                    child: Image.asset(
                                      'assets/avanalogo.png',
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                              SizedBox(height: medQry.size.height * 0.03),
                              TextField(
                                obscureText: false,
                                controller: emailField,
                                onEditingComplete: () {
                                  setState(() {
                                    FocusScopeNode currentFocus =
                                        FocusScope.of(context);
                                    currentFocus.unfocus();
                                  });
                                },
                                decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                    ),
                                    focusColor: Colors.blue,
                                    border: OutlineInputBorder(),
                                    // icon: Icon(Icons.perm_identity),
                                    labelStyle: TextStyle(color: Colors.black),
                                    labelText: "Email"),
                              ),
                              SizedBox(height: medQry.size.height * 0.03),
                              TextField(
                                obscureText: true,
                                controller: passwordField,
                                onEditingComplete: () {
                                  setState(() {
                                    FocusScopeNode currentFocus =
                                        FocusScope.of(context);
                                    currentFocus.unfocus();
                                  });
                                },
                                decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                    ),
                                    focusColor: Colors.blue,
                                    border: OutlineInputBorder(),
                                    //  icon: Icon(Icons.vpn_key),
                                    labelStyle: TextStyle(color: Colors.black),
                                    labelText: "Password"),
                              ),
                              SizedBox(height: medQry.size.height * 0.13),
                              Row(children: [
                                Expanded(
                                    child: Padding(
                                  padding:
                                      EdgeInsets.all(medQry.size.width * .06),
                                  child: SizedBox(),
                                )),
                                Builder(builder: (BuildContext context) {
                                  return ButtonTheme(
                                      height: 60,
                                      minWidth: 60,
                                      buttonColor: Colors.red,
                                      child: RaisedButton(
                                          onPressed: () {
                                            handleSignIn(context);
                                          },
                                          shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(60),
                                          ),
                                          child: new Icon(Icons.arrow_forward,
                                              color: Colors.white)));
                                })
                              ])
                            ],
                          )),
                    )))));
  }
}
