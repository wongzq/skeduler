import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/firestore/user.dart';
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
  // Future<bool> _onWillPopApp() async {
  //   return await showDialog(
  //         context: context,
  //         builder: (context) {
  //           return SimpleAlertDialog(
  //             context: context,
  //             contentDisplay: 'Do you want to exit Skeduler?',
  //             confirmDisplay: 'YES',
  //             cancelDisplay: 'NO',
  //             confirmFunction: () => Navigator.of(context).pop(true),
  //             cancelFunction: () => Navigator.of(context).pop(false),
  //           );
  //         },
  //       ) ??
  //       false;
  // }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthUser>(context);

    return user == null ? Authentication() : widget.widget;
    // return WillPopScope(
    //   onWillPop: Navigator.of(context).canPop() ? null : _onWillPopApp,
    //   child: user == null ? Authentication() : widget.widget,
    // );
  }
}
