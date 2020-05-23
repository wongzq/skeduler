import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/widgets/label_text_input.dart';
import 'package:skeduler/shared/widgets/loading.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/simple_widgets.dart';

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
              title: AppBarTitle(
                title: groupStatus.group.name,
                alternateTitle: 'Group',
                subtitle: widget.member.role == MemberRole.dummy
                    ? 'Edit dummy'
                    : 'Edit member',
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
                    // if transfer ownership
                    if (groupStatus.me.role == MemberRole.owner &&
                        _editRole == MemberRole.owner) {
                      await dbService.updateGroupMemberRole(
                        groupDocId: groupStatus.group.docId,
                        memberDocId: groupStatus.me.docId,
                        role: MemberRole.admin,
                      );

                      await dbService.updateGroupData(
                        groupStatus.group.docId,
                        name: groupStatus.group.name,
                        description: groupStatus.group.description,
                        colorShade: groupStatus.group.colorShade,
                        ownerName: _editName,
                        ownerEmail: widget.member.docId,
                      );
                    }

                    // general update group member details
                    if ((widget.member.role == MemberRole.owner ||
                            widget.member.role == MemberRole.admin ||
                            widget.member.role == MemberRole.member) &&
                        _formKeyNickname.currentState.validate()) {
                      OperationStatus status =
                          await dbService.updateGroupMember(
                        groupDocId: groupStatus.group.docId,
                        member: Member(
                          docId: widget.member.docId,
                          name: widget.member.name,
                          nickname: _editNickname,
                          role: _editRole,
                        ),
                      );

                      if (status.completed) {
                        Fluttertoast.showToast(msg: status.message);
                      }

                      if (status.success) {
                        Navigator.of(context).maybePop();
                      }
                    }

                    // general update group dummy details
                    else if (widget.member.role == MemberRole.dummy &&
                        _formKeyName.currentState.validate() &&
                        _formKeyNickname.currentState.validate()) {
                      // if dummy id remains the same
                      OperationStatus status =
                          await dbService.updateGroupMember(
                        groupDocId: groupStatus.group.docId,
                        member: Member(
                          docId: widget.member.docId,
                          name: _editName,
                          nickname: _editNickname,
                          role: _editRole,
                        ),
                      );

                      if (status.completed) {
                        Fluttertoast.showToast(msg: status.message);
                      }

                      if (status.success) {
                        Navigator.of(context).maybePop();
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
                  // ID
                  Padding(
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
                            widget.member.role == MemberRole.owner ||
                                    widget.member.role == MemberRole.admin ||
                                    widget.member.role == MemberRole.member
                                ? 'Email'
                                : 'ID',
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
                            initialValue: widget.member.docId,
                          ),
                        )
                      ],
                    ),
                  ),

                  // Nickname
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
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

                  // Name
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

                  // member role
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 20.0,
                    ),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: 100,
                          child: Text(
                            'Role',
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        DropdownButton<MemberRole>(
                          value: _editRole,
                          disabledHint:
                              widget.member.role == MemberRole.owner ||
                                      widget.member.role == MemberRole.dummy
                                  ? Text(memberRoleStr(_editRole))
                                  : null,
                          isDense: true,
                          underline: Container(),
                          items:
                              // if I am owner, and I am editing owner, admin or member
                              groupStatus.me.role == MemberRole.owner &&
                                      (widget.member.role == MemberRole.admin ||
                                          widget.member.role ==
                                              MemberRole.member)
                                  ? [
                                      DropdownMenuItem<MemberRole>(
                                        value: MemberRole.owner,
                                        child: Text(
                                            memberRoleStr(MemberRole.owner)),
                                      ),
                                      DropdownMenuItem<MemberRole>(
                                        value: MemberRole.admin,
                                        child: Text(
                                            memberRoleStr(MemberRole.admin)),
                                      ),
                                      DropdownMenuItem<MemberRole>(
                                        value: MemberRole.member,
                                        child: Text(
                                            memberRoleStr(MemberRole.member)),
                                      ),
                                    ]
                                  :
                                  // if I am owner, and I am editing dummy
                                  widget.member.role == MemberRole.dummy
                                      ? <DropdownMenuItem<MemberRole>>[
                                          DropdownMenuItem<MemberRole>(
                                            value: MemberRole.dummy,
                                            child: Text(memberRoleStr(
                                                MemberRole.dummy)),
                                          ),
                                        ]
                                      : groupStatus.me.role == MemberRole.admin
                                          ? [
                                              DropdownMenuItem<MemberRole>(
                                                value: MemberRole.admin,
                                                child: Text(memberRoleStr(
                                                    MemberRole.admin)),
                                              ),
                                              DropdownMenuItem<MemberRole>(
                                                value: MemberRole.member,
                                                child: Text(memberRoleStr(
                                                    MemberRole.member)),
                                              ),
                                            ]
                                          : [],
                          onChanged: widget.member.role == MemberRole.owner ||
                                  widget.member.role == MemberRole.dummy
                              ? null
                              : (value) async {
                                  if (groupStatus.me.role == MemberRole.owner &&
                                      value == MemberRole.owner) {
                                    GlobalKey<FormState> formKey =
                                        GlobalKey<FormState>();

                                    await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(
                                              'Transfer ownership to ' +
                                                  (widget.member.name ?? ''),
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
                                                              'Type \'Confirm\''),
                                                      validator: (value) {
                                                        if (value ==
                                                            'Confirm') {
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
                                                  Navigator.of(context)
                                                      .maybePop();
                                                },
                                              ),

                                              // CONFIRM button
                                              FlatButton(
                                                child: Text('CONFIRM'),
                                                onPressed: () async {
                                                  if (formKey.currentState
                                                      .validate()) {
                                                    setState(() {
                                                      _editRole = value;
                                                    });
                                                    Navigator.of(context)
                                                        .maybePop();
                                                  }
                                                },
                                              ),
                                            ],
                                          );
                                        });
                                  } else {
                                    setState(() {
                                      _editRole = value;
                                    });
                                  }
                                },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
