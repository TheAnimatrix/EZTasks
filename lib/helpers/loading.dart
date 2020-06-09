import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {

  Color color;
  Loading({Key key, this.color}): super(key:key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: (color==null)?Colors.black54:color,
      child:Center(child: SpinKitChasingDots(
        color: (color==null)?Colors.white:Colors.black,
        size: 50.0,
      ),)
    );
  }
}

class LogOutLoading extends StatelessWidget {

  Color color;
  LogOutLoading({Key key, this.color}): super(key:key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: (color==null)?Colors.black54:color,
      child:Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SpinKitChasingDots(
            color: (color==null)?Colors.white:Colors.black,
            size: 50.0,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("Signing out",style:TextStyle(color:Colors.white,fontSize:20,fontWeight: FontWeight.w800,decoration: TextDecoration.none)),
          )
        ],
      ),)
    );
  }
}