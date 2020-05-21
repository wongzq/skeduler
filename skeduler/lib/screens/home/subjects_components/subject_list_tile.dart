import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/option_enums.dart';
import 'package:skeduler/models/auxiliary/route_arguments.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/models/firestore/subject.dart';
import 'package:skeduler/services/database_service.dart';


class SubjectListTile extends StatelessWidget {
  final Subject subject;

  const SubjectListTile({
    Key key,
    @required this.subject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.class_),
          title: Text(subject.display ?? ''),
          subtitle: Text(subject.name ?? ''),
          trailing: groupStatus.me.role == MemberRole.owner ||
                  groupStatus.me.role == MemberRole.admin
              ? PopupMenuButton<SubjectOption>(
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem<SubjectOption>(
                        value: SubjectOption.edit,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.edit),
                            SizedBox(width: 10.0),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem<SubjectOption>(
                        value: SubjectOption.remove,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.delete),
                            SizedBox(width: 10.0),
                            Text('Remove'),
                          ],
                        ),
                      ),
                    ];
                  },
                  onSelected: (option) {
                    switch (option) {
                      case SubjectOption.edit:
                        Navigator.of(context).pushNamed(
                          '/subjects/editSubject',
                          arguments: RouteArgsEditSubject(subject: subject),
                        );
                        break;

                      case SubjectOption.remove:
                        dbService.removeGroupSubject(
                            groupStatus.group.docId, subject);
                        break;
                    }
                  },
                )
              : null,
        ),
        Divider(height: 1.0),
      ],
    );
  }
}
