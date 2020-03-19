import 'package:flutter/material.dart';
import 'package:skeduler/services/auth_service.dart';
import 'package:skeduler/shared/constants.dart';
import 'package:skeduler/shared/loading.dart';

class LogIn extends StatefulWidget {
  // properties
  final Function toggleView;

  // constructor
  LogIn({this.toggleView});

  // methods
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  // properties
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  String _email = '';
  String _password = '';
  String _error = '';

  double _buttonRadius = 5.0;

  // methods
  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 40.0,
              ),

              // Form: Log In
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20.0),

                    // Text Form Field: Email
                    Container(
                      height: 50.0,
                      child: TextFormField(
                        initialValue: _email,
                        decoration:
                            textInputDecoration.copyWith(hintText: 'Email'),
                      ),
                    ),
                    SizedBox(height: 20.0),

                    // Text Form Field: Password
                    Container(
                      height: 50.0,
                      child: TextFormField(
                        initialValue: _password,
                        decoration:
                            textInputDecoration.copyWith(hintText: 'Password'),
                      ),
                    ),
                    SizedBox(height: 20.0),

                    // RaisedButton: Log In
                    ButtonTheme(
                      height: 50.0,
                      minWidth: MediaQuery.of(context).size.width,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_buttonRadius),
                        ),
                        onPressed: () {
                          setState(() {
                            _buttonRadius == 5.0
                                ? _buttonRadius = 50.0
                                : _buttonRadius = 5.0;
                          });
                        },
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),

                    // // FlatButton: Switch to Sign Up
                    // ButtonTheme(
                    //   height: 50.0,
                    //   minWidth: MediaQuery.of(context).size.width,
                    //   child: FlatButton(
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(5.0),
                    //       side: BorderSide(color: Colors.black12)
                    //     ),
                    //     onPressed: () {},
                    //     color: Colors.white,
                    //     child: Text(
                    //       'Create an account',
                    //       style: TextStyle(
                    //         // color: Theme.of(context).primaryColor,
                    //         color: Colors.black38,
                    //         fontSize: 18.0,
                    //         fontWeight: FontWeight.w400,
                    //         letterSpacing: 1.5,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          );
  }
}
