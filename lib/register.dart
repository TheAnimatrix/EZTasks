import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:tasks/helpers/pubfunctions.dart';

import 'auth/AuthService.dart';
import 'loading.dart';

class RegisterUserPage extends StatefulWidget {
  RegisterUserPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RegisterUserPageState createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  final _formkey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    AuthService _auth = AuthService();
    return ChangeNotifierProvider(
        create: (context) => _auth,
        child: Stack(
          children: <Widget>[ Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(76, 8, 76, 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: getLogo(context,padding: false)
                    ),
                    Form(
                        key: _formkey,
                        child: Column(children: [
                          Text(
                            "Email",
                            textAlign: TextAlign.left,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.red[100], width: 3),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.redAccent, width: 3),
                                    borderRadius: BorderRadius.circular(20),
                                  )),
                              onChanged: (val) {
                                setState(() {
                                  this.email = val;
                                });
                              },
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                return (val.isEmpty)
                                    ? "Please provide a valid email"
                                    : null;
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Password",
                            textAlign: TextAlign.left,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.red[100], width: 3),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.redAccent, width: 3),
                                    borderRadius: BorderRadius.circular(20),
                                  )),
                              obscureText: true,
                              validator: (val) {
                                return (val.length < 6)
                                    ? "Password should be > 6 characters"
                                    : null;
                              },
                              onChanged: (val) {
                                setState(() {
                                  this.password = val;
                                });
                              },
                            ),
                          )
                        ])),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Builder(builder: (context) {
                          AuthService _auth = Provider.of<AuthService>(context);
                          return RaisedButton(
                            elevation: 20,
                            onPressed: () async {
                              //sign in
                              print(this.email + " " + this.password);
                              if (_formkey.currentState.validate()) {
                                _auth.toggleLoading(true);
                                dynamic user =
                                    await _auth.register(email, password);
                                if (user != null && !(user is int)) {
                                  _auth.toggleLoading(false);
                                  print("" + user.toString());
                                } else {
                                  _auth.toggleLoading(false);
                                  final snackBar = SnackBar(
                                    content: Text("Error: ${_auth.errorText}"),
                                  );
                                  Scaffold.of(context).showSnackBar(snackBar);
                                  print("Registration failed");
                                }
                              } else {
                                print("Error form is problematic");
                              }
                            },
                            textColor: Colors.white,
                            color: Colors.redAccent,
                            child: Text("Register"),
                          );
                        }),
                        SizedBox(width: 20),
                        Builder(
                          builder: (BuildContext context) {
                            return RaisedButton(
                              elevation: 20,
                              onPressed: () async {
                                //sign in
                                print(this.email + " " + this.password);
                                if (_formkey.currentState.validate()) {
                                  _auth.toggleLoading(true);
                                  dynamic user =
                                      await _auth.signIn(email, password);
                                  if (user != null && !(user is int)) {
                                    print("" + user.toString());
                                  } else {
                                    _auth.toggleLoading(false);
                                    final snackBar = SnackBar(
                                      content:
                                          Text("Error: ${_auth.errorText}"),
                                    );
                                    Scaffold.of(context).showSnackBar(snackBar);
                                    print("Sign in failed");
                                  }
                                } else {
                                  print("Error form is problematic");
                                }
                              },
                              textColor: Colors.white,
                              color: Colors.amberAccent,
                              child: Text(
                                "Sign In",
                                style: TextStyle(color: Colors.black),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SignInButton(
                      Buttons.Google,
                      text: "Sign in with google",
                      onPressed: () async {
                        //sign in
                        _auth.toggleLoading(true);
                        var result = await _auth.registerWithGoogle();
                        if (result == null) _auth.toggleLoading(false);
                      },
                    ),
                  ],
                ),
              ),
            ),
            _auth.isLoading
                ? Loading()
                : SizedBox(
                    height: 0,
                    width: 0,
                  )
          ],
        ));
  }
}
