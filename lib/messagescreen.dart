import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'Utils.dart';

class MessagePage extends StatefulWidget {
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  
  MediaQueryData medQry = null;
  SharedPreferences prefs ;
  String userName="";
  int userRole=1;
 
 
  @override
  void initState() {
      super.initState();    
      Utils.getAllComments();  
  }

  void getUserName() async{
      prefs = await SharedPreferences.getInstance();
    if (this.mounted){

    setState(() {
     userName=prefs.getString("name"); 
     userRole=prefs.getInt("role");
    });     
    }
  }
 

  Widget messageItem(DocumentSnapshot messageDoc, BuildContext context) {
    return new GestureDetector(
        child: Card(
            elevation: 3,
            child: new Container(
              height:  messageDoc["content"].length>150?145:125,
              child: new Padding(
                  padding: EdgeInsets.only(top:10,bottom:10,left:8,right:8),
                  child: new Column(children: [
                    Row(children: [
                      Utils.isNewMessage(messageDoc.documentID,prefs),
                      SizedBox(width: 5),
                      SizedBox(
                        
                        width: medQry.size.width * .68,
                        child: Text(
                          messageDoc["ownername"],
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: TextStyle(fontSize: 19,color: Colors.black)
                          
                        ),
                      ),
                      SizedBox(
                        width: medQry.size.width*.19,
                      child:Text(
                        Utils.getTimeFrmt(messageDoc["created_time"]),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          
                         color: Colors.black87,
                            fontSize: 11,
                            
                           ),
                      ),
                      ),                      
                    ]),
                    SizedBox(height: medQry.size.height * .01),
                    Row(
                      children: <Widget>[
                        SizedBox(width:15),
                        SizedBox(
                          width: medQry.size.width * .89,
                          child: Text(
                            messageDoc["content"],
                            maxLines: 3,                                                      
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: TextStyle(
                                fontSize: 15,color: Colors.black54),
                          ),
                        ),                       
                      ],
                    ),
                    SizedBox(height: 7),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[  
                        SizedBox(width:15),                   
                        Icon(Icons.comment,color: Colors.green),
                        Text(Utils.threadCount.containsKey(messageDoc.documentID)?"  "+Utils.threadCount[messageDoc.documentID].toString():"  0"),
                        SizedBox(width:10),
                        Icon(Icons.attachment,color: Colors.deepOrange),
                        Text((messageDoc["attachments"].length>0)?"  "+messageDoc["attachments"].length.toString():"  0"),                    
                      ],)
                  ])),
            )),
        onTap: () {
          Navigator.pushNamed(context, "/messageview",
              arguments: messageDoc.documentID);
        });
  }

  Widget build(BuildContext context) {
       getUserName();
    medQry = MediaQuery.of(context);
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(title: Utils.getNewMessageCount(prefs)),
          body: new StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('Threads')
                .orderBy("created_time",descending: true)                
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return SizedBox(child:  new LinearProgressIndicator(),height:5);
              return new ListView(
                children: snapshot.data.documents.map((document) {
                  return messageItem(document, context);
                }).toList(),
              );
            },
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(25, 118, 210, 1),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height:medQry.size.width*.15, 
                            width:medQry.size.width*.15,
                            child: CircleAvatar(
                              child: Icon(Icons.account_circle, size: medQry.size.width*.15),
                            ),
                          ),
                          SizedBox(height:15),
                          Text(userName,style: TextStyle(fontSize:18,color: Colors.white))
                        ])),
                ListTile(
                  leading: Icon(Icons.message),
                  title: Text('Messages'),
                  onTap: () {
                    Navigator.pushNamed(context, "/messagePage" ); 
                  },
                ),
                (userRole==1) ?
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Users'),
                  onTap: () {
                    Navigator.pushNamed(context, "/userlist");
                  },
                ):SizedBox(height:0),
                ListTile(
                  leading: Icon(Icons.image),
                  title: Text('Faculties'),
                  onTap: () {
                     Navigator.pushNamed(context, "/facultyPage" );  
                  },
                ),
                ListTile(
                  leading: Icon(Icons.image),
                  title: Text('Resources'),
                  onTap: () {
                    Navigator.pushNamed(context, "/gallery",arguments:{"superLevel":0,"parentid":"0","title":"Gallery"} ); 
                  },
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
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
            backgroundColor: Theme.of(context).secondaryHeaderColor,
          ),
        ));
  }
}
