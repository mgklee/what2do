import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
    "358946647934-bmir594d3nbdj7mcgradov4ogrd74p1b.apps.googleusercontent.com",
    scopes: [
      'email', // Access the user's email
      'https://www.googleapis.com/auth/userinfo.profile', // Access profile info
    ],
  );

  Future<void> _handleGoogleSignIn() async {
    print('Starting Google Sign-In...');
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        print('Logged in as: ${account.displayName}');
        print('Email: ${account.email}');
      } else {
        print('Sign-In aborted by user.');
      }
    } catch (error) {
      print('Error during Google Sign-In: $error');
    }
    print('Google Sign-In process completed.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleGoogleSignIn,
          child: const Text('Log in with Google'),
        ),
      ),
    );
  }
}
