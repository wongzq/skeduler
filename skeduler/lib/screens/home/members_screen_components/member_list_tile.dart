import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/route_arguments.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/widgets.dart';
import 'package:theme_provider/theme_provider.dart';

class MemberListTile extends StatelessWidget {
  final Member me;
  final Member member;

  const MemberListTile({
    Key key,
    @required this.me,
    @required this.member,
  }) : super(key: key);

  // methods
  PopupMenuItem _optionMakeOwner() {
    return PopupMenuItem(
      child: Row(
        children: <Widget>[
          Icon(FontAwesomeIcons.userTie),
          SizedBox(width: 10.0),
          Text('Make Owner'),
        ],
      ),
      value: MemberOption.makeOwner,
    );
  }

  PopupMenuItem _optionMakeAdmin() {
    return PopupMenuItem(
      child: Row(
        children: <Widget>[
          Icon(FontAwesomeIcons.userCog),
          SizedBox(width: 10.0),
          Text('Make Admin'),
        ],
      ),
      value: MemberOption.makeAdmin,
    );
  }

  PopupMenuItem _optionMakeMember() {
    return PopupMenuItem(
      child: Row(
        children: <Widget>[
          Icon(FontAwesomeIcons.userAlt),
          SizedBox(width: 10.0),
          Text('Make member'),
        ],
      ),
      value: MemberOption.makeMember,
    );
  }

  PopupMenuItem _optionEdit() {
    return PopupMenuItem(
      child: Row(
        children: <Widget>[
          Icon(Icons.edit),
          SizedBox(width: 10.0),
          Text('Edit'),
        ],
      ),
      value: MemberOption.edit,
    );
  }

  PopupMenuItem _optionRemove() {
    return PopupMenuItem(
      child: Row(
        children: <Widget>[
          Icon(Icons.delete),
          SizedBox(width: 10.0),
          Text('Remove'),
        ],
      ),
      value: MemberOption.remove,
    );
  }

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    if (me.role == MemberRole.pending) {
      return Container();
    }

    // If I am Member
    else if (me.role == MemberRole.member) {
      return member.role == MemberRole.pending
          ? Container()
          : Column(
              children: <Widget>[
                Container(
                  color: member.docId == me.docId
                      ? getOriginThemeData(ThemeProvider.themeOf(context).id)
                          .primaryColorLight
                      : null,
                  child: ListTile(
                    leading: Icon(
                      member.roleIcon,
                      color: member.docId == me.docId ? Colors.black : null,
                    ),
                    title: Text(
                      member.display,
                      style: TextStyle(
                          color:
                              member.docId == me.docId ? Colors.black : null),
                    ),
                    subtitle: Text(
                      member.name,
                      style: TextStyle(
                          color: member.docId == me.docId
                              ? Colors.grey.shade700
                              : null),
                    ),
                  ),
                ),
                Divider(height: 1.0),
              ],
            );
    }

