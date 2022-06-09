import 'dart:ffi';

import 'package:avana_academy/Utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  TextEditingController emailField = new TextEditingController();
  TextEditingController passwordField = new TextEditingController();
  MediaQueryData medQry = null;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<Void> handleSignIn(BuildContext context) async {
    bool isActive = false;
    final ProgressDialog loadingPop = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);

    await loadingPop.style(
      message: "Logging in ...",
    );
    await loadingPop.show();

    if (!Utils.validateLogin(emailField.text, passwordField.text)) {
      loadingPop.hide();

      scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text('Invalid Email or Password ! ')));
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
          loadingPop.hide();

          if (isActive) {
            prefs.setString("userId", documents[0].documentID);
            prefs.setString("name", documents[0]["username"]);
            prefs.setInt("role", documents[0]["userrole"]);

            Navigator.pushReplacementNamed(context, "/feed");
          } else {
            scaffoldKey.currentState
                .showSnackBar(SnackBar(content: Text('Membership Expired ! ')));
          }
        } else {
          scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text('Invalid Email or Password ! ')));
        }
      } catch (Exception) {
        print(Exception);
      }
    }
    loadingPop.hide();
  }

  Widget build(BuildContext context) {
    medQry = MediaQuery.of(context);

    return SafeArea(
        child: Scaffold(
            key: scaffoldKey,
            //resizeToAvoidBottomPadding: false,
            body: Container(
              padding: EdgeInsets.fromLTRB(20, 145, 20, 0),
              constraints: BoxConstraints.expand(),
              /*decoration: BoxDecoration(
                  image: DecorationImage(
                      image: Image.asset("assets/loginbg.jpg").image,
                      fit: BoxFit.fill)),*/
              child: Column(
                children: [
                  Text(
                          "Avana Surgical Systems Pvt Ltd",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: medQry.size.height * 0.03),
                         Text(
                          "Orthotics Learning App",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 21,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: medQry.size.height * 0.1),
                  TextField(
                    obscureText: false,
                    controller: emailField,
                    onEditingComplete: () {
                      setState(() {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        currentFocus.unfocus();
                      });
                    },
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
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
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        currentFocus.unfocus();
                      });
                    },
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusColor: Colors.blue,
                        border: OutlineInputBorder(),
                        //  icon: Icon(Icons.vpn_key),
                        labelStyle: TextStyle(color: Colors.black),
                        labelText: "Password"),
                  ),
                  SizedBox(height: medQry.size.height * 0.03),
                  SizedBox(
                      width: 200,
                      height: 40,
                      child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10),
                          ),
                          color: Color.fromRGBO(128, 0, 0, 1),
                          textColor: Colors.white,
                          onPressed: () => handleSignIn(context),
                          child: Text("Log in"))),
                ],
              ),
            )));
  }
/*
  Widget build(BuildContext context) {
    medQry = MediaQuery.of(context);
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            body: Material(
                child: new Container(
          height: medQry.size.height,
          width: medQry.size.width,
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: Image.asset("assets/loginbg.jpg").image,
                  fit: BoxFit.cover)),
          child: Padding(
              padding: EdgeInsets.fromLTRB(20, medQry.size.height * .12, 20, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 85,
                    child: isLoading ? LinearProgressIndicator() : SizedBox(),
                  ),
                  TextField(
                    obscureText: false,
                    controller: emailField,
                    onEditingComplete: () {
                      setState(() {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        currentFocus.unfocus();
                      });
                    },
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
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
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        currentFocus.unfocus();
                      });
                    },
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusColor: Colors.blue,
                        border: OutlineInputBorder(),
                        //  icon: Icon(Icons.vpn_key),
                        labelStyle: TextStyle(color: Colors.black),
                        labelText: "Password"),
                  ),
                  SizedBox(height: medQry.size.height * 0.05),
                  Row(children: [
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.all(medQry.size.width * .06),
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
                                borderRadius: new BorderRadius.circular(60),
                              ),
                              child: new Icon(Icons.arrow_forward,
                                  color: Colors.white)));
                    })
                  ])
                ],
              )),
        ))));
  }*/
}


 
