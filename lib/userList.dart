import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class userListPage extends StatefulWidget{

_userListPageState createState() => _userListPageState();
}
class _userListPageState extends State<userListPage>{


  Widget build(BuildContext context){

    return Scaffold(
      
         body:new CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              title: Text("Users"),
              brightness: Brightness.light,
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(        
          onPressed: () {
            Navigator.pushNamed(context, "/adduser");
            // Add your onPressed code here!
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.green,
        ),
    );


  }
}