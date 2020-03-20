import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/screens/authentication/log_in.dart';
import 'package:skeduler/screens/authentication/sign_up.dart';
import 'package:skeduler/shared/loading.dart';

import 'authentication_info.dart';

class Authentication extends StatefulWidget {
  static _AuthenticationState of(BuildContext context) =>
      context.findAncestorStateOfType<_AuthenticationState>();

  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication>
    with TickerProviderStateMixin {
  // properties
  AuthInfo authInfoLogIn = AuthInfo();
  AuthInfo authInfoSignUp = AuthInfo();
  LogIn _logIn = LogIn();
  SignUp _signUp = SignUp();

  TabController _tabController;
  bool _showLogIn = true;
  bool loading = false;

  // methods
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(() {
      setState(() {
        _showLogIn = !_showLogIn;
        if (_showLogIn) {
          authInfoLogIn = AuthInfo();
          _logIn = LogIn();
        } else {
          authInfoSignUp = AuthInfo();
          _signUp = SignUp();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
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
              controller: _tabController,
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
            controller: _tabController,
            children: <Widget>[
              Provider<AuthInfo>.value(
                child: _logIn,
                value: authInfoLogIn,
              ),
              Provider<AuthInfo>.value(
                child: _signUp,
                value: authInfoSignUp,
              ),
            ],
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
