import 'package:avana_academy/Utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageViewScreen extends StatefulWidget {
  _MessageViewScreenState createState() => _MessageViewScreenState();
}

class _MessageViewScreenState extends State<MessageViewScreen> {
  MediaQueryData medQry;
  TextEditingController commentEditor = new TextEditingController();
  String threadID;
  bool isLoading = true;
  bool isCmntLoading = true;
  DocumentSnapshot threadDetails = null;
  List<DocumentSnapshot> commentsDoc = null;
  var focusNode = new FocusNode();
  String userId;
  int userRole;

  Future<void> addComment() async {
    final SharedPreferences localStore = await SharedPreferences.getInstance();

     await Firestore.instance.collection("comments").add({
      "comment": commentEditor.text,
      "created_time": new DateTime.now().millisecondsSinceEpoch,
      "owner": localStore.getString("userId"),
      "owner_name": localStore.getString("name"),
      "ownerrole": localStore.getInt("role"),
      "thread_id": threadID,
    });
    
    
    focusNode.unfocus();
    String notfyStr=localStore.getString("name")+":"+commentEditor.text;
    commentEditor.clear();
    Utils.sendPushNotification("New Comment",notfyStr,"messageview",threadID);
  }

  Future<void> getComments() async {
    final QuerySnapshot userDetails = await Firestore.instance
        .collection('comments')
        //  .orderBy("comments")
        .where("thread_id", isEqualTo: threadID)
        .orderBy("created_time",descending: true)
        .getDocuments();
    commentsDoc = userDetails.documents;
    if (this.mounted) {
      setState(() {
        isCmntLoading = false;
      });
    }
  }

  Widget buildInput() {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
        color: Colors.black54,
      ))),
      padding: EdgeInsets.all(3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(width: 6), // Edit text
          Flexible(
            child: Container(
              decoration: new BoxDecoration(
                  color: Color.fromRGBO(250, 250, 250, 1),
                  borderRadius:
                      new BorderRadius.all(const Radius.circular(10.0))),
              child: TextField(
                focusNode: focusNode,
                scrollPadding: EdgeInsets.all(3),
                maxLines: 10,
                controller: commentEditor,
                decoration: InputDecoration(
                  hintText: 'Add Comment...',
                  contentPadding: const EdgeInsets.all(4),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                //     focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              color: Colors.transparent,
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: addComment,
              ),
            ),
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
    );
  }

  Widget buildMessageInfo() {
    return new Container(
        //  padding: EdgeInsets.only(
        //    left: medQry.size.width * .03, top: medQry.size.width * .04),
        child: Row(children: [
      SizedBox(
          // width: medQry.size.width * .80,
          //height: medQry.size.width * .13,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
           SizedBox( width:medQry.size.width*.75, child:
            
            Text(threadDetails['ownername'].toString(),
            softWrap: true,
                style: TextStyle(
                    color: Colors.white,                                        
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
           ),           
            SizedBox(height: 3),
            Text(Utils.getMessageTimerFrmt(threadDetails["created_time"]),
                style: TextStyle(
                    color: Colors.white70,
                    // fontStyle: FontStyle.italic,
                    fontSize: 13,
                    fontWeight: FontWeight.normal))
          ]))
    ]));
  }

  Widget buildMessageContent() {
    return new Container(
        padding: EdgeInsets.only(
            left: medQry.size.width * .03,
            right: medQry.size.width * .02,
            top: medQry.size.width * .05),
        child: Text(
          "\t\t\t\t" + threadDetails["content"],
          style: TextStyle(fontSize: 17),
        ));
  }

  List<Widget> commentRowWid() {
    List<Widget> cmtRow = new List();
    if (!isCmntLoading) {
      cmtRow.add(Padding(padding:EdgeInsets.only(top:30) , child:Text(        
        "Comments",        
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
      )));
      cmtRow.add(SizedBox(height: 12));
      if(commentsDoc.length>0){
      for (int i = 0; i < commentsDoc.length; i++) {
        cmtRow.add(Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(children: <Widget>[                Text(
                  commentsDoc[i]["owner_name"],
                  style: TextStyle(
                      color: Colors.black,
                      //fontWeight: FontWeight.normal,
                      fontSize: 18),
                )],),
                //Padding(
                  //  padding: EdgeInsets.only(left: 10),
                    //child:
                     Text(
                      commentsDoc[i]["comment"],
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.normal),
                    ),                    
                    //)
                    Padding(padding: EdgeInsets.only(top:8), child:Text(Utils.getTimeFrmt(commentsDoc[i]["created_time"]),style: TextStyle(fontSize:10,color: Colors.black54), ))
              ]
              ),
          padding: EdgeInsets.all(medQry.size.width * .03),
          width: medQry.size.width * .85,
          decoration: BoxDecoration(
              color: Color.fromRGBO(238, 238, 238, 1),
              borderRadius: BorderRadius.circular(8.0)),
       
        ));
         //cmtRow.add();
        cmtRow.add(SizedBox(height: 9));
      }
      }
      else{
        cmtRow.add(new Center(child: Text("No comments added "),));
      }
    } else {
      cmtRow.add(CircularProgressIndicator());
    }
    return cmtRow;
  }

  Widget buildCommentSection(){
    
    return new Container(
      padding: const EdgeInsets.all(15.0),
      child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: commentRowWid()),
    );

  }

  Widget buildAttachmentSection(BuildContext context) {
    List<dynamic> attachmentList = threadDetails["attachments"];

    List<Widget> row1 = new List();
    List<Widget> row2 = new List();
    for (int i = 0; i < attachmentList.length; i++) {
      String type = attachmentList[i]["type"];
      String url = attachmentList[i]["url"];
      String name = attachmentList[i]["name"];
      if (i < 3) {
        row1.add((Utils.attachmentWid(null, url, type, context, medQry)));
      } else {
        row2.add((Utils.attachmentWid(null, url, type, context, medQry)));
      }
    }

    return new Container(
      child: Column(
        children: <Widget>[Row(children: row1), Row(children: row2)],
      ),
    );
  }

  Future<void> getThreadDetails() async {
    final SharedPreferences localStore = await SharedPreferences.getInstance();
    userId=localStore.getString("userId");
    userRole=localStore.getInt("role");
    Utils.removeNotifyItem(threadID);
    getComments();
    threadDetails =
        await Firestore.instance.collection('Threads').document(threadID).get();
    if (this.mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget build(BuildContext context) {
    medQry = MediaQuery.of(context);
    threadID = ModalRoute.of(context).settings.arguments;
    getThreadDetails();
    /* threadDetails = await Firestore.instance
          .collection('Threads')
          .document(threadID).get();*/
    return new Scaffold(
      appBar: AppBar(title:isLoading?Text(""): buildMessageInfo()),
      body: isLoading
          ? new Container(
              height: medQry.size.height,
              width: medQry.size.width,
              child: Center(child: new CircularProgressIndicator()))
          : Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Flexible(
                      child: ListView(
                        children: <Widget>[
                          //  buildMessageInfo(),
                          buildMessageContent(),
                          SizedBox(height:10),
                          buildAttachmentSection(context),
                          //Divider(color: Colors.black),
                          buildCommentSection()
                          // Display your list,
                        ],
                        reverse: false,
                      ),
                    ),
                    (userRole==1 || userRole==2 || userId==threadDetails["owner"])?
                    buildInput():SizedBox(height:10),
                  ],
                ),
              ],

              // Loading
              // buildLoading()
            ),
    );
  }
}
