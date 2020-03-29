import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagePage extends StatefulWidget {
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  Widget build(BuildContext context) {
    return Scaffold(
      body: new CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text("Threads"),
            brightness: Brightness.light,
          )
        ],
      ),
      drawer: new Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                "text",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Users'),
              onTap: () {
                Navigator.pushNamed(context, "/userlist");
              },
            ),
            ListTile(
              leading: Icon(Icons.add_call),
              title: Text('Log out'),
              onTap: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                prefs.clear();
                Navigator.pushNamed(context, "/login");
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/messageeditor");
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
