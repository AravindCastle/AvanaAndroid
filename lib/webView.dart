import 'package:avana_academy/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

class WebAppPage extends StatefulWidget {
  @override
  _WebAppPageState createState() => _WebAppPageState();
}

class _WebAppPageState extends State<WebAppPage> {
  int _selectedIndex = 3;
  void _onItemTapped(int index) {
    Utils.bottomNavAction(index, context);
  }

  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(
          msg: "Location permission needed",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(
            msg: "Location permission needed",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      Fluttertoast.showToast(
          msg: "Location permission needed",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    setState(() {
      _locationPermissionGranted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    });
  }

  @override
  Widget build(BuildContext context) {
    String url =
        'https://avanasurgical.com/crm/login.html?username=${Utils.userEmail}&pass=${Utils.password}';
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 134, 131, 131),
                  Color.fromARGB(255, 54, 52, 52),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0, 1],
              ),
            ),
          ),
          leading: IconButton(
            icon: Utils.userProfilePic(Utils.userId, 14),
            onPressed: () {
              Utils.showUserPop(context);
            },
          ),
          title: Text("Avana App"),
        ),
        body: _locationPermissionGranted
            ? WebView(
                geolocationEnabled: true,
                initialUrl: url, // Replace with your web application URL
                javascriptMode:
                    JavascriptMode.unrestricted, // Enable JavaScript
              )
            : Text("Location permissin needed to proceed further"),
        bottomNavigationBar: BottomNavigationBar(
          items: Utils.bottomNavItem(),

          currentIndex: _selectedIndex,
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          //unselectedLabelStyle: TextStyle(color: Colors.grey),
          onTap: _onItemTapped,
        ));
  }
}
