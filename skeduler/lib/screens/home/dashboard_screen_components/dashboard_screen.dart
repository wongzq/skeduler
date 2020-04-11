import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/create_group.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/group_card.dart';
import 'package:skeduler/screens/home/home_drawer.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';

class DashboardScreen extends StatelessWidget {
  /// properties
  static const double _bodyPadding = 5.0;

  /// methods
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<DrawerEnum> selected =
        Provider.of<ValueNotifier<DrawerEnum>>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Dashboard',
          style: textStyleAppBarTitle,
        ),
      ),
      drawer: HomeDrawer(),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(_bodyPadding),
            child: StreamBuilder<List<Group>>(
              stream: dbService.groups,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                List<Group> groups = snapshot.data;

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemCount: groups != null ? groups.length : 0,
                  itemBuilder: (BuildContext context, int index) {
                    if (groups[index] != null) {
                      return StreamBuilder(
                          stream: dbService
                              .getGroupMemberMyData(groups[index].groupDocId),
                          builder: (context, snapshot) {
                            Member me = snapshot != null ? snapshot.data : null;

                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                if (me != null &&
                                    me.role != null &&
                                    me.role != MemberRole.pending) {
                                  groupDocId.value = groups[index].groupDocId;
                                  selected.value = DrawerEnum.group;
                                  Navigator.of(context).pushNamed('/group');
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return StreamBuilder(
                                            stream: dbService.getGroup(
                                                groups[index].groupDocId),
                                            builder: (context, snapshot) {
                                              Group group = snapshot != null
                                                  ? snapshot.data
                                                  : null;

                                              return group == null
                                                  ? Container()
                                                  : AlertDialog(
                                                      content: Text(
                                                          'You have been invited to join ' +
                                                              group.name),
                                                      actions: <Widget>[
                                                        /// DECLINE button
                                                        FlatButton(
                                                          child:
                                                              Text('DECLINE'),
                                                          onPressed: () async {
                                                            await dbService
                                                                .declineGroupInvitation(
                                                                    groups[index]
                                                                        .groupDocId);

                                                            selected.value =
                                                                DrawerEnum
                                                                    .dashboard;

                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),

                                                        /// ACCEPT button
                                                        FlatButton(
                                                          child: Text('ACCEPT'),
                                                          onPressed: () async {
                                                            await dbService
                                                                .acceptGroupInvitation(
                                                                    groups[index]
                                                                        .groupDocId);

                                                            selected.value =
                                                                DrawerEnum
                                                                    .group;
                                                            groupDocId.value =
                                                                groups[index]
                                                                    .groupDocId;
                                                            Navigator.of(
                                                                    context)
                                                                .popAndPushNamed(
                                                                    '/group');
                                                          },
                                                        ),
                                                      ],
                                                    );
                                            });
                                      });
                                }
                              },
                              child: GroupCard(
                                groupName: groups[index].name,
                                groupColor: groups[index].colorShade.color,
                                numOfMembers: groups[index].numOfMembers,
                                ownerName: groups[index].ownerName,
                              ),
                            );
                          });
                    } else {
                      return Container();
                    }
                  },
                  physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  scrollDirection: Axis.vertical,
                );
              },
            ),
          ),

          /// SpeedDial: Create or Join group
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
              child: SpeedDial(
                foregroundColor: getFABIconForegroundColor(context),
                backgroundColor: getFABIconBackgroundColor(context),
                overlayColor: Colors.grey,
                overlayOpacity: 0.8,
                curve: Curves.easeOutCubic,
                child: Icon(Icons.add, size: 30.0),

                /// Join button
                children: <SpeedDialChild>[
                  SpeedDialChild(
                    foregroundColor: getFABIconForegroundColor(context),
                    backgroundColor: getFABIconBackgroundColor(context),
                    child: Icon(
                      Icons.group_add,
                      size: 30.0,
                    ),
                    labelWidget: Container(
                      height: 40.0,
                      width: 100.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: getFABIconBackgroundColor(context),
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0.0, 5.0),
                            blurRadius: 10.0,
                          ),
                        ],
                      ),
                      child: Text(
                        'JOIN',
                        style: TextStyle(
                          color: getFABTextColor(context),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    onTap: () {},
                  ),

                  /// Create button
                  SpeedDialChild(
                    foregroundColor: getFABIconForegroundColor(context),
                    backgroundColor: getFABIconBackgroundColor(context),
                    child: Icon(
                      FontAwesomeIcons.users,
                      size: 25.0,
                    ),
                    labelWidget: Container(
                      height: 40.0,
                      width: 100.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: getFABIconBackgroundColor(context),
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0.0, 5.0),
                            blurRadius: 10.0,
                          ),
                        ],
                      ),
                      child: Text(
                        'CREATE',
                        style: TextStyle(
                          color: getFABTextColor(context),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateGroup(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
