import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auth_info.dart';
import 'package:skeduler/shared/ui_settings.dart';

class FormName extends StatefulWidget {
  // properties
  final GlobalKey<FormState> formKeyName;
  final Function refresh;

  // constructor
  FormName({this.formKeyName, this.refresh});

  // methods
  @override
  _FormNameState createState() => _FormNameState();
}

class _FormNameState extends State<FormName> {
  @override
  Widget build(BuildContext context) {
    // Provider for Authentication Info
    final AuthInfo authInfo = Provider.of<AuthInfo>(context);

    return SizedBox(
      height: 80.0,
      child: Form(
        key: widget.formKeyName,
        child: TextFormField(
          inputFormatters: [
            WhitelistingTextInputFormatter(
                RegExp(r"^[a-zA-Z,.'-][a-zA-Z ,.'-]*"))
          ],
          initialValue: null,
          style: TextStyle(fontSize: 14.0),
          decoration: authInfo.nameValid
              ? textInputDecorationValid(context)
              : textInputDecoration(context).copyWith(hintText: 'Name'),
          onChanged: (val) {
            authInfo.name = val;
            if (val.isNotEmpty) {
              widget.formKeyName.currentState.validate();
            } else {
              authInfo.nameValid = false;
              widget.formKeyName.currentState.reset();
              widget.refresh();
            }
          },
          validator: (val) {
            RegExp regExp = RegExp(r"([a-zA-Z]+.*$)");
            if (regExp.hasMatch(authInfo.name)) {
              authInfo.nameValid = true;
              widget.refresh();
              return null;
            } else {
              authInfo.nameValid = false;
              widget.refresh();
              return 'Name must contain letters';
            }
          },
        ),
      ),
    );
  }
}
