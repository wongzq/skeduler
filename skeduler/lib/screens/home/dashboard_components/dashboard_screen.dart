import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/custom_enums.dart';
import 'package:skeduler/navigation/route_arguments.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/navigation/home_drawer.dart';
import 'package:skeduler/screens/home/dashboard_components/group_card.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class DashboardScreen extends StatelessWidget {
  // properties
  final double _bodyPadding = 5.0;

  // methods
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);

    return Scaffold(
        appBar: AppBar(title: AppBarTitle(title: 'Dashboard')),
        drawer: HomeDrawer(DrawerEnum.dashboard),
        floatingActionButton: FloatingActionButton(
          foregroundColor: getFABIconForegroundColor(context),
          backgroundColor: getFABIconBackgroundColor(context),
          child: Icon(Icons.add, size: 30.0),
          onPressed: () {
            Navigator.of(context).pushNamed(
              '/dashboard/createGroup',
              arguments: RouteArgs(),
            );
          },
        ),
        body: Padding(
            padding: EdgeInsets.all(_bodyPadding),
            child: StreamBuilder<List<Group>>(
                stream: dbService.groups,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  List<Group> groups = snapshot.data;

                  return groups == null || groups.length == 0
                      ? EmptyPlaceholder(
                          iconData: Icons.dashboard, text: 'No groups')
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          itemCount: groups != null ? groups.length : 0,
                          itemBuilder: (BuildContext context, int index) {
                            if (groups[index] != null) {
                              return GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () async {
                                    if (groupDocId.value ==
                                        groups[index].docId) {
                                      Navigator.of(context).pushNamed(
                                          '/timetables',
                                          arguments: RouteArgs());
                                    } else {
                                      Member me =
                                          await dbService.getGroupMemberMe(
                                              groups[index].docId);

                                      if (me != null &&
                                          me.docId != null &&
                                          me.role != null) {
                                        if (me.role == MemberRole.owner ||
                                            me.role == MemberRole.admin ||
                                            me.role == MemberRole.member) {
                                          ttbStatus.reset();
                                          groupStatus.reset();
                                          groupDocId.value = '';
                                          groupDocId.value =
                                              groups[index].docId;

                                          Navigator.of(context).pushNamed(
                                              '/timetables',
                                              arguments: RouteArgs());
                                        } else if (me.role ==
                                            MemberRole.pending) {
                                          await showDialog(
                                              context: context,
                                              builder: (context) {
                                                return StreamBuilder(
                                                    stream:
                                                        dbService.streamGroup(
                                                            groups[index]
                                                                .docId),
                                                    builder:
                                                        (context, snapshot) {
                                                      Group group =
                                                          snapshot != null
                                                              ? snapshot.data
                                                              : null;

                                                      return group == null
                                                          ? Container()
                                                          : SimpleAlertDialog(
                                                              context: context,
                                                              contentDisplay:
                                                                  'You have been invited to join ' +
                                                                      group
                                                                          .name,
                                                              cancelDisplay:
                                                                  'DECLINE',
                                                              cancelFunction:
                                                                  () async {
                                                                await dbService
                                                                    .declineGroupInvitation(
                                                                        groups[index]
                                                                            .docId);

                                                                Navigator.of(
                                                                        context)
                                                                    .maybePop();
                                                              },
                                                              confirmDisplay:
                                                                  'ACCEPT',
                                                              confirmFunction:
                                                                  () async {
                                                                await dbService
                                                                    .acceptGroupInvitation(
                                                                        groups[index]
                                                                            .docId);

                                                                ttbStatus
                                                                    .reset();
                                                                groupStatus
                                                                    .reset();
                                                                groupDocId
                                                                        .value =
                                                                    null;
                                                                groupDocId
                                                                        .value =
                                                                    groups[index]
                                                                        .docId;

                                                                Navigator.of(
                                                                        context)
                                                                    .popAndPushNamed(
                                                                  '/timetables',
                                                                  arguments:
                                                                      RouteArgs(),
                                                                );
                                                              });
                                                    });
                                              });
                                        }
                                      } else {
                                        await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return SimpleAlertDialog(
                                                  context: context,
                                                  titleDisplay:
                                                      'Setting up ${groups[index].name}',
                                                  contentDisplay:
                                                      'This may take a few seconds',
                                                  onlyConfirmButton: true,
                                                  confirmDisplay: 'OK',
                                                  confirmFunction: () {
                                                    Navigator.of(context)
                                                        .maybePop();
                                                  });
                                            });
                                      }
                                    }
                                  },
                                  child: GroupCard(
                                    // unsure
                                    // notifications: groups[index].pendingConflicts,
                                    groupName: groups[index].name,
                                    groupColor: groups[index].colorShade.color,
                                    numOfMembers: groups[index].numOfMembers,
                                    ownerName: groups[index].ownerName,
                                  ));
                            } else {
                              return Container();
                            }
                          },
                          physics: BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          scrollDirection: Axis.vertical,
                        );
                })));
  }
}
