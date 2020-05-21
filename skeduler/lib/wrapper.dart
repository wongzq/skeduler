import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/firestore/user.dart';
import 'package:skeduler/screens/authentication/authentication.dart';
import 'package:skeduler/shared/simple_widgets.dart';

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
            return SimpleAlertDialog(
              context: context,
              contentDisplay: 'Do you want to exit Skeduler?',
              confirmDisplay: 'YES',
              cancelDisplay: 'NO',
              confirmFunction: () => Navigator.of(context).pop(true),
              cancelFunction: () => Navigator.of(context).pop(false),
            );
          },
        ) ??
        false;
  }

  // Map of screens
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthUser>(context);

    return WillPopScope(
      onWillPop: Navigator.of(context).canPop() ? null : _onWillPopApp,
      child: user == null ? Authentication() : widget.widget,
    );
  }
}
