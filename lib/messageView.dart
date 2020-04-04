

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageViewScreen extends StatefulWidget {
  _MessageViewScreenState createState() => _MessageViewScreenState();
}

class _MessageViewScreenState extends State<MessageViewScreen> {
TextEditingController commentEditor= new TextEditingController();

  Future<void> addComment() async {
    final SharedPreferences localStore = await SharedPreferences.getInstance();

    var succes=await Firestore.instance.collection("comments").add({
      "comment":commentEditor.text,
      "created_time":new DateTime.now().millisecondsSinceEpoch,
      "owner":localStore.getString("userId"),
      "owner_name":localStore.getString("name"),
      "thread_id":"hu988ikTm7G6R4y2EP6g",
     
    }); 
    commentEditor.clear();
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

  Widget buildMessageContent(){
     return  Flexible(
       child: new Container(  padding: const EdgeInsets.all(10.0), child:Text("O Lorem Ipsum é um texto modelo da indústria tipográfica e de impressão. O Lorem Ipsum tem vindo a ser o texto padrão usado por estas indústrias desde o ano de 1500, quando uma misturou os caracteres de um texto para criar um espécime de livro. Este texto não só sobreviveu 5 séculos, mas também o salto para a tipografia electrónica, mantendo-se essencialmente inalterada. Foi popularizada nos anos 60 com a disponibilização das folhas de Letraset, que continham passagens com Lorem Ipsum, e mais recentemente com os programas de publicação como o Aldus PageMaker que incluem versões do Lorem IpsumO Lorem Ipsum é um texto modelo da indústria tipográfica e de impressão. O Lorem Ipsum tem vindo a ser o texto padrão usado por estas indústrias desde o ano de 1500, quando uma misturou os caracteres de um texto para criar um espécime de livro. Este texto não só sobreviveu 5 séculos, mas também o salto para a tipografia electrónica, mantendo-se essencialmente inalterada. Foi popularizada nos anos 60 com a disponibilização das folhas de Letraset, que continham passagens com Lorem Ipsum, e mais recentemente com os programas de publicação como o Aldus PageMaker que incluem versões do Lorem IpsumO Lorem Ipsum é um texto modelo da indústria tipográfica e de impressão. O Lorem Ipsum tem vindo a ser o texto padrão usado por estas indústrias desde o ano de 1500, quando uma misturou os caracteres de um texto para criar um espécime de livro. Este texto não só sobreviveu 5 séculos, mas também o salto para a tipografia electrónica, mantendo-se essencialmente inalterada. Foi popularizada nos anos 60 com a disponibilização das folhas de Letraset, que continham passagens com Lorem Ipsum, e mais recentemente com os programas de publicação como o Aldus PageMaker que incluem versões do Lorem IpsumO Lorem Ipsum é um texto modelo da indústria tipográfica e de impressão. O Lorem Ipsum tem vindo a ser o texto padrão usado por estas indústrias desde o ano de 1500, quando uma misturou os caracteres de um texto para criar um espécime de livro. Este texto não só sobreviveu 5 séculos, mas também o salto para a tipografia electrónica, mantendo-se essencialmente inalterada. Foi popularizada nos anos 60 com a disponibilização das folhas de Letraset, que continham passagens com Lorem Ipsum, e mais recentemente com os programas de publicação como o Aldus PageMaker que incluem versões do Lorem IpsumO Lorem Ipsum é um texto modelo da indústria tipográfica e de impressão. O Lorem Ipsum tem vindo a ser o texto padrão usado por estas indústrias desde o ano de 1500, quando uma misturou os caracteres de um texto para criar um espécime de livro. Este texto não só sobreviveu 5 séculos, mas também o salto para a tipografia electrónica, mantendo-se essencialmente inalterada. Foi popularizada nos anos 60 com a disponibilização das folhas de Letraset, que continham passagens com Lorem Ipsum, e mais recentemente com os programas de publicação como o Aldus PageMaker que incluem versões do Lorem IpsumO Lorem Ipsum é um texto modelo da indústria tipográfica e de impressão. O Lorem Ipsum tem vindo a ser o texto padrão usado por estas indústrias desde o ano de 1500, quando uma misturou os caracteres de um texto para criar um espécime de livro. Este texto não só sobreviveu 5 séculos, mas também o salto para a tipografia electrónica, mantendo-se essencialmente inalterada. Foi popularizada nos anos 60 com a disponibilização das folhas de Letraset, que continham passagens com Lorem Ipsum, e mais recentemente com os programas de publicação como o Aldus PageMaker que incluem versões do Lorem IpsumO Lorem Ipsum é um texto modelo da indústria tipográfica e de impressão. O Lorem Ipsum tem vindo a ser o texto padrão usado por estas indústrias desde o ano de 1500, quando uma misturou os caracteres de um texto para criar um espécime de livro. Este texto não só sobreviveu 5 séculos, mas também o salto para a tipografia electrónica, mantendo-se essencialmente inalterada. Foi popularizada nos anos 60 com a disponibilização das folhas de Letraset, que continham passagens com Lorem Ipsum, e mais recentemente com os programas de publicação como o Aldus PageMaker que incluem versões do Lorem IpsumO Lorem Ipsum é um texto modelo da indústria tipográfica e de impressão. O Lorem Ipsum tem vindo a ser o texto padrão usado por estas indústrias desde o ano de 1500, quando uma misturou os caracteres de um texto para criar um espécime de livro. Este texto não só sobreviveu 5 séculos, mas também o salto para a tipografia electrónica, mantendo-se essencialmente inalterada. Foi popularizada nos anos 60 com a disponibilização das folhas de Letraset, que continham passagens com Lorem Ipsum, e mais recentemente com os programas de publicação como o Aldus PageMaker que incluem versões do Lorem Ipsum O Lorem Ipsum é um texto modelo da indústria tipográfica e de impressão. O Lorem Ipsum tem vindo a ser o texto padrão usado por estas indústrias desde o ano de 1500, quando uma misturou os caracteres de um texto para criar um espécime de livro. Este texto não só sobreviveu 5 séculos, mas também o salto para a tipografia electrónica, mantendo-se essencialmente inalterada. Foi popularizada nos anos 60 com a disponibilização das folhas de Letraset, que continham passagens com Lorem Ipsum, e mais recentemente com os programas de publicação como o Aldus PageMaker que incluem versões do Lorem Ipsum.")
     ));
  }
  Widget buildCommentSection(){
    return new Container(
    padding: const EdgeInsets.all(15.0) ,
    child: new Column(
       children: <Widget>[
          Text("Comments",style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400            
          ),),
          Container(
                  child: Text("text1",
                    style: TextStyle(color: Colors.black),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8.0)),
                 // margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                ),
                Container(
                  child: Text("text1",
                    style: TextStyle(color: Colors.black),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8.0)),
                 // margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                ),
                Container(
                  child: Text("text1",
                    style: TextStyle(color: Colors.black),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8.0)),
                 // margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                )


                 ]
    ),

    );
  }
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: Text("Details")),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[

              Flexible(
                child: ListView(
                  children: <Widget>[
                    buildMessageContent(),
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