    // If I am Owner or Admin
    else if (me.role == MemberRole.owner || me.role == MemberRole.admin) {
      return Column(
        children: <Widget>[
          Container(
            color: member.docId == me.docId
                ? getOriginThemeData(ThemeProvider.themeOf(context).id)
                    .primaryColorLight
                : null,
            child: ListTile(
              leading: Icon(
                member.roleIcon,
                color: member.docId == me.docId ? Colors.black : null,
              ),
              title: Text(
                member.role == MemberRole.pending
                    ? member.docId
                    : member.nickname,
                style: TextStyle(
                    color: member.docId == me.docId ? Colors.black : null),
              ),
              subtitle: member.role == MemberRole.pending
                  ? null
                  : Text(
                      member.name,
                      style: TextStyle(
                          color: member.docId == me.docId
                              ? Colors.grey.shade700
                              : null),
                    ),
              trailing: member.role == MemberRole.owner
                  ? me.role == MemberRole.owner
                      ? PopupMenuButton(
                          icon: Icon(
                            Icons.more_vert,
                            color:
                                member.docId == me.docId ? Colors.black : null,
                          ),
                          itemBuilder: (context) {
                            return [
                              _optionEdit(),
                            ];
                          },
                          onSelected: (value) {
                            if (value == MemberOption.edit) {
                              Navigator.of(context).pushNamed(
                                '/members/editMember',
                                arguments: RouteArgsEditMember(
                                  member: member,
                                ),
                              );
                            }
                          },
                        )
                      : null
                  : PopupMenuButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: member.docId == me.docId ? Colors.black : null,
                      ),
                      itemBuilder: (context) {
                        // If member is admin
                        if (member.role == MemberRole.admin) {
                          return [
                            me.role == MemberRole.owner
                                ? _optionMakeOwner()
                                : null,
                            _optionMakeMember(),
                            _optionEdit(),
                            _optionRemove(),
                          ];
                        }

                        ///If member is member
                        else if (member.role == MemberRole.member) {
                          return [
                            me.role == MemberRole.owner
                                ? _optionMakeOwner()
                                : null,
                            _optionMakeAdmin(),
                            _optionEdit(),
                            _optionRemove(),
                          ];
                        }

                        // If member is Pending
                        else if (member.role == MemberRole.pending) {
                          return [
                            _optionRemove(),
                          ];
                        }

                        // If member is Dummy
                        else if (member.role == MemberRole.dummy) {
                          return [
                            _optionEdit(),
                            _optionRemove(),
                          ];
                        } else {
                          return [];
                        }
                      },
                      onSelected: (value) async {
                        if (value == MemberOption.makeOwner) {
                          await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    'Transfer ownership to ' +
                                        (member.name ?? ''),
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                  content: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Form(
                                          key: formKey,
                                          child: TextFormField(
                                            autofocus: true,
                                            decoration: InputDecoration(
                                                hintText: 'Type \'Confirm\''),
                                            validator: (value) {
                                              if (value == 'Confirm') {
                                                return null;
                                              } else {
                                                return 'Word doesn\'t match';
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    // CANCEL button
                                    FlatButton(
                                      child: Text('CANCEL'),
                                      onPressed: () {
                                        Navigator.of(context).maybePop();
                                      },
                                    ),

                                    // CONFIRM button
                                    FlatButton(
                                      child: Text('CONFIRM'),
                                      onPressed: () async {
                                        if (formKey.currentState.validate()) {
                                          Navigator.of(context).maybePop();

                                          await dbService.updateGroupMemberRole(
                                            groupDocId: groupStatus.group.docId,
                                            memberDocId: member.docId,
                                            role: MemberRole.owner,
                                          );
                                          await dbService.updateGroupMemberRole(
                                            groupDocId: groupStatus.group.docId,
                                            memberDocId: me.docId,
                                            role: MemberRole.admin,
                                          );

                                          await dbService.updateGroupData(
                                            groupStatus.group.docId,
                                            name: groupStatus.group.name,
                                            description:
                                                groupStatus.group.description,
                                            colorShade:
                                                groupStatus.group.colorShade,
                                            ownerName: member.name,
                                            ownerEmail: member.docId,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                );
                              });
                        } else if (value == MemberOption.makeAdmin) {
                          await dbService.updateGroupMemberRole(
                            groupDocId: groupStatus.group.docId,
                            memberDocId: member.docId,
                            role: MemberRole.admin,
                          );
                        } else if (value == MemberOption.makeMember) {
                          await dbService.updateGroupMemberRole(
                            groupDocId: groupStatus.group.docId,
                            memberDocId: member.docId,
                            role: MemberRole.member,
                          );
                        } else if (value == MemberOption.edit) {
                          Navigator.of(context).pushNamed(
                            '/members/editMember',
                            arguments: RouteArgsEditMember(
                              member: member,
                            ),
                          );
                        } else if (value == MemberOption.remove) {
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleAlertDialog(
                                context: context,
                                contentDisplay:
                                    'Remove ${member.display} from the group?',
                                confirmDisplay: 'REMOVE',
                                confirmFunction: () async {
                                  await dbService.removeMemberFromGroup(
                                    groupDocId: groupStatus.group.docId,
                                    memberDocId: member.docId,
                                  );
                                },
                              );
                            },
                          );
                        }
                      },
                    ),
            ),
          ),
          Divider(height: 1.0),
        ],
      );
    } else {
      return Container();
    }
  }
}

enum MemberOption {
  makeOwner,
  makeAdmin,
  makeMember,
  edit,
  remove,
}
