import 'package:flutter/material.dart';
import 'package:skeduler/shared/ui_settings.dart';

class CreateGroup extends StatefulWidget {
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create group',
          style: appBarTitleTextStyle,
        ),
      ),
      body: Column(
        // Group Name
        // Group Color
        
        // Group Description: optional
        // 

      ),
    );
  }
}
