import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tasks/helpers/pubfunctions.dart';

import '../register.dart';

class TasksPageLogin extends StatefulWidget {
  @override
  _TasksPageLoginState createState() => _TasksPageLoginState();
}

class _TasksPageLoginState extends State<TasksPageLogin> {
  ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black.withAlpha(230),
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            getNavBar(),
            Transform.translate(
              offset: Offset(0, navBarHeight + 10),
              child: placeholderDataPage(),
            ),
            signInPage()
          ],
        ));
  }

  getDynamicWidth(ctx) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 1;
    } else if (width < 1000) {
      return 0.6;
    } else if (width < 1200) {
      return 0.5;
    } else {
      return 0.4;
    }
  }

  signInPage() {
    return Container(
      color: Colors.white10,
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: getDynamicWidth(context),
              child: Container(
                color: Color(0xFF151515),
                child: RegisterUserPage(),
              ),
            ),
          )),
    );
  }

  placeholderDataPage() {
    return SingleChildScrollView(
      child: FractionallySizedBox(
        widthFactor: 0.6,
        child: SingleChildScrollView(
          controller: _controller,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Your Tasks for Today"),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  height: 150,
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: placeholderList()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("All Tasks", style: TextStyle(fontSize: 22)),
              ),
              ListView(
                  shrinkWrap: true,
                  controller: _controller,
                  children: placeholderList2())
            ],
          ),
        ),
      ),
    );
  }

  placeholderList2() {
    var arr = <Widget>[];
    for (int i = 0; i < 15; i++) {
      arr.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 100,
          child: Card(
            color: Colors.white12,
          ),
        ),
      ));
    }
    return arr;
  }

  placeholderList() {
    var arr = <Widget>[];
    for (int i = 0; i < 15; i++) {
      arr.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 150,
          child: Card(
            color: Colors.white12,
          ),
        ),
      ));
    }
    return arr;
  }

  double navBarHeight = 70;

  getNavBar() {
    return Container(
      color: Colors.black.withAlpha(110),
      height: navBarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: getLogo(context),
            fit: FlexFit.loose,
            flex: 2,
          ),
          Spacer(flex: 2),
          Flexible(
            flex: 3,
            child: Card(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: TextField(
                decoration: InputDecoration(
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none),
              ),
            ),
            fit: FlexFit.loose,
          ),
          Spacer(flex: 1),
          Flexible(
            flex: 2,
            fit: FlexFit.loose,
            child: FlatButton(
                child: Row(
                  children: [
                    Icon(Icons.add_circle),
                    Text(
                      "  Add Task",
                      style: TextStyle(fontSize: 18),
                    ),
                    Spacer(flex: 1),
                  ],
                ),
                onPressed: () {}),
          )
        ],
      ),
    );
  }
}
