import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MessageEditor extends StatefulWidget {
  _MessageEditorState createState() => _MessageEditorState();
}

class _MessageEditorState extends State<MessageEditor> {
  List<File> uploaderImgs = new List();

  Future<void> _pickImage(ImageSource source) async {
    if (uploaderImgs.length <= 6) {
      File selectedFile = await ImagePicker.pickImage(source: source);
      setState(() {
        uploaderImgs.add(selectedFile);
      });
    }
  }

  Widget previewThumbnail() {
    if(uploaderImgs.length>0){
    List<Widget> previewIcons = new List();
    for (int i = 0; i < uploaderImgs.length; i++) {
      Widget imgCOnt = new Container(
        width: 25,
        height: 25,
        alignment: Alignment.center,
        child: Image.file(uploaderImgs[i]),
        
      );
      previewIcons.add(imgCOnt);
    
    }
    return   GridView.count(
          childAspectRatio: 1,
          padding: const EdgeInsets.all(10),
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          crossAxisCount: 3,
          children: previewIcons);
    }
    else{
      return SizedBox(height:10);
    }
  }

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("Compose Message"),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.send), onPressed: null)
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
                            _pickImage(ImageSource.gallery);
                          },
                          child: Text("Add Files",
                              style: TextStyle(color: Colors.black))),
                      previewThumbnail()
                    ])),
          ),
        ));
  }
}
