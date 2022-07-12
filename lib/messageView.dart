import 'dart:io';

import 'package:avana_academy/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  BuildContext commonContext = null;
  TextEditingController editMessageController = new TextEditingController();

  Future<void> _addImage() async {
    FilePickerResult selectedFile =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (selectedFile != null && this.mounted) {
      Utils.showLoadingPop(commonContext);
      final SharedPreferences localStore =
          await SharedPreferences.getInstance();
      List<Map> fileUrls = new List();
      String folderId = threadDetails["folderid"];
      String fileName = selectedFile.files.first.path.split("/").last;

      String url = await Utils.uploadImageGetUrl(
          'AvanaFiles/' + folderId + '/' + fileName,
          File(selectedFile.files.first.path));

      fileUrls.add(
          {"url": url, "name": fileName, "type": fileName.split(".").last});

      await FirebaseFirestore.instance.collection("comments").add({
        "comment": "",
        "created_time": new DateTime.now().millisecondsSinceEpoch,
        "owner": localStore.getString("userId"),
        "owner_name": localStore.getString("name"),
        "ownerrole": localStore.getInt("role"),
        "thread_id": threadID,
        "isattachment": true,
        "attachment": fileUrls,
      });
      Navigator.pop(context);
    }
  }

  bool isCommentSaved = true;
  Future<void> addComment() async {
    if (isCommentSaved) {
      Utils.showLoadingPopText(context, "Adding Comment");
      isCommentSaved = false;
      final SharedPreferences localStore =
          await SharedPreferences.getInstance();
      await FirebaseFirestore.instance.collection("comments").add({
        "comment": commentEditor.text,
        "created_time": new DateTime.now().millisecondsSinceEpoch,
        "owner": localStore.getString("userId"),
        "owner_name": localStore.getString("name"),
        "ownerrole": localStore.getInt("role"),
        "thread_id": threadID,
        "isattachment": false
      });

      focusNode.unfocus();
      String notfyStr = localStore.getString("name") + ":" + commentEditor.text;
      commentEditor.clear();
      Utils.sendPushNotification(
          "New Comment", notfyStr, "messageview", threadID);
      //Utils.pushFeed(" has added new comment.", 1);
      Utils.updateCommentCount(threadID, true);
      isCommentSaved = true;
      Navigator.pop(context);
      focusNode.unfocus();
    }
  }

  Future<void> getComments() async {
    final QuerySnapshot userDetails = await FirebaseFirestore.instance
        .collection('comments')
        //  .orderBy("comments")
        .where("thread_id", isEqualTo: threadID)
        .orderBy("created_time", descending: true)
        .get();
    commentsDoc = userDetails.docs;
    if (this.mounted) {
      setState(() {
        isCmntLoading = false;
      });
    }
  }

  Widget buildInput() {
    return Container(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        // decoration:
        //    BoxDecoration(border: Border(top: BorderSide(color: Colors.grey))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
                onTap: _addImage,
                child: Padding(
                    padding: EdgeInsets.only(left: 5, bottom: 0),
                    child: Container(
                      child: Icon(
                        Icons.image_outlined,
                      ),
                      height: 30,
                      width: 30,
                    ))),
            SizedBox(
              width: 10,
            ),
            Container(
                padding: EdgeInsets.only(left: 7, right: 4),
                decoration: new BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    // You can use like this way or like the below line
                    borderRadius: new BorderRadius.circular(10.0),
                    color: Colors.grey[200]),
                child: SizedBox(
                  width: medQry.size.width * .73,
                  child: TextField(
                      maxLines: null,
                      controller: commentEditor,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Add Comment ..")),
                )),
            Spacer(),
            Padding(
                padding: EdgeInsets.only(left: 5, right: 5, bottom: 0),
                child: GestureDetector(
                    onTap: addComment,
                    child: Container(
                      child: Icon(
                        CupertinoIcons.up_arrow,
                        color: Colors.white,
                        size: 18,
                      ),
                      decoration: new BoxDecoration(
                        shape: BoxShape
                            .circle, // You can use like this way or like the below line
                        //borderRadius: new BorderRadius.circular(30.0),
                        color: Colors.black,
                      ),
                      height: 25,
                      width: 25,
                    )))
          ],
        ));

