import 'package:flutter/material.dart';
import 'package:skeduler/screens/authentication/log_in.dart';
import 'package:skeduler/screens/authentication/sign_up.dart';

class Authentication extends StatefulWidget {
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  bool _showLogIn = true;

  // switch between Log In and Sign Up screen
  void toggleView() {
    setState(() {
      _showLogIn = !_showLogIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text(
            'Skeduler',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w400,
              letterSpacing: 2.0,
            ),
          ),
          backgroundColor: Colors.black,
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: <Widget>[
              Tab(text: 'Log in'),
              Tab(text: 'Sign up'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            LogIn(),
            SignUp(),
          ],
        ),
      ),
    );
  }
}
