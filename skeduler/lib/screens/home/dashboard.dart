import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/user.dart';
import 'package:skeduler/services/auth_service.dart';
import 'package:skeduler/services/database_service.dart';

class Dashboard extends StatelessWidget {
  // properties
  final AuthService _authService = AuthService();

  // methods
  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);
    final DatabaseService _databaseService = DatabaseService(uid: user.uid);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        child: Center(
          child: StreamBuilder<UserData>(
            stream: _databaseService.userData,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              UserData userData = snapshot.data ?? null;
              return RaisedButton(
                child: Text(userData != null ? userData.name : ''),
                onPressed: () {
                  _authService.logOut();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