/*
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        //   borderRadius:new BorderRadius.all(const Radius.circular(10.0)),
      ),
      padding: EdgeInsets.all(3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Material(
            child: new Container(
              color: Colors.black87,
              child: new IconButton(
                icon: new Icon(
                  Icons.add_to_photos,
                  color: Colors.white,
                ),
                onPressed: _addImage,
              ),
            ),
          ),
          Flexible(
            child: Container(
              decoration: new BoxDecoration(
                color: Color.fromRGBO(250, 250, 250, 1),
                borderRadius: new BorderRadius.all(const Radius.circular(20.0)),
                // border: Border.all(width: 2.0, color:Colors.lightBlue),
              ),
              child: TextField(
                focusNode: focusNode,
                scrollPadding: EdgeInsets.all(3),
                maxLines: 10,
                controller: commentEditor,
                decoration: InputDecoration(
                  hintText: 'Add Comment...',
                  contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
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
              color: Colors.black87,
              child: new IconButton(
                icon: new Icon(
                  Icons.send,
                  color: Colors.blue,
                ),
                onPressed: addComment,
              ),
            ),
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
    );
    */
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
            SizedBox(
              width: medQry.size.width * .60,
              child: Text(threadDetails['ownername'].toString(),
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
    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: EdgeInsets.only(
              left: 15,
              right: 0,
              top: 8,
            ),
            child: new Text(
              threadDetails["subject"],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )),
        new Container(
            padding: EdgeInsets.only(
                left: 5,
                right: medQry.size.width * .02,
                top: medQry.size.width * .05),
            child: Text(
              "\t\t\t\t" + threadDetails["content"],
              style: TextStyle(fontSize: 17),
            ))
      ],
    );
  }

  void deleteCommentAlert(BuildContext context, String commentId) {
    showDialog(
        context: context,
        builder: (BuildContext bCont) {
          return new Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(95)),
              child: AlertDialog(
                title: Text(
                  "Do you want to delete this comment",
                  textAlign: TextAlign.center,
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('Delete'),
                    onPressed: () {
                      deleteComment(commentId);
                    },
                  ),
                ],
              ));
        });
  }

  void deleteComment(String commentId) {
    FirebaseFirestore.instance.collection('comments').doc(commentId).delete();
    setState(() {
      Utils.updateCommentCount(threadDetails.id, false);
    });

    Navigator.of(context).pop();
  }

  List<Widget> commentRowWid(BuildContext context) {
    List<Widget> cmtRow = new List();
    if (!isCmntLoading) {
      cmtRow.add(Padding(
          padding: EdgeInsets.only(top: 30),
          child: Text(
            "Comments",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
          )));
      cmtRow.add(SizedBox(height: 12));
      if (commentsDoc.length > 0) {
        for (int i = 0; i < commentsDoc.length; i++) {
          cmtRow.add(Container(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: <Widget>[
                      (commentsDoc[i]["ownerrole"] == 1)
                          ? Icon(
                              Icons.check_circle,
                              size: 16,
                              color: commentsDoc[i]["ownerrole"] == 1
                                  ? Colors.redAccent
                                  : Colors.blueAccent,
                            )
                          : SizedBox(),
                      SizedBox(
                          width: medQry.size.width * .61,
                          child: Text(
                            commentsDoc[i]["owner_name"],
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  commentsDoc[i]["isattachment"]
                      ? Container(
                          width: medQry.size.width * .29,
                          height: medQry.size.width * .29,
                          child: OutlinedButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  width: medQry.size.width * .29,
                                  height: medQry.size.width * .29,
                                  fit: BoxFit.contain,
                                  progressIndicatorBuilder:
                                      (context, url, progress) => Image.asset(
                                    "assets/imagethumbnail.png",
                                    width: 100,
                                    height: 100,
                                  ),
                                  imageUrl: commentsDoc[i]["attachment"][0]
                                      ["url"],
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, "/photoview",
                                    arguments: {
                                      "url": commentsDoc[i]["attachment"][0]
                                          ["url"],
                                      "name": commentsDoc[i]["attachment"][0]
                                          ["name"]
                                    });
                              },
                              style: OutlinedButton.styleFrom(
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(8.0)),
                                side: BorderSide(color: Colors.grey),
                                padding: EdgeInsets.all(0),
                              )),
                          margin: EdgeInsets.only(
                              left: medQry.size.width * .03,
                              top: medQry.size.width * .03),
                        )
                      : Text(
                          "\t\t\t" + commentsDoc[i]["comment"],
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.normal),
                        ),
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        SizedBox(
                            height: 35,
                            child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  Utils.getTimeFrmt(
                                      commentsDoc[i]["created_time"]),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
                                ))),
                        Spacer(),
                        SizedBox(
                            height: 35,
                            child: Visibility(
                                visible: (Utils.isDeleteAvail(
                                        commentsDoc[i]['created_time']) ||
                                    userRole == 1),
                                child: new IconButton(
                                  icon: Image.asset(
                                    "assets/icons/delete.png",
                                    width: 24.0,
                                    height: 24.0,
                                  ),
                                  onPressed: () {
                                    deleteCommentAlert(
                                        context, commentsDoc[i].id);
                                  },
                                )))
                      ],
                    ),
                  )
                ]),
            padding: EdgeInsets.all(medQry.size.width * .03),
            width: medQry.size.width * .85,
            //height: commentsDoc[i]["isattachment"]?100:double.infinity,
            decoration: BoxDecoration(
                color: Color.fromRGBO(238, 238, 238, 1),
                borderRadius: BorderRadius.circular(8.0)),
          ));

          //cmtRow.add();
          cmtRow.add(SizedBox(height: 9));
        }
      } else {
        cmtRow.add(new Center(
          child: Text("No comments added "),
        ));
      }
    } else {
      cmtRow.add(CircularProgressIndicator());
    }
    return cmtRow;
  }

  Future<void> updateMessage() async {
    Utils.showLoadingPopText(context, "Updating the messsage");
    await FirebaseFirestore.instance
        .collection('Threads')
        .doc(threadID)
        .update({
      "content": editMessageController.text,
    });
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void showEditSheet() {
    editMessageController.text = threadDetails["content"];
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
        ),
        builder: (BuildContext bc) {
          return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                  padding: EdgeInsets.all(20),
                  child: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Edit Message",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextField(
                          autofocus: true,
                          maxLines: 5,
                          decoration:
                              InputDecoration(border: OutlineInputBorder()),
                          controller: editMessageController,
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Row(children: [
                          RaisedButton(
                            onPressed: updateMessage,
                            child: Text("Edit"),
                          ),
                          Spacer(),
                          RaisedButton(
                            onPressed: () => {Navigator.pop(context)},
                            child: Text("Cancel"),
                          )
                        ])
                      ])));
        });
  }

  Widget buildCommentSection(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.all(15.0),
      child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: commentRowWid(context)),
    );
  }

  Widget buildAttachmentSection(BuildContext context) {
    List<dynamic> attachmentList = threadDetails["attachments"];

    List<Widget> row1 = new List();
    List<Widget> row2 = new List();
    List<Widget> row3 = new List();
    List<Widget> row4 = new List();
    for (int i = 0; i < attachmentList.length; i++) {
      String type = attachmentList[i]["type"];
      String url = attachmentList[i]["url"];
      String name = attachmentList[i]["name"];
      if (i < 3) {
        row1.add((Utils.attachmentWid(name, null, url, type, context, medQry)));
      } else if (i < 6) {
        row2.add((Utils.attachmentWid(name, null, url, type, context, medQry)));
      } else if (i < 9) {
        row3.add((Utils.attachmentWid(name, null, url, type, context, medQry)));
      } else {
        row4.add((Utils.attachmentWid(name, null, url, type, context, medQry)));
      }
    }

    return new Container(
      child: Column(
        children: <Widget>[
          Row(children: row1),
          Row(children: row2),
          Row(children: row3),
          Row(children: row4)
        ],
      ),
    );
  }

  Future<void> getThreadDetails() async {
    final SharedPreferences localStore = await SharedPreferences.getInstance();
    userId = localStore.getString("userId");
    userRole = localStore.getInt("role");
    Utils.removeNotifyItem(threadID);
    getComments();

    threadDetails = await FirebaseFirestore.instance
        .collection('Threads')
        .doc(threadID)
        .get();
    if (this.mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void deleteThread(String threadId) async {
    setState(() {
      isLoading = true;
    });
    List<dynamic> attachmentList = threadDetails["attachments"];
    for (int i = 0; i < attachmentList.length; i++) {
      try {
        Reference storageReference =
            await FirebaseStorage.instance.refFromURL(attachmentList[i]["url"]);
        storageReference.delete();
      } catch (e) {}
    }

    for (int i = 0; i < commentsDoc.length; i++) {
      if (commentsDoc[i]["isattachment"] &&
          commentsDoc[i]["attachment"] != null) {
        List<dynamic> commnetattachmentList = commentsDoc[i]["attachment"];
        for (int i = 0; i < commnetattachmentList.length; i++) {
          try {
            Reference storageReference = await FirebaseStorage.instance
                .refFromURL(commnetattachmentList[i]["url"]);
            storageReference.delete();
          } catch (e) {}
        }
      }

      FirebaseFirestore.instance
          .collection('comments')
          .doc(commentsDoc[i].id)
          .delete();
    }
    Navigator.of(context).pop();
    FirebaseFirestore.instance.collection('Threads').doc(threadId).delete();
    Navigator.of(context).pop();
  }

  void deleteAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext bCont) {
          return new Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(95)),
              child: AlertDialog(
                title: Text(
                  "Do you want to delete this message",
                  textAlign: TextAlign.center,
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('Delete'),
                    onPressed: () {
                      deleteThread(threadID);
                    },
                  ),
                ],
              ));
        });
  }

  @override
  void initState() {
    super.initState();
    getThreadDetails();
  }

  Widget build(BuildContext context) {
    medQry = MediaQuery.of(context);
    threadID = ModalRoute.of(context).settings.arguments;
    getThreadDetails();
    commonContext = context;
    if (threadDetails != null) {
      return SafeArea(
          child: Scaffold(
        appBar: AppBar(
          title: isLoading ? Text("") : buildMessageInfo(),
          actions: <Widget>[
            (!isLoading &&
                    (Utils.isDeleteAvail(threadDetails['created_time']) ||
                        userRole == 1))
                ? PopupMenuButton(
                    initialValue: 1,
                    onSelected: (val) =>
                        {val == "1" ? showEditSheet() : deleteAlert(context)},
                    itemBuilder: (context) {
                      var list = List<PopupMenuEntry<Object>>();
                      list.add(
                        PopupMenuItem(
                          child: Text("Edit"),
                          value: "1",
                        ),
                      );
                      list.add(
                        PopupMenuDivider(
                          height: 10,
                        ),
                      );
                      list.add(
                        PopupMenuItem(
                          child: Text("Delete"),
                          value: "2",
                        ),
                      );
                      return list;
                    },
                    icon: Icon(Icons.more_vert),
                  )
                : SizedBox()
          ],
        ),
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
                            SizedBox(height: 10),
                            buildAttachmentSection(context),
                            //Divider(color: Colors.black),
                            buildCommentSection(context)
                            // Display your list,
                          ],
                          reverse: false,
                        ),
                      ),
                      (userRole == 1 || userId == threadDetails["owner"])
                          ? buildInput()
                          : SizedBox(height: 10),
                    ],
                  ),
                ],

                // Loading
                // buildLoading()
              ),
      ));
    } else {
      return Scaffold();
    }
  }
}
