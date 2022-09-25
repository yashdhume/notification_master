import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({Key? key}) : super(key: key);
  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  Future<UserCredential> _signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn(scopes: ['email']).signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> _updateToken() async {
    String? token =  await FirebaseMessaging.instance.getToken();
    if(token == null){
      throw Exception("Token invalid");
    }
    else{
      String userToken = await  FirebaseAuth.instance.currentUser!.getIdToken();
       http.post(  Uri.parse("https://yashdhume.com/api/addUserFCM"), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': userToken
      }, body: jsonEncode({'token': token}) ).then((_){
         print(userToken); print(token);return;}).catchError((e){throw Exception(e);});
    }
  }
  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: () async {
      try{
        await _signInWithGoogle();
        await _updateToken();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login Successful"))
        );
      }
      catch (e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()))
        );
      }
    }, icon: const Icon(FontAwesomeIcons.google));
  }
}
