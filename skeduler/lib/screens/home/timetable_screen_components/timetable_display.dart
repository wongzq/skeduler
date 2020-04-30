import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_grid.dart';
import 'package:skeduler/services/database_service.dart';

class TimetableDisplay extends StatefulWidget {
  final TimetableEditMode editMode;

  TimetableDisplay({
    Key key,
    this.editMode,
  }) : super(key: key);

  @override
  _TimetableDisplayState createState() => _TimetableDisplayState();
}

class _TimetableDisplayState extends State<TimetableDisplay> {
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return StreamBuilder<List<Member>>(
      stream: dbService.getGroupMembers(groupStatus.group.docId),
      builder: (context, snapshot) {
        List<Member> members = snapshot != null ? snapshot.data ?? [] : [];
        
        MembersStatus membersStatus = MembersStatus(members: members);

        return ChangeNotifierProvider<MembersStatus>.value(
          value: membersStatus,
          child: ChangeNotifierProvider<TimetableEditMode>.value(
            value: widget.editMode,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: TimetableGrid(),
            ),
          ),
        );
      },
    );
  }
}
