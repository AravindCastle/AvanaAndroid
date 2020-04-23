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
  Future<void> addComment() async {
    final SharedPreferences localStore = await SharedPreferences.getInstance();

    var succes = await Firestore.instance.collection("comments").add({
      "comment": commentEditor.text,
      "created_time": new DateTime.now().millisecondsSinceEpoch,
      "owner": localStore.getString("userId"),
      "owner_name": localStore.getString("name"),
      "thread_id": threadID,
    });
    commentEditor.clear();

    var textField = new TextField(focusNode: focusNode);
    focusNode.unfocus();
  }

  Future<List> getComments() async {
    final QuerySnapshot userDetails = await Firestore.instance
        .collection('comments')
        //  .orderBy("comments")
        .where("thread_id", isEqualTo: threadID)
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
        padding: EdgeInsets.only(
            left: medQry.size.width * .03, top: medQry.size.width * .04),
        child: Row(children: [
          SizedBox(
            width: medQry.size.width * .13,
            height: medQry.size.width * .13,
            child: CircleAvatar(
                backgroundColor: Color.fromRGBO(117, 117, 117, 1),
                child: Text(
                  threadDetails['ownername']
                      .toString()
                      .substring(0, 1)
                      .toUpperCase(),
                  style: TextStyle(
                      color: Colors.white, fontSize: medQry.size.width * .07),
                )),
          ),
          SizedBox(
              width: medQry.size.width * .80,
              height: medQry.size.width * .13,
              child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(threadDetails['ownername'].toString(),
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: medQry.size.width * .06,
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: 3),
                        Text(Utils.getTimeFrmt(threadDetails["created_time"]),
                            style: TextStyle(
                                color: Colors.black54,
                                // fontStyle: FontStyle.italic,
                                fontSize: medQry.size.width * .035,
                                fontWeight: FontWeight.normal))
                      ])))
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
      cmtRow.add(Text(
        "Comments",
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
      ));
      cmtRow.add(SizedBox(height: 12));
      for (int i = 0; i < commentsDoc.length; i++) {
        cmtRow.add(Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commentsDoc[i]["owner_name"],
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 17),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      commentsDoc[i]["comment"],
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.normal),
                    ))
              ]),
          padding: EdgeInsets.all(medQry.size.width * .03),
          width: medQry.size.width * .85,
          decoration: BoxDecoration(
              color: Color.fromRGBO(238, 238, 238, 1),
              borderRadius: BorderRadius.circular(8.0)),
        ));
        cmtRow.add(SizedBox(height: 9));
      }
    } else {
      cmtRow.add(CircularProgressIndicator());
    }
    return cmtRow;
  }

  Widget buildCommentSection() {
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
      appBar: AppBar(title: Text("Details")),
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
                          buildMessageInfo(),
                          buildMessageContent(),
                          //Divider(color: Colors.black),
                          buildAttachmentSection(context),
                          //Divider(color: Colors.black),
                          buildCommentSection()
                          // Display your list,
                        ],
                        reverse: false,
                      ),
                    ),
                    buildInput(),
                  ],
                ),
              ],

              // Loading
              // buildLoading()
            ),
    );
  }
}
