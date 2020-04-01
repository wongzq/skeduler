import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/user.dart';
import 'package:skeduler/screens/authentication/authentication.dart';
import 'package:skeduler/screens/home/home.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  Future<bool> _onWillPop() async {
    return await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text('Do you want to exit Skeduler?'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('NO'),
                  ),
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('YES'),
                  )
                ],
              );
            }) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthUser>(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: user == null ? Authentication() : Home(),
    );
  }
}
