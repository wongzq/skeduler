import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/screens/home/home_drawer.dart';
import 'package:skeduler/screens/home/members_screen_components/member_list_tile.dart';
import 'package:skeduler/screens/home/members_screen_components/members_screen_options_admin.dart';
import 'package:skeduler/screens/home/members_screen_components/members_screen_options_member.dart';
import 'package:skeduler/screens/home/members_screen_components/members_screen_options_owner.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/loading.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';
import 'package:theme_provider/theme_provider.dart';

class MembersScreen extends StatefulWidget {
  @override
  _MembersScreenState createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);

    return groupDocId.value == null || groupDocId.value == ''
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                'Members',
                style: textStyleAppBarTitle,
              ),
            ),
            drawer: HomeDrawer(),
          )
        : StreamBuilder(
            stream: dbService.getGroup(groupDocId.value),
            builder: (context, snapshot) {
              Group group = snapshot != null ? snapshot.data : null;

              Color backgroundColor;
              IconThemeData iconTheme;
              TextTheme textTheme;

              if (group != null) {
                bool lightShade =
                    group.colorShade.shade == Shade.primaryColorLight;

                backgroundColor = getOriginThemeColorShade(group.colorShade);
                iconTheme = lightShade
                    ? ThemeProvider.themeOf(context)
                        .data
                        .iconTheme
                        .copyWith(color: Colors.black)
                    : getOriginThemeData(group.colorShade.themeId)
                        .primaryIconTheme;
                textTheme = lightShade
                    ? ThemeProvider.themeOf(context)
                        .data
                        .textTheme
                        .copyWith(title: TextStyle(color: Colors.black))
                    : getOriginThemeData(group.colorShade.themeId)
                        .primaryTextTheme;
              }

              return group == null
                  ? Loading()
                  : StreamBuilder(
                      stream: dbService.getGroupMembers(groupDocId.value),
                      builder: (context, snapshot) {
                        List<Member> members =
                            snapshot != null ? snapshot.data : null;

                        return members == null || members.isEmpty
                            ? Loading()
                            : StreamBuilder<Object>(
                                stream: dbService
                                    .getGroupMemberMyData(groupDocId.value),
                                builder: (context, snapshot) {
                                  Member me =
                                      snapshot != null ? snapshot.data : null;

                                  return me == null
                                      ? Loading()
                                      : Scaffold(
                                          appBar: AppBar(
                                            backgroundColor: backgroundColor,
                                            iconTheme: iconTheme,
                                            textTheme: textTheme,
                                            title: group.name == null
                                                ? Text(
                                                    'Members',
                                                    style: textStyleAppBarTitle,
                                                  )
                                                : Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        group.name,
                                                        style:
                                                            textStyleAppBarTitle,
                                                      ),
                                                      Text(
                                                        'Members',
                                                        style: textStyleBody,
                                                      )
                                                    ],
                                                  ),
                                          ),
                                          drawer: HomeDrawer(),
                                          body: Stack(
                                            children: <Widget>[
                                              ListView.builder(
                                                itemCount: members != null
                                                    ? members.length
                                                    : 0,
                                                itemBuilder: (context, index) {
                                                  if (members != null) {
                                                    members.sort((member1,
                                                            member2) =>
                                                        member2.role.index
                                                            .compareTo(member1
                                                                .role.index));
                                                  }

                                                  return members != null
                                                      ? MemberListTile(
                                                          me: me,
                                                          member:
                                                              members[index],
                                                        )
                                                      : Container();
                                                },
                                              ),
                                              me.role == MemberRole.owner
                                                  ? MembersScreenOptionsOwner()
                                                  : me.role == MemberRole.admin
                                                      ? MembersScreenOptionsAdmin()
                                                      : me.role ==
                                                              MemberRole.member
                                                          ? MembersScreenOptionsMember()
                                                          : Container(),
                                            ],
                                          ),
                                        );
                                });
                      },
                    );
            });
  }
}
