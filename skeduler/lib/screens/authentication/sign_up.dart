import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/screens/authentication/authentication.dart';
import 'package:skeduler/screens/authentication/authentication_info.dart';
import 'package:skeduler/screens/authentication/form_email.dart';
import 'package:skeduler/screens/authentication/form_name.dart';
import 'package:skeduler/screens/authentication/form_password.dart';
import 'package:skeduler/services/auth_service.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // properties
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKeyName = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyEmail = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyPassword = GlobalKey<FormState>();

  FocusScopeNode currentFocus;
  String _error = '';

  // methods
  // callback for setState()
  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    // get Authentication Info using provider
    final AuthInfo authInfo =
        Provider.of<AuthInfo>(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 40.0,
          horizontal: 40.0,
        ),
        child: Column(
          children: <Widget>[
            // Form: Name
            FormName(formKeyName: _formKeyName, refresh: refresh),
            SizedBox(height: 20.0),

            // Form: Email
            FormEmail(formKeyEmail: _formKeyEmail, refresh: refresh),
            SizedBox(height: 20.0),

            // Form: Password
            FormPassword(formKeyPassword: _formKeyPassword, refresh: refresh),
            SizedBox(height: 20.0),

            // RaisedButton: Sign Up
            ButtonTheme(
              height: 50.0,
              minWidth: MediaQuery.of(context).size.width,
              child: FlatButton(
                color: Theme.of(context).primaryColor,
                disabledColor: Colors.grey[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    authInfo.emailValid && authInfo.passwordValid ? 50.0 : 5.0,
                  ),
                ),

                // Function: onPressed:
                // enable when email and password are valid
                // disable when email and password are invalid
                onPressed: authInfo.nameValid &&
                        authInfo.emailValid &&
                        authInfo.passwordValid
                    ? () async {
                        setState(() {
                          authInfo.name = authInfo.name.trim();
                        });

                        if (_formKeyEmail.currentState.validate() &&
                            _formKeyPassword.currentState.validate()) {
                          setState(() async {
                            Authentication.of(context).setState(() {
                              Authentication.of(context).loading = true;
                            });

                            // check internet connection
                            try {
                              final result =
                                  await InternetAddress.lookup('google.com');
                              if (result.isNotEmpty &&
                                  result[0].rawAddress.isNotEmpty) {
                                // sign up with email and password
                                dynamic authResult = await _authService
                                    .signUpWithEmailAndPassword(
                                  authInfo.email,
                                  authInfo.password,
                                  authInfo.name,
                                );

                                if (authResult == null) {
                                  // display error message
                                  setState(() {
                                    _error =
                                        'Please check your email or password';
                                    print(authInfo.emailValid);
                                    print(authInfo.passwordValid);
                                  });

                                  // unfocus text form field
                                  currentFocus = FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }

                                  // remove loading screen
                                  Authentication.of(context).setState(() {
                                    Authentication.of(context).loading = false;
                                  });
                                } else {
                                  // log in account and go to dashboard
                                }
                              }
                            } on SocketException catch (_) {
                              setState(() {
                                _error =
                                    'Please check your internet connection';
                              });

                              // unfocus text form field
                              currentFocus = FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }

                              // remove loading screen
                              Authentication.of(context).setState(() {
                                Authentication.of(context).loading = false;
                              });
                            }
                          });
                        }
                      }
                    : null,

                // Text: Log In
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    color: authInfo.emailValid && authInfo.passwordValid
                        ? Colors.white
                        : Colors.grey[200],
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),

            // Text: Error message
            Text(
              _error,
              style: TextStyle(
                color: Colors.red,
                fontSize: 14.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}
