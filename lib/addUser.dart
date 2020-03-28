import 'dart:collection';
import 'dart:ffi';
import 'dart:wasm';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

 bool isActive = true;
  String userRole = "3";
  bool loading=false;
class AddUserPage extends StatefulWidget {
  

  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
 TextEditingController userName = new TextEditingController();
  TextEditingController emailId = new TextEditingController();
  TextEditingController password = new TextEditingController();

Widget buttonOrLoading(){

if(loading)  
  return 
    new LinearProgressIndicator(

  );
  else{
    return Builder(builder: (BuildContext context) {
                        return ButtonTheme(
                            height: 30,
                            minWidth: 300,
                            child: RaisedButton(
                              onPressed: () {
                                addnewUser(context);
                              },
                              color: Colors.black,
                              padding: const EdgeInsets.all(10.0),
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0),
                              ),
                              child: const Text('Add New User',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400)),
                            ));
                      });
  }
}

 Future<Null> addnewUser(BuildContext context ) async{
    try{
      HashMap userDetail=new HashMap();
      setState(() {
        loading=true;
      });
   var succes=await Firestore.instance.collection("userdata").add({
      "username":userName.text,
      "email":emailId.text,
      "password":password.text,
      "isactive":isActive,
      "userrole":int.parse(userRole),
      "membershipdate":new DateTime.now().millisecondsSinceEpoch    
    }); 
    
     final snackBar = SnackBar(content: Text('Saved Successfully ! '));
        Scaffold.of(context).showSnackBar(snackBar);
    userName.clear();
    emailId.clear();
    password.clear();
 setState(() {
   loading=false;
 });

    }
 
    catch(Exception){
         final snackBar = SnackBar(content: Text('oops Something went wrong ! '));
         Scaffold.of(context).showSnackBar(snackBar);
    }
  } 
 
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Add user")),
        body: SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.all(1.0),
                //alignment: Alignment.t,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[                      
                      TextField(
                        controller: userName,
                          decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "Username")),
                      SizedBox(height: 10),
                      TextField(
                        controller: emailId,
                          decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "Email Id")),
                      SizedBox(height: 10),
                      TextField(
                        controller: password,
                          decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "Password")),
                      SizedBox(height: 10),
                      SwitchListTile(
                        title: const Text('Activate User'),
                        value: isActive,
                        onChanged: (bool value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                      ),
                      ListTile(
                        title: new Text('Admin'),
                        leading: Radio(
                          value: "1",
                          groupValue: userRole,
                          onChanged: (String value) {
                            setState(() {
                              userRole = value;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: new Text('Faculty'),
                        leading: Radio(
                          value: "2",
                          groupValue: userRole,
                          onChanged: (String value) {
                            setState(() {
                              userRole = value;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: new Text('Member'),
                        leading: Radio(
                          value: "3",
                          groupValue: userRole,
                          onChanged: (String value) {
                            setState(() {
                              userRole = value;
                            });
                          },
                        ),
                      ),
                      
                      SizedBox(height: 10),                      
                      buttonOrLoading(),
                    ],
                  ),
                ))));
  }
}
