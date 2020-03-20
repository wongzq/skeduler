import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skeduler/screens/authentication/authentication.dart';
import 'package:skeduler/services/auth_service.dart';
import 'package:skeduler/shared/text_input_decoration.dart';

class SignUp extends StatefulWidget {
  // properties
  final Function toggleView;

  // constructor
  SignUp({this.toggleView});

  // methods
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // properties
  final AuthService _authService = AuthService();
  final _formKeyName = GlobalKey<FormState>();
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();

  FocusScopeNode currentFocus;

  bool _nameValid = false;
  bool _emailValid = false;
  bool _passwordValid = false;

  String _name = '';
  String _email = '';
  String _password = '';
  String _error = '';

  // methods
  @override
  Widget build(BuildContext context) {
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
            SizedBox(
              height: 80.0,
              child: Form(
                key: _formKeyName,
                child: TextFormField(
                  inputFormatters: [
                    new WhitelistingTextInputFormatter(RegExp(r"^[a-zA-Z,.'-]{1}[a-zA-Z ,.'-]*$"))
                  ],
                  initialValue: null,
                  style: TextStyle(fontSize: 14.0),
                  decoration: _nameValid
                      ? textInputDecorationValid(context)
                      : textInputDecoration(context).copyWith(hintText: 'Name'),
                  onChanged: (val) {
                    _name = val;
                    if (val.isNotEmpty) {
                      _formKeyName.currentState.validate();
                    } else {
                      setState(() {
                        _nameValid = false;
                        _formKeyName.currentState.reset();
                      });
                    }
                  },
                  validator: (val) {
                    RegExp regExp = RegExp(r"([a-zA-Z]+.*$)");
                    if (regExp.hasMatch(_name)) {
                      setState(() {
                        _nameValid = true;
                      });
                      return null;
                    } else {
                      setState(() {
                        _nameValid = false;
                      });
                      return 'Name must contain letters';
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20.0),

            // Form: Email
            SizedBox(
              height: 80.0,
              child: Form(
                key: _formKeyEmail,
                child: TextFormField(
                  initialValue: null,
                  style: TextStyle(fontSize: 14.0),
                  decoration: _emailValid
                      ? textInputDecorationValid(context)
                      : textInputDecoration(context)
                          .copyWith(hintText: 'Email'),
                  onChanged: (val) {
                    _email = val;
                    if (val.isNotEmpty) {
                      _formKeyEmail.currentState.validate();
                    } else {
                      setState(() {
                        _emailValid = false;
                        _formKeyEmail.currentState.reset();
                      });
                    }
                  },
                  validator: (val) {
                    RegExp regExp = RegExp(
                        r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)");
                    if (regExp.hasMatch(_email)) {
                      setState(() {
                        _emailValid = true;
                      });
                      return null;
                    } else {
                      setState(() {
                        _emailValid = false;
                      });
                      return 'Invalid email address';
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20.0),

            // Form: Password
            SizedBox(
              height: 80.0,
              child: Form(
                key: _formKeyPassword,
                child: TextFormField(
                  obscureText: true,
                  initialValue: null,
                  style: TextStyle(fontSize: 14.0),
                  decoration: _passwordValid
                      ? textInputDecorationValid(context)
                      : textInputDecoration(context)
                          .copyWith(hintText: 'Password'),
                  onChanged: (val) {
                    _password = val;
                    if (val.isNotEmpty) {
                      _formKeyPassword.currentState.validate();
                    } else {
                      setState(() {
                        _passwordValid = false;
                        _formKeyPassword.currentState.reset();
                      });
                    }
                  },
                  validator: (val) {
                    if (_password.length >= 8) {
                      RegExp regExp =
                          RegExp(r'^(?=.*?[a-zA-Z])(?=.*?[0-9]).{8,128}$');
                      if (regExp.hasMatch(_password)) {
                        setState(() {
                          _passwordValid = true;
                        });
                        return null;
                      } else {
                        setState(() {
                          _passwordValid = false;
                        });
                        return 'Password must contain letters and numbers';
                      }
                    } else if (_password.length > 128) {
                      setState(() {
                        _passwordValid = false;
                      });
                      return 'Password myst be less than 128 characters';
                    } else {
                      setState(() {
                        _passwordValid = false;
                      });
                      return 'Password must contain 8 characters or more';
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20.0),

            // RaisedButton: Log In
            ButtonTheme(
              height: 50.0,
              minWidth: MediaQuery.of(context).size.width,
              child: FlatButton(
                color: Theme.of(context).primaryColor,
                disabledColor: Colors.grey[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    _emailValid && _passwordValid ? 50.0 : 5.0,
                  ),
                ),

                // Function: onPressed:
                // enable when email and password are valid
                // disable when email and password are invalid
                onPressed: _nameValid && _emailValid && _passwordValid
                    ? () async {
                        setState(() {
                          _name = _name.trim();
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
                                // log in with email and password
                                dynamic authResult = await _authService
                                    .signUpWithEmailAndPassword(
                                        _email, _password);

                                if (authResult == null) {
                                  setState(() {
                                    Authentication.of(context).setState(() {
                                      Authentication.of(context).loading =
                                          false;
                                    });
                                    _error =
                                        'Please provide a valid email';
                                    currentFocus = FocusScope.of(context);
                                    if (!currentFocus.hasPrimaryFocus) {
                                      currentFocus.unfocus();
                                    }
                                  });
                                } else {
                                  // log in account and go to dashboard
                                }
                              }
                            } on SocketException catch (_) {
                              setState(() {
                                Authentication.of(context).setState(() {
                                  Authentication.of(context).loading = false;
                                });
                                _error =
                                    'Please check your internet connection';
                                currentFocus = FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
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
                    color: _emailValid && _passwordValid
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
