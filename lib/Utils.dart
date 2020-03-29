import 'dart:ui';

import 'package:flutter/material.dart';

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