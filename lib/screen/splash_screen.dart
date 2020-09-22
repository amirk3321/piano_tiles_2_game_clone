import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piano_tiles/screen/home_screen.dart';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    Timer(Duration(seconds: 10),(){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeScreen()), (route) => false);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 450,
              width: 350,
              child: Image.asset("assets/logo.png"),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                Icon(Icons.headset_mic,size: 40,color: Colors.blue,),
                Text("Headphone recommended",style: TextStyle(color: Colors.blue,fontSize: 22),),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
