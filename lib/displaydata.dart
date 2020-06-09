import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'auth/AuthService.dart';
import 'loading.dart';

class DisplayDataPage extends StatefulWidget {
  @override
  _DisplayDataPageState createState() => _DisplayDataPageState();
}

class _DisplayDataPageState extends State<DisplayDataPage> {
  AuthService service = AuthService();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  void copyToClipboard(String toClipboard) {
    ClipboardData data = new ClipboardData(text: toClipboard);
    Clipboard.setData(data);
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text('Text copied to clipboard.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder<IdTokenResult>(
          future: service.getCurrentUserToken(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Loading();
                break;
              case ConnectionState.done:
                return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      SelectableText("Token - Update 3"),
                      InkWell(
                        child: Text("${(snapshot.data.token)}"),
                        onTap: () {
                          copyToClipboard(snapshot.data.token);
                        },
                      ),
                      RaisedButton(
                        onPressed: () {
                          setState(() {});
                        },
                        child: Text("Expired? Refresh token"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          service.logoutCurrentUser();
                        },
                        child: Text("Sign out"),
                      )
                      // Text("Token Data"),
                      // Text("${snapshot")
                    ]);
                break;
              default:
                break;
            }
          }),
    );
  }
}
