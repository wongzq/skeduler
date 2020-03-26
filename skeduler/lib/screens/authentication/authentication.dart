import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auth_info.dart';
import 'package:skeduler/models/theme_changer.dart';
import 'package:skeduler/screens/authentication/log_in.dart';
import 'package:skeduler/screens/authentication/sign_up.dart';
import 'package:skeduler/shared/loading.dart';
import 'package:skeduler/shared/methods.dart';

class Authentication extends StatefulWidget {
  static _AuthenticationState of(BuildContext context) =>
      context.findAncestorStateOfType<_AuthenticationState>();

  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication>
    with TickerProviderStateMixin {
  // properties
  FocusScopeNode currentFocus;

  AuthInfo authInfoLogIn = AuthInfo();
  AuthInfo authInfoSignUp = AuthInfo();
  LogIn _logIn = LogIn();
  SignUp _signUp = SignUp();

  TabController _tabController;
  int _tabs = 2;

  bool loading = false;

  // methods
  void _switchTab() {
    setState(() {
      _logIn = LogIn();
      _signUp = SignUp();
      authInfoLogIn = AuthInfo();
      authInfoSignUp = AuthInfo();
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabs);

    // handle switch tab behaviour
    _tabController.addListener(_switchTab);
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
        GestureDetector(
          onTap: () => unfocus(context),
          child: Scaffold(
            backgroundColor: Colors.grey[200],
            appBar: AppBar(
              title: Text(
                'Skeduler',
                style: TextStyle(
                  color: Colors.white,
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
                        color: Colors.white,
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
                        color: Colors.white,
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
        ),

        // Loading: display
        Visibility(
          child: loading ? Loading() : Container(),
        )
      ],
    );
  }
}
