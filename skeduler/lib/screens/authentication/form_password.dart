import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auth_info.dart';
import 'package:skeduler/shared/ui_settings.dart';

class FormPassword extends StatefulWidget {
  // properties
  final GlobalKey<FormState> formKeyPassword;
  final Function refresh;

  // constructor
  FormPassword({this.formKeyPassword, this.refresh});

  // methods
  @override
  _FormPasswordState createState() => _FormPasswordState();
}

class _FormPasswordState extends State<FormPassword> {
  @override
  Widget build(BuildContext context) {
    // Provider for Authentication Info
    final AuthInfo authInfo = Provider.of<AuthInfo>(context);

    return SizedBox(
      height: 80.0,
      child: Form(
        key: widget.formKeyPassword,
        child: TextFormField(
          obscureText: true,
          initialValue: null,
          style: TextStyle(color: Colors.black, fontSize: 14.0),
          decoration: Provider.of<AuthInfo>(context).passwordValid
              ? textInputDecorationValid
              : textInputDecoration.copyWith(
                  hintText: 'Password',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                ),
          onChanged: (val) {
            authInfo.password = val;
            if (val.isNotEmpty) {
              widget.formKeyPassword.currentState.validate();
            } else {
              authInfo.passwordValid = false;
              widget.formKeyPassword.currentState.reset();
              widget.refresh();
            }
          },
          validator: (val) {
            if (authInfo.password.length >= 8) {
              RegExp regExp = RegExp(r'^(?=.*?[a-zA-Z])(?=.*?[0-9]).{8,128}$');
              if (regExp.hasMatch(authInfo.password)) {
                authInfo.passwordValid = true;
                widget.refresh();
                return null;
              } else {
                authInfo.passwordValid = false;
                widget.refresh();
                return 'Password must contain letters and numbers';
              }
            } else if (authInfo.password.length > 128) {
              authInfo.passwordValid = false;
              widget.refresh();
              return 'Password myst be less than 128 characters';
            } else {
              authInfo.passwordValid = false;
              widget.refresh();
              return 'Password must contain 8 characters or more';
            }
          },
        ),
      ),
    );
  }
}
