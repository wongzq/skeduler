import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';

class MemberListTile extends StatelessWidget {
  final Member me;
  final Member member;

  const MemberListTile({
    Key key,
    @required this.me,
    @required this.member,
  }) : super(key: key);

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
      return member.role == MemberRole.pending ||
              member.role == MemberRole.dummy
          ? Container()
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Container(
                    child: ListTile(
                      leading: Icon(member.roleIcon),
                      title:
                          Text(member.nickname ?? member.name ?? member.email),
                      subtitle: Text(member.roleStr),
                    ),
                  ),
                ),
                Divider(),
              ],
            );
    }

    // If I am Owner or Admin
    else if (me.role == MemberRole.owner || me.role == MemberRole.admin) {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(
              child: ListTile(
                leading: Icon(member.roleIcon),
                title: Text(member.nickname ?? member.name ?? member.email),
                subtitle: Text(member.roleStr),
                trailing: member.role == MemberRole.owner
                    ? me.role == MemberRole.owner
                        ? PopupMenuButton(
                            icon: Icon(Icons.more_vert),
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  child: Text('Edit'),
                                  value: MemberOption.edit,
                                ),
                              ];
                            },
                            onSelected: (value) {},
                          )
                        : null
                    : PopupMenuButton(
                        icon: Icon(Icons.more_vert),
                        itemBuilder: (context) {
                          // If member is admin
                          if (member.role == MemberRole.admin) {
                            return [
                              me.role == MemberRole.owner
                                  ? PopupMenuItem(
                                      child: Text('Make owner'),
                                      value: MemberOption.makeOwner,
                                    )
                                  : null,
                              PopupMenuItem(
                                child: Text('Make member'),
                                value: MemberOption.makeMember,
                              ),
                              PopupMenuItem(
                                child: Text('Edit'),
                                value: MemberOption.edit,
                              ),
                              PopupMenuItem(
                                child: Text('Remove'),
                                value: MemberOption.remove,
                              ),
                            ];
                          }

                          ///If member is member
                          else if (member.role == MemberRole.member) {
                            return [
                              me.role == MemberRole.owner
                                  ? PopupMenuItem(
                                      child: Text('Make owner'),
                                      value: MemberOption.makeOwner,
                                    )
                                  : null,
                              PopupMenuItem(
                                child: Text('Make admin'),
                                value: MemberOption.makeAdmin,
                              ),
                              PopupMenuItem(
                                child: Text('Edit'),
                                value: MemberOption.edit,
                              ),
                              PopupMenuItem(
                                child: Text('Remove'),
                                value: MemberOption.remove,
                              ),
                            ];
                          }

                          // If member is Pending
                          else if (member.role == MemberRole.pending) {
                            return [
                              PopupMenuItem(
                                child: Text('Remove'),
                                value: MemberOption.remove,
                              ),
                            ];
                          }

                          // If member is Dummy
                          else if (member.role == MemberRole.dummy) {
                            return [
                              PopupMenuItem(
                                child: Text('Edit'),
                                value: MemberOption.edit,
                              ),
                              PopupMenuItem(
                                child: Text('Remove'),
                                value: MemberOption.remove,
                              ),
                            ];
                          } else {
                            return [];
                          }
                        },
                        onSelected: (value) async {
                          if (await checkInternetConnection()) {
                            if (value == MemberOption.makeOwner) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Transfer ownership to ' +
                                            (member.nickname ?? ''),
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
                                                    hintText:
                                                        'type \'Confirm\''),
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
                                            if (formKey.currentState
                                                .validate()) {
                                              await dbService
                                                  .updateMemberRoleInGroup(
                                                groupDocId:
                                                    groupStatus.group.docId,
                                                memberDocId: member.email,
                                                role: MemberRole.owner,
                                              );
                                              await dbService
                                                  .updateMemberRoleInGroup(
                                                groupDocId:
                                                    groupStatus.group.docId,
                                                memberDocId: me.email,
                                                role: MemberRole.admin,
                                              );
                                              Navigator.of(context).maybePop();
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            } else if (value == MemberOption.makeAdmin) {
                              await dbService.updateMemberRoleInGroup(
                                groupDocId: groupStatus.group.docId,
                                memberDocId: member.email,
                                role: MemberRole.admin,
                              );
                            } else if (value == MemberOption.makeMember) {
                              await dbService.updateMemberRoleInGroup(
                                groupDocId: groupStatus.group.docId,
                                memberDocId: member.email,
                                role: MemberRole.member,
                              );
                            } else if (value == MemberOption.remove) {
                              await dbService.removeMemberFromGroup(
                                groupDocId: groupStatus.group.docId,
                                memberDocId: member.email,
                              );
                            }
                          } else {
                            Fluttertoast.showToast(
                              msg: 'Please check your internet connection',
                              toastLength: Toast.LENGTH_LONG,
                            );
                          }
                        },
                      ),
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
