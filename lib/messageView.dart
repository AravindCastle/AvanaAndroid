

import 'package:avana_academy/Utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageViewScreen extends StatefulWidget {
  _MessageViewScreenState createState() => _MessageViewScreenState();
}

class _MessageViewScreenState extends State<MessageViewScreen> {
TextEditingController commentEditor= new TextEditingController();
String threadID;
bool isLoading=true;
bool isCmntLoading=true;
DocumentSnapshot threadDetails =null;
 List<DocumentSnapshot> commentsDoc=null;

  Future<void> addComment() async {
    final SharedPreferences localStore = await SharedPreferences.getInstance();

    var succes=await Firestore.instance.collection("comments").add({
      "comment":commentEditor.text,
      "created_time":new DateTime.now().millisecondsSinceEpoch,
      "owner":localStore.getString("userId"),
      "owner_name":localStore.getString("name"),
      "thread_id":threadID,
     
    }); 
    commentEditor.clear();
  }

Future<List> getComments() async{
    final QuerySnapshot userDetails = await Firestore.instance
          .collection('comments')
       //  .orderBy("comments")
          .where("thread_id", isEqualTo: threadID)
          
          .getDocuments();
     commentsDoc= userDetails.documents;
     setState(() {
       isCmntLoading=false;
     });
}
  Widget buildInput() {
    return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            // Button send image
            /*  Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.image),
               // onPressed: getImage,
                //color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),*/
            Material(
              child: new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 1.0),
                  child: SizedBox(width: 20)),
              color: Colors.white,
            ),

            // Edit text
            Flexible(
              child: Container(
                child: TextField(
                  controller: commentEditor,
                  //   style: TextStyle(color: primaryColor, fontSize: 15.0),
                  //   controller: textEditingController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Add Comment...',
                  
                  ),
                  //     focusNode: focusNode,
                ),
              ),
            ),

            // Button send message
            Material(
              child: new Container(
                margin: new EdgeInsets.symmetric(horizontal: 8.0),
                child: new IconButton(
                  icon: new Icon(Icons.send),
                    onPressed:addComment,
                  //   color: primaryColor,
                ),
              ),
              color: Colors.white,
            ),
          ],
        ),
        width: double.infinity,
        height: 50.0,
        decoration: new BoxDecoration(
            //  border: new Border(top: new BorderSide(color: greyColor2, width: 0.5)), color: Colors.white),
            ));
  }

  Widget buildMessageContent()  {    
     return   new Container(  padding: const EdgeInsets.all(10.0), child:Text(threadDetails["content"])
     );
  }
  List<Widget> commentRowWid(){
    List<Widget> cmtRow= new List();
    if(!isCmntLoading){
    cmtRow.add(Text("Comments",style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400            
          ),));
    for(int i=0;i<commentsDoc.length;i++){
      
      cmtRow.add(Container(
                  child: Text(commentsDoc[i]["comment"],
                    style: TextStyle(color: Colors.black),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8.0)),
                 // margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                ));
    }}
    else{
      cmtRow.add(CircularProgressIndicator());
    }
  return cmtRow;
  }
  Widget buildCommentSection(){
    return new Container(
    padding: const EdgeInsets.all(15.0) ,
    child: new Column(
       children: commentRowWid()

    ),

    );
  }


  Widget buildAttachmentSection(BuildContext context){
    List<dynamic> attachmentList = threadDetails["attachments"];

    List<Widget> row1= new List();
     List<Widget> row2= new List();
    for(int i=0;i<attachmentList.length;i++){
      String type=attachmentList[i]["type"];
       String url=attachmentList[i]["url"];
        String name=attachmentList[i]["name"];
        if(i<3){
          row1.add((Utils.attachmentWid(null, url, type, context)));
        }
        else{
 row2.add((Utils.attachmentWid(null, url, type, context)));
        }
        
    } 
  
    return new Container(
      child:  Column(
          children: <Widget>[
            Row(
              children:row1
            )
          ],

      ),
    )  ; 
  }
  Future<void> getThreadDetails() async {
    getComments();
    threadDetails = await Firestore.instance
          .collection('Threads')
          .document(threadID).get();
          setState(() {
            isLoading=false;
          });
  }
  Widget build(BuildContext context) {
    threadID= ModalRoute.of(context).settings.arguments;
    getThreadDetails();
   /* threadDetails = await Firestore.instance
          .collection('Threads')
          .document(threadID).get();*/
    return 
    new Scaffold(
      appBar: AppBar(title: Text("Details")),
      body:isLoading? new CircularProgressIndicator(): Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
             Flexible(child:                  ListView(
                  children: <Widget>[
                   buildMessageContent(),
                    Divider(color:Colors.black),
                    buildAttachmentSection(context),
                    Divider(color:Colors.black),
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
