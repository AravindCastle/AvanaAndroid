import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailField = new TextEditingController();
  TextEditingController passwordField = new TextEditingController();

  Future<Void> handleSignIn(BuildContext context) async{
    bool isActive=false;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final QuerySnapshot userDetails = await Firestore.instance
          .collection('userdata')
          .where("email", isEqualTo: emailField.text)
          .where("password",isEqualTo: passwordField.text.trim()) 
          .getDocuments();
      final List<DocumentSnapshot> documents = userDetails.documents;
      if (documents.length > 0) {
         int membershipDate=documents[0]["membershipdate"];
         int currDate=new DateTime.now().millisecondsSinceEpoch;
         isActive=membershipDate-currDate > 31540000000?false:documents[0]["isactive"];   
        
        if(isActive){
          prefs.setString("userId", documents[0].documentID);
        prefs.setString("name", documents[0]["username"]);
        prefs.setString("role", documents[0]["role"]);
       // prefs.setString("isActive", documents[0]["isactive"]);
       // prefs.setString("membershipdate", documents[0]["membershipdate"]);
             Navigator.pushNamed(context, "/messagePage"); 
        }
        else{
         final snackBar = SnackBar(content: Text('Membership Expired ! '));
        Scaffold.of(context).showSnackBar(snackBar);
        }
        
      } else {
        final snackBar = SnackBar(content: Text('Invalid email or password '));
        Scaffold.of(context).showSnackBar(snackBar);
      }
    } catch (Exception) {
      print(Exception);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: new Container(
      padding: const EdgeInsets.all(1.0),
      alignment: Alignment.center,
      color: Color.fromRGBO(227, 228, 228, 1),
      constraints: BoxConstraints.expand(
          //height: Theme.of(context).textTheme.display1.fontSize * 500,
          ),
      child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height:  100,
                child: AnimatedDefaultTextStyle(
                    curve: Curves.linear,
                    child: Text("Avana Academy"),
                    style: TextStyle(
                        fontSize:   30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    duration: const Duration(milliseconds: 500)),
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
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      hintText: "Email")),
              SizedBox(height: 15),
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
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      hintText: "Password")),
              SizedBox(height: 45),
              Builder(builder: (BuildContext context) {
                return ButtonTheme(
                    height: 30,
                    minWidth: 300,
                    child: RaisedButton(
                      onPressed: () {
                        handleSignIn(context);
                      },
                      color: Colors.black,
                      padding: const EdgeInsets.all(10.0),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      child: const Text('Log in with Avana',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w400)),
                    ));
              })
            ],
          )),
    ));
  }
}
