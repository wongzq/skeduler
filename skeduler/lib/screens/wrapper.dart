import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/user.dart';
import 'package:skeduler/screens/authentication/authentication.dart';
import 'package:skeduler/screens/home/home.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthUser>(context);

    return user == null ? Authentication() : Home();
  }
}
