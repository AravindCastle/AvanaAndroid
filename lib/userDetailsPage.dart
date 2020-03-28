import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserDetailsArguement {
  final String userId;
  
  UserDetailsArguement(this.userId);
}

class UserDetailsPage extends StatefulWidget{
  _UserDetailsPageState createState() =>_UserDetailsPageState();
}
class _UserDetailsPageState extends State<UserDetailsPage>{
 
  Widget build(BuildContext context){
 final UserDetailsArguement userDet=ModalRoute.of(context).settings.arguments;
    return new Scaffold(
     appBar:AppBar(title:Text("User Details")),
     body: Text(userDet.userId),
    );
  }


}