import 'package:avana_academy/main.dart';

class userModel extends AvanaHome{

  static String userName;
  static String role;
  static String email;
  static String memberShipDate;

userModel(String userName,int role , String email, String memberShipDate){
    userName=userName;
    role=role;
    email=email;
    memberShipDate=memberShipDate;

}
}