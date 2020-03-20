import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auth_info.dart';
import 'package:skeduler/shared/text_input_decoration.dart';

class FormEmail extends StatefulWidget {
  // properties
  final GlobalKey<FormState> formKeyEmail;
  final Function refresh;

  // constructor
  FormEmail({this.formKeyEmail, this.refresh});

  // methods
  @override
  _FormEmailState createState() => _FormEmailState();
}

class _FormEmailState extends State<FormEmail> {
  @override
  Widget build(BuildContext context) {
    // Provider for Authentication Info
    final AuthInfo authInfo =
        Provider.of<AuthInfo>(context);

    return SizedBox(
      height: 80.0,
      child: Form(
        key: widget.formKeyEmail,
        child: TextFormField(
          initialValue: null,
          style: TextStyle(fontSize: 14.0),
          decoration: authInfo.emailValid
              ? textInputDecorationValid(context)
              : textInputDecoration(context).copyWith(hintText: 'Email'),
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
