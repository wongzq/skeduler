import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/label_text_input.dart';
import 'package:skeduler/shared/components/loading.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';

class EditMember extends StatefulWidget {
  final Member member;

  const EditMember({
    Key key,
    @required this.member,
  }) : super(key: key);

  @override
  _EditMemberState createState() => _EditMemberState();
}

class _EditMemberState extends State<EditMember> {
  GlobalKey<FormState> _formKeyName = GlobalKey<FormState>();
  GlobalKey<FormState> _formKeyNickname = GlobalKey<FormState>();

  String _editName;
  String _editNickname;
  MemberRole _editRole;

  @override
  void initState() {
    _editName = widget.member.name;
    _editNickname = widget.member.nickname;
    _editRole = widget.member.role;
    print(_editName);
    print(_editNickname);
    print(_editRole);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return groupStatus.group == null
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    groupStatus.group.name,
                    style: textStyleAppBarTitle,
                  ),
                  Text(
                    widget.member.role == MemberRole.dummy
                        ? 'Edit dummy'
                        : 'Edit member',
                    style: textStyleBody,
                  ),
                ],
              ),
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: 'Edit Member Cancel',
                  backgroundColor: Colors.red,
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                ),
                SizedBox(width: 20.0),
                FloatingActionButton(
                  heroTag: 'Edit Member Confirm',
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    if ((widget.member.role == MemberRole.owner ||
                            widget.member.role == MemberRole.admin ||
                            widget.member.role == MemberRole.member) &&
                        _formKeyNickname.currentState.validate()) {
                      await dbService
                          .updateGroupMember(
                        groupDocId: groupStatus.group.docId,
                        member: Member(
                          id: widget.member.id,
                          name: widget.member.name,
                          nickname: _editNickname,
                          role: _editRole,
                        ),
                      )
                          .then((result) {
                        if (result) {
                          Fluttertoast.showToast(
                            msg: 'Successfully updated member details',
                            toastLength: Toast.LENGTH_LONG,
                          );
                          Navigator.of(context).maybePop();
                        } else {
                          Fluttertoast.showToast(
                            msg: 'Failed to update member details',
                            toastLength: Toast.LENGTH_LONG,
                          );
                        }
                      });
                    } else if (widget.member.role == MemberRole.dummy &&
                        _formKeyName.currentState.validate() &&
                        _formKeyNickname.currentState.validate()) {
                      if (_editName == widget.member.name) {
                        await dbService
                            .updateGroupMember(
                          groupDocId: groupStatus.group.docId,
                          member: Member(
                            id: widget.member.id,
                            name: widget.member.name,
                            nickname: _editNickname,
                            role: _editRole,
                          ),
                        )
                            .then((result) {
                          if (result) {
                            Fluttertoast.showToast(
                              msg: 'Successfully updated member details',
                              toastLength: Toast.LENGTH_LONG,
                            );
                            Navigator.of(context).maybePop();
                          } else {
                            Fluttertoast.showToast(
                              msg: 'Failed to update member details',
                              toastLength: Toast.LENGTH_LONG,
                            );
                          }
                        });
                      } else {
                        await dbService
                            .addDummyToGroup(
                          groupDocId: groupStatus.group.docId,
                          newDummyName: _editName,
                          newDummyNickname: _editNickname,
                        )
                            .then((errorMsg) async {
                          if (errorMsg == null) {
                            await dbService.removeMemberFromGroup(
                              groupDocId: groupStatus.group.docId,
                              memberDocId: widget.member.id,
                            );
                            Fluttertoast.showToast(
                              msg: 'Successfully updated member details',
                              toastLength: Toast.LENGTH_LONG,
                            );
                            Navigator.of(context).maybePop();
                          } else {
                            Fluttertoast.showToast(
                              msg: errorMsg,
                              toastLength: Toast.LENGTH_LONG,
                            );
                          }
                        });
                      }
                    }
                  },
                ),
              ],
            ),
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => unfocus(),
              child: Column(
                children: <Widget>[
                  // ID (only shows for owners, admins and members)
                  widget.member.role == MemberRole.owner ||
                          widget.member.role == MemberRole.admin ||
                          widget.member.role == MemberRole.member
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: 100,
                                child: Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  style: TextStyle(color: Colors.grey),
                                  enabled: false,
                                  initialValue: widget.member.id,
                                ),
                              )
                            ],
                          ),
                        )
                      : Container(),
                  // name
                  widget.member.role == MemberRole.owner ||
                          widget.member.role == MemberRole.admin ||
                          widget.member.role == MemberRole.member
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: 100,
                                child: Text(
                                  'Name',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  style: TextStyle(color: Colors.grey),
                                  enabled: false,
                                  initialValue: widget.member.name,
                                ),
                              )
                            ],
                          ),
                        )
                      : widget.member.role == MemberRole.dummy
                          ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: LabelTextInput(
                                initialValue: widget.member.name,
                                hintText: 'Required',
                                label: 'Name',
                                valSetText: (value) => _editName = value,
                                formKey: _formKeyName,
                                validator: (value) =>
                                    value == null || value.trim() == ''
                                        ? 'Name cannot be empty'
                                        : null,
                              ),
                            )
                          : Container(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: LabelTextInput(
                      initialValue: widget.member.nickname,
                      hintText: 'Required',
                      label: 'Nickname',
                      valSetText: (value) {
                        _editNickname = value;
                      },
                      formKey: _formKeyNickname,
                      validator: (value) => value == null || value.trim() == ''
                          ? 'Nickname cannot be empty'
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
