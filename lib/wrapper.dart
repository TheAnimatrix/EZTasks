import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks/register.dart';
import 'package:tasks/screens/tasksPage.dart';
import 'package:tasks/screens/tasksPageLogin.dart';
import 'package:tasks/user.dart';

import 'displaydata.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    print("hello $user x");
    if (user == null) {
      return TasksPageLogin();
    } else{
      return TasksPage();
    }
  }
}
