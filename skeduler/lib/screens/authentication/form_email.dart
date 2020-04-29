import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/auth_info.dart';
import 'package:skeduler/shared/ui_settings.dart';

class FormEmail extends StatefulWidget {
  // properties
  final GlobalKey<FormState> formKeyEmail;
  final Function refresh;

  // constructors
  FormEmail({this.formKeyEmail, this.refresh});

  // methods
  @override
  _FormEmailState createState() => _FormEmailState();
}

class _FormEmailState extends State<FormEmail> {
  @override
  Widget build(BuildContext context) {
    // Provider for Authentication Info
    final AuthInfo authInfo = Provider.of<AuthInfo>(context);

    return SizedBox(
      height: 80.0,
      child: Form(
        key: widget.formKeyEmail,
        child: TextFormField(
          initialValue: null,
          style: TextStyle(color: Colors.black, fontSize: 14.0),
          decoration: authInfo.emailValid
              ? authTextInputDecorationValid
              : authTextInputDecoration.copyWith(
                  hintText: 'Email',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                ),
          onChanged: (val) {
            authInfo.email = val;
            if (val.isNotEmpty) {
              widget.formKeyEmail.currentState.validate();
            } else {
              authInfo.emailValid = false;
              widget.formKeyEmail.currentState.reset();
              widget.refresh();
            }
          },
          validator: (val) {
            RegExp regExp =
                RegExp(r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)");
            if (regExp.hasMatch(authInfo.email)) {
              authInfo.emailValid = true;
              widget.refresh();
              return null;
            } else {
              authInfo.emailValid = false;
              widget.refresh();
              return 'Invalid email address';
            }
          },
        ),
      ),
    );
  }
}
