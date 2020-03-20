import 'package:flutter/material.dart';
import 'package:skeduler/screens/authentication/log_in.dart';
import 'package:skeduler/screens/authentication/sign_up.dart';
import 'package:skeduler/shared/loading.dart';

class Authentication extends StatefulWidget {
  static _AuthenticationState of(BuildContext context) =>
      context.findAncestorStateOfType<_AuthenticationState>();

  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  bool _showLogIn = true;
  bool loading = false;

  // switch between Log In and Sign Up screen
  void toggleView() {
    setState(() {
      _showLogIn = !_showLogIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        DefaultTabController(
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

              // Tab Bar
              bottom: TabBar(
                indicatorColor: Colors.white,
                tabs: <Widget>[
                  // Tab 1: Log in
                  Tab(
                    text: null,
                    child: Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  // Tab 2: Sign up
                  Tab(
                    text: null,
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar View
            body: TabBarView(
              children: <Widget>[
                LogIn(),
                SignUp(),
              ],
            ),
          ),
        ),

        // Loading: display
        Visibility(
          child: loading ? Loading() : Container(),
        )
      ],
    );
  }
}
