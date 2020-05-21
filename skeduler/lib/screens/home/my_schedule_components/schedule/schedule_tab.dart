import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/screens/home/my_schedule_components/schedule/schedule_view.dart';

class ScheduleTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return groupStatus.group == null ? Container() : ScheduleView();
  }
}
