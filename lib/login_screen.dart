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
  );

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        print('Logged in as: ${account.displayName}');
        // Proceed with your app logic (e.g., navigate to the home screen)
      }
    } catch (error) {
      print('Error during Google Sign-In: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleGoogleSignIn,
          child: const Text('Log in with Google'),
        ),
      ),
    );
  }
}
