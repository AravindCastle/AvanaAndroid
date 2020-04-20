import 'dart:io';
import 'dart:ui';


import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class Utils{
static Map<int, Color> primColor =
{
50:Color.fromRGBO(183, 28, 28, .1),
100:Color.fromRGBO(183, 28, 28, .2),
200:Color.fromRGBO(183, 28, 28, .3),
300:Color.fromRGBO(183, 28, 28, .4),
400:Color.fromRGBO(183, 28, 28, .5),
500:Color.fromRGBO(183, 28, 28, .6),
600:Color.fromRGBO(183, 28, 28, .7),
700:Color.fromRGBO(183, 28, 28, .8),
800:Color.fromRGBO(183, 28, 28, .9),
900:Color.fromRGBO(183, 28, 28, 1),
};

 


static bool getImageFormats(String isSupported){
  List<String> imgFrmt= new List();
  imgFrmt.add("jpeg");
  imgFrmt.add("jpeg");
  imgFrmt.add("jpg");
  imgFrmt.add("bmp");
  imgFrmt.add("png");
  imgFrmt.add("gif");
  imgFrmt.add("heif");

return imgFrmt.contains(isSupported.toLowerCase());

}
static String getMessageTimerFrmt(int time){
  DateTime dt= new DateTime.fromMillisecondsSinceEpoch(time);
  DateTime todat = new DateTime.now();
  int day=dt.day.toInt();
  int hour=dt.hour.toInt();  
  int min=dt.minute.toInt();
  int month=dt.month.toInt();  
  int year=dt.year.toInt();
  String timeFrmt="";
  if(year==todat.year && day==todat.day.toInt() && month==todat.month.toInt()){
    timeFrmt=hour.toString()+":"+min.toString();
   
  }
  else{
     timeFrmt=day.toString()+"/"+month.toString()+"/"+year.toString().substring(1,3);
  }
return timeFrmt;

}

static String getTimeFrmt(int time){
  DateTime dt= new DateTime.fromMillisecondsSinceEpoch(time);
  return dt.day.toString()+"/"+dt.month.toString()+"/"+dt.year.toString().substring(2,3)+" "+dt.hour.toString()+":"+dt.minute.toString();

}
static bool validateLogin(String email,String password){
  if(email.trim().isNotEmpty){
    return true;
  }
  if(password.trim().isNotEmpty ){
    return true;
  }
  return false;
}
static Widget attachmentWid(File attach,String url,String type,BuildContext context){
     
     if(getImageFormats(type)){
        return Container(
                            child: FlatButton(
                              child:  Material(
                                    child:attach==null? Image.network(url,
                                      width: 100.0,
                                      height: 100.0,
                                      fit: BoxFit.cover,
                                    ): Image.file(attach,
                                      width: 100.0,
                                      height: 100.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                              onPressed: () {
                                 OpenFile.open(url);
                               // Navigator.push(context,
                                   // MaterialPageRoute(builder: (context) => FullPhoto(url: document['content'])));
                              },
                              padding: EdgeInsets.all(0),
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          );
     }
     else{
           return Container(
                            child: FlatButton(
                              child:  Material(
                                    child:Text(type,
                                    style:TextStyle(
                                      fontSize: 15
                                    )),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    
                                  ),
                              onPressed: () {
                                 
                               // Navigator.push(context,
                                   // MaterialPageRoute(builder: (context) => FullPhoto(url: document['content'])));
                              },
                              padding: EdgeInsets.all(0),
                              
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          );
     }
  

}









  static String getRoleString(String role){
      switch(role){
        case "1":
          return "Admin";
        break;
        case "2":
         return "Faculty";
        break;
        case "3":
         return "Member";
        break;
        
      }
      return "";
  }
}