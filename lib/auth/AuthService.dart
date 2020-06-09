
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:tasks/user.dart';
/*
USER_REQUIRED?? and 1 second of null screen
*/

/*
Error list
-----------
119 - Wrong password
120 - User not found
*/

class AuthService with ChangeNotifier {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  User currentUser;
  String errorText = "";

  //TODO: fix signout pulling back to verify page despite multiple checks 
  //fixed the bug was that the "Stream was being rebuilt on each change."

  void printWrapped(String text) {
    final pattern = new RegExp('.{1,400}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  Future getIdToken() async {
    await _auth.currentUser()
      ..getIdToken(refresh: true).then((idToken) async {
        var verifyUrl =
            "https://2xsjhdvjcc.execute-api.ap-south-1.amazonaws.com/Prod/verifyId";
        // var verifyUrl = "http://192.168.169.177:3000/verifyId";
        var body = '{"OID":"${idToken.token}"}';
        var response = await http.post(verifyUrl, body: body);
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      });
  }

  Future<String> getValidToken() async {
    FirebaseUser currentUser = await _auth.currentUser();
    await currentUser.reload();
    String token = "";
    await currentUser.getIdToken().then((idToken) async {
      print("interceptor token generated");
      token = idToken.token;
    }).catchError((err) {
      print("error no token interceptor");
      token = "";
    });
    return token;
  }

  Future<bool> isCurrentUserVerified() async {
    FirebaseUser user = await _auth.currentUser();
    if (user == null) return false;
    await user.reload();
    print(user.toString());
    return user.isEmailVerified;
  }

  Future<bool> sendVerificationLink() async {
    FirebaseUser user = await _auth.currentUser();
    if (user == null) return false;
    try {
      user.sendEmailVerification();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void setSnackbarText(String text) {
    errorText = text;
    notifyListeners();
  }

  void toggleLoading(bool e) {
    isLoading = e;
    notifyListeners();
  }

  Future<IdTokenResult> getCurrentUserToken() async
  {
    FirebaseUser user = await _auth.currentUser();
    return user.getIdToken(refresh:true);
  }

  void get getUser async {
    FirebaseUser user = await _auth.currentUser();
    if (user != null)
      currentUser = User(
          uid: user.uid,
          isEmailVerified: user.isEmailVerified,
          email: user.email);
    notifyListeners();
  }

  Future<dynamic> signIn(String email, String password) async {
    email = email.trim();
    try {
      FirebaseUser user = (await _auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      print("" + user.displayName);
    } catch (e) {
      print("yo");
      print(e);
      if (e.toString().contains("ERROR_WRONG_PASSWORD"))
        setSnackbarText("Invalid username/password combination");
      else if (e.toString().contains("ERROR_USER_NOT_FOUND"))
        setSnackbarText("User not found");
      else if (e.toString().contains("ERROR_INVALID_EMAIL"))
        setSnackbarText("Your email address is improperly formatted");
      else
        setSnackbarText("${e.toString()}");
      return null;
    }
  }

  Future<dynamic> register(String email, String password) async {
    try {
      FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
              email: email.trim(), password: password))
          .user;
      print("" + user.toString());

      return _getUserFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      if (e.toString().contains("ERROR_EMAIL_ALREADY_IN_USE"))
        setSnackbarText("This email address is already in use");
      else if (e.toString().contains("ERROR_INVALID_EMAIL"))
        setSnackbarText("Your email address is improperly formatted");
      else
        setSnackbarText("${e.toString()}");
      return null;
    }
  }

  Future logoutCurrentUser() async {
    if ((await _auth.currentUser()) == null) return null;
    try {
      await _auth.signOut();
      print("Signed out user Successfully");
      currentUser = null;
    } catch (e) {
      print(e.toString());
      print("Signout Unsuccessful");
    }
  }

  User _getUserFromFirebaseUser(FirebaseUser user) {
    return (user != null)
        ? User(
            uid: user.uid,
            isEmailVerified: user.isEmailVerified,
            email: user.email,)
        : null;
  }

  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_getUserFromFirebaseUser);
  }

  Future<FirebaseUser> registerWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    try {
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      print("signed in " + user.toString());

      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
