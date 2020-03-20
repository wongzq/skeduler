import 'package:flutter/material.dart';
import 'package:skeduler/services/auth_service.dart';

class Dashboard extends StatelessWidget {
  // properties
  final AuthService _authService = AuthService();

  // methods
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        child: RaisedButton(
          onPressed: () {
            _authService.logOut();
          },
        ),
      ),
    );
  }
}
