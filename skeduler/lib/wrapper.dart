import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/user.dart';
import 'package:skeduler/screens/authentication/authentication.dart';

Widget wrapWidget(Widget widget) {
  return Wrapper(widget);
}

class Wrapper extends StatefulWidget {
  final Widget widget;

  const Wrapper(this.widget);

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  Future<bool> _onWillPopApp() async {
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
          },
        ) ??
        false;
  }

  /// Map of screens
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthUser>(context);

    return WillPopScope(
      onWillPop: Navigator.of(context).canPop() ? null : _onWillPopApp,
      child: user == null ? Authentication() : widget.widget,
    );
  }
}
