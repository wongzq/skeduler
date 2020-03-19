import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/user.dart';
import 'package:skeduler/screens/authentication/authenticate.dart';
import 'package:skeduler/screens/home/dashboard.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return user == null ? Authentication() : Dashboard();
  }
}
