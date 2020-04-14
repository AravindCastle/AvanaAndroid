import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//String[] videoFrmts=new String['.WEBM','.MPG', '.MP2', '.MPEG', '.MPE', '.MPV', '.OGG', '.MP4', '.M4P', '.M4V', '.AVI', '.WMV', '.MOV','.QT', '.FLV', '.SWF', '.AVCHD'];

class MessageEditor extends StatefulWidget {
  _MessageEditorState createState() => _MessageEditorState();
}

class _MessageEditorState extends State<MessageEditor> {
  List<File> uploaderImgs = new List();
  List<String> videoFrmts = new List();
  TextEditingController messageContr= new TextEditingController();
//videoFrmts.addAll({'.WEBM','.MPG', '.MP2', '.MPEG', '.MPE', '.MPV', '.OGG', '.MP4', '.M4P', '.M4V', '.AVI', '.WMV', '.MOV','.QT', '.FLV', '.SWF', '.AVCHD'});
  Future<void> _pickImage() async {
    if (uploaderImgs.length <= 6) {
      File selectedFile = await FilePicker.getFile(type: FileType.any);
      //await ImagePicker.pickImage(source: source);
      if(selectedFile!=null){
        setState(() {
        uploaderImgs.add(selectedFile);
      });
      }
    }
  }
  Future<void> saveThread() async{
    try{
      
    List<Map> fileUrls= new List();
    final SharedPreferences localStore = await SharedPreferences.getInstance();
    for(int i=0;i<uploaderImgs.length;i++){
      String fileName=uploaderImgs[i].path.split("/").last;
        StorageReference storageReference = FirebaseStorage.instance    
          .ref()    
          .child('AvanaFiles/'+fileName);    
        StorageUploadTask uploadTask = storageReference.putFile(uploaderImgs[i]);    
        await uploadTask.onComplete;         
        fileUrls.add({"url":await storageReference.getDownloadURL(),"name":fileName,"type":fileName.split(".").last});

    }

    var succes=await Firestore.instance.collection("Threads").add({
          "content":messageContr.text,
          "owner":localStore.getString("userId"),
          "ownername":localStore.getString("name"),
          "attachments":fileUrls.toList(),
          "created_time":new DateTime.now().millisecondsSinceEpoch,
          "title":localStore.getString("name")+"-"+new DateTime.now().toIso8601String()
        }); 
      Navigator.pushNamed(context, "/messagePage");

    }
    catch(Exception){
      print(Exception);
    }
  }

  Widget previewThumbnail() {
    if (uploaderImgs.length > 0) {
      List<Widget> previewIcons = new List();
      for (int i = 0; i < uploaderImgs.length; i++) {
        File temp = uploaderImgs[i];
        String fileName = temp.path.split("/").last;
        Widget imgCOnt = new Container(
          width: 250,
          height: 30,
          child:Row(
             children: <Widget>[
               Icon(Icons.attachment),SizedBox(width: 15,), Flexible(child: Text(fileName))
             ],
          ) ,
          
          decoration: BoxDecoration(border: Border.all()),
        );
        previewIcons.add(imgCOnt);
      }
      return new SizedBox(
          height: 500,
          
          width:500 ,
          child: Column(
           mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
             children: previewIcons
          ));
    } else {
      return SizedBox(height: 10);
    }
  }

  Widget build(BuildContext context) {
        var size = MediaQuery.of(context).size;

    return new Scaffold(
        appBar: AppBar(
          title: Text("Compose Message"),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.send), onPressed: saveThread)
          ],
        ),
        body: new SingleChildScrollView(
          child: new Container(
            padding: const EdgeInsets.all(1.0),
            alignment: Alignment.center,
            child: Padding(
                padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new TextField(
                          controller: messageContr,
                          maxLines: 12,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 0.0),
                              ),
                              contentPadding:
                                  EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "Type ...")),
                      SizedBox(height: 10),
                      RaisedButton(
                          onPressed: () {
                            _pickImage();
                          },
                          child: Text("Add Files",
                              style: TextStyle(color: Colors.black))),
                              SizedBox(height:10),
                      previewThumbnail()
                    ])),
          ),
        ));
  }
}
