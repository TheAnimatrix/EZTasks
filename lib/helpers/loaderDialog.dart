
import 'package:flutter/material.dart';

import 'loading.dart';

class LoaderDialog extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Loading(), onWillPop: () async=>false,);
  }
}