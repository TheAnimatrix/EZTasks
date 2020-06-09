import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

getLogo(context,{bool padding=true}) {
    return Padding(
      padding: (padding)?EdgeInsets.fromLTRB(40, 0, 0, 0):EdgeInsets.zero,
      child: RichText(
        text: TextSpan(
          text: '',
          style: TextStyle(
              fontFamily: 'PS',
              fontWeight: FontWeight.normal,
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width<600?12:18,
              decoration: TextDecoration.none),
          children: <TextSpan>[
            TextSpan(
                text: 'EZ',
                style: TextStyle(
                    fontFamily: 'PS',
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    fontSize:  MediaQuery.of(context).size.width<600?20:28,
                    decoration: TextDecoration.none)),
            TextSpan(
                text: "TASK",
                style: TextStyle(
                  fontFamily: 'PS',
                  fontWeight: FontWeight.w800,
                  color: RandomColor().randomColor(
                              colorHue:ColorHue.orange,colorSaturation: ColorSaturation.highSaturation),
                  fontSize:  MediaQuery.of(context).size.width<600?14:18,
                  decoration: TextDecoration.none,
                )),
          ],
        ),
      ),
    );
  }

  _inProgressList(taskList) {
    return ListView.builder(scrollDirection: Axis.horizontal,itemBuilder: (context,i)
    {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 150,
          height:200,
          child: Card(
            color: Colors.white12,
            child: Text("${taskList[i].task}"),
          ),
        ),
      );
    },itemCount: taskList.length,);
  }
