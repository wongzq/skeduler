import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/models/firestore/subject.dart';
import 'package:skeduler/models/auxiliary/time.dart';
import 'package:skeduler/models/firestore/timetable.dart';
import 'package:skeduler/models/firestore/user.dart';
import 'package:skeduler/shared/functions.dart';

class DatabaseService {
  // properties
  final String userId;

  // constructors method
  DatabaseService({this.userId});

  // methods
  Future<bool> dbCheckInternetConnection() async {
    if (await checkInternetConnection()) {
      return true;
    } else {
      Fluttertoast.showToast(msg: 'Please check your internet connection');
      return false;
    }
  }

  // --------------------------------------------------------------------------------
  // Collection References
  // --------------------------------------------------------------------------------

  final CollectionReference usersCollection =
      Firestore.instance.collection('users');
  final CollectionReference groupsCollection =
      Firestore.instance.collection('groups');

  // --------------------------------------------------------------------------------
  // Getter methods
  // --------------------------------------------------------------------------------

  // get [User] data as stream
  Stream<User> get user {
    return usersCollection.document(userId).snapshots().map(_userFromSnapshot);
  }

  // get ['users'] collection of [Group] as stream
  Stream<List<User>> get users {
    return usersCollection.snapshots().map(_usersFromSnapshots);
  }

  // get ['groups'] collection as stream
  Stream<List<Group>> get groups {
    return groupsCollection
        .where('members', arrayContains: userId)
        .snapshots()
        .map(_groupsFromSnapshots);
  }

  // get [Group] data as stream
  Stream<Group> streamGroup(String groupDocId) {
    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : groupsCollection
            .document(groupDocId)
            .snapshots()
            .map(_groupFromSnapshot);
  }

  // get [Group][Member] data of me as stream
  Stream<Member> streamGroupMemberMe(String groupDocId) {
    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : groupsCollection
            .document(groupDocId)
            .collection('members')
            .document(userId)
            .snapshots()
            .map(_memberFromSnapshot);
  }

  Stream<List<Timetable>> streamGroupTimetables(String groupDocId) {
    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : groupsCollection
            .document(groupDocId)
            .collection('timetables')
            .snapshots()
            .map(_timetablesFromSnapshots);
  }

  // get [Group][Member]s' data as stream
  Stream<List<Member>> streamGroupMembers(String groupDocId) {
    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : groupsCollection
            .document(groupDocId)
            .collection('members')
            .snapshots()
            .map(_membersFromSnapshots);
  }

  // get [Group][Subject]'s data as stream
  Stream<List<Subject>> streamGroupSubjects(String groupDocId) {
    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : groupsCollection
            .document(groupDocId)
            .collection('subjects')
            .snapshots()
            .map(_subjectsFromSnapshots);
  }

  // --------------------------------------------------------------------------------
  // Setter methods
  // --------------------------------------------------------------------------------

  // create [User]
  Future createUser(String email, String name) async {
    if (!(await dbCheckInternetConnection())) {
      return null;
    }

    return usersCollection.document(email).setData({'name': name});
  }

  // create [Group]
  Future createGroup(
    String name,
    ColorShade colorShade,
    String ownerEmail,
    String ownerName,
  ) async {
    if (!(await dbCheckInternetConnection())) {
      return null;
    }

    return groupsCollection.document().setData({
      'name': name,
      'colorShade': {
        'themeId': colorShade.themeId,
        'shade': colorShade.shadeIndex,
      },
      'owner': {
        'email': ownerEmail,
        'name': ownerName,
      },
      'members': [ownerEmail],
    });
  }

  // --------------------------------------------------------------------------------
  // Modifying methods for User
  // --------------------------------------------------------------------------------

  // update [User] data
  Future updateUserData({String name}) async {
    if (!(await dbCheckInternetConnection())) {
      return null;
    }

    return usersCollection.document(userId).updateData({'name': name});
  }

  // --------------------------------------------------------------------------------
  // Modifying methods for Group
  // --------------------------------------------------------------------------------

  // update [Group] data
  Future updateGroupData(
    String groupDocId, {
    String name,
    ColorShade colorShade,
    String ownerEmail,
    String ownerName,
  }) async {
    if (!(await dbCheckInternetConnection())) {
      return null;
    }

    if (groupDocId == null || groupDocId.trim() == '') {
      return null;
    } else {
      return groupsCollection.document(groupDocId).updateData({
        'name': name,
        'colorShade': {
          'themeId': colorShade.themeId,
          'shade': colorShade.shadeIndex,
        },
        'owner': {
          'email': ownerEmail,
          'name': ownerName,
        },
      });
    }
  }

  // Delete [Group]
  Future deleteGroup(String groupDocId) async {
    if (!(await dbCheckInternetConnection())) {
      return null;
    }

    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : await groupsCollection.document(groupDocId).delete();
  }

  // --------------------------------------------------------------------------------
  // Modifying methods for Member
  // --------------------------------------------------------------------------------

  // add Dummy to [Group]
  Future<OperationStatus> addDummyToGroup({
    @required String groupDocId,
    @required Member dummy,
  }) async {
    if (!(await dbCheckInternetConnection())) {
      return OperationStatus(OperationResult.abort, '');
    }

    DocumentReference groupDummyRef = groupsCollection
        .document(groupDocId)
        .collection('members')
        .document(dummy.docId);

    return groupDocId == null ||
            groupDocId.trim() == '' ||
            dummy == null ||
            dummy.docId == null ||
            dummy.docId.trim() == ''
        ? OperationStatus(OperationResult.fail, 'Failed to add dummy')
        : await groupDummyRef
            .get()
            .then((member) async => member.exists
                ? OperationStatus(
                    OperationResult.fail, 'ID ${dummy.docId} already exists')
                : await groupDummyRef
                    .setData({
                      'role': MemberRole.dummy.index,
                      'name': dummy.name,
                      'nickname': dummy.display,
                      'alwaysAvailable': true,
                      'timesAvailable': [],
                      'timesUnavailable': [],
                    })
                    .then((_) => OperationStatus(OperationResult.success,
                        'Successfully added ${dummy.display}'))
                    .catchError((_) => OperationStatus(OperationResult.fail,
                        'Failed to add ${dummy.display}')))
            .catchError((_) => OperationStatus(
                OperationResult.fail, 'Failed to add ${dummy.display}'));
  }

  // add [Member] to [Group]
  Future<OperationStatus> inviteMemberToGroup({
    @required String groupDocId,
    @required String newMemberEmail,
    MemberRole memberRole = MemberRole.pending,
  }) async {
    if (!(await dbCheckInternetConnection())) {
      return OperationStatus(OperationResult.abort, '');
    }

    DocumentReference groupMemberRef = groupsCollection
        .document(groupDocId)
        .collection('members')
        .document(newMemberEmail);

    return groupDocId == null ||
            groupDocId.trim() == '' ||
            newMemberEmail == null ||
            newMemberEmail.trim() == ''
        ? OperationStatus(
            OperationResult.fail, 'Failed to invite member to group')
        : await usersCollection
            .document(newMemberEmail)
            .get()
            .then((user) async => user.exists
                ? await groupMemberRef.get().then((member) async => member.exists
                    ? OperationStatus(
                        OperationResult.fail, 'User is already in the group')
                    : await groupMemberRef
                        .setData({'role': memberRole.index})
                        .then((_) => OperationStatus(OperationResult.success,
                            'Successfully invited $newMemberEmail'))
                        .catchError((_) => OperationStatus(OperationResult.fail,
                            'Failed to invite $newMemberEmail')))
                : OperationStatus(OperationResult.fail, 'User not found'))
            .catchError(
                (_) => OperationStatus(OperationResult.fail, 'Failed to invite $newMemberEmail'));
  }

  // remove [Member] from [Group]
  Future removeMemberFromGroup({
    @required String groupDocId,
    @required String memberDocId,
  }) async {
    if (!(await dbCheckInternetConnection())) {
      return null;
    }

    return groupsCollection
        .document(groupDocId)
        .collection('members')
        .document(memberDocId)
        .delete();
  }

  // update [Member] in group
  Future<OperationStatus> updateGroupMember({
    @required String groupDocId,
    @required Member member,
  }) async {
    if (!(await dbCheckInternetConnection())) {
      return OperationStatus(OperationResult.abort, '');
    }

    return groupDocId == null || groupDocId.trim() == ''
        ? OperationResult.fail
        : await groupsCollection
            .document(groupDocId)
            .collection('members')
            .document(member.docId)
            .updateData({
              'name': member.name,
              'nickname': member.nickname,
              'role': member.role.index,
            })
            .then((_) => OperationStatus(
                OperationResult.success, 'Successfully updated member details'))
            .catchError((_) => OperationStatus(
                OperationResult.fail, 'Failed to update member details'));
  }

  // update [Member]'s role in group
  Future updateGroupMemberRole({
    @required String groupDocId,
    @required String memberDocId,
    @required MemberRole role,
  }) async {
    if (!(await dbCheckInternetConnection())) {
      return null;
    }

    return groupDocId == null ||
            groupDocId.trim() == '' ||
            memberDocId == null ||
            memberDocId.trim() == '' ||
            role == null
        ? null
        : groupsCollection
            .document(groupDocId)
            .collection('members')
            .document(memberDocId)
            .updateData({'role': role.index});
  }

  // [Member] accepts [Group] invitation
  Future acceptGroupInvitation(String groupDocId) async {
    if (!(await dbCheckInternetConnection())) {
      return null;
    }

    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : await usersCollection.document(userId).get().then((userData) async {
            if (userData.exists) {
              DocumentReference groupMemberRef = groupsCollection
                  .document(groupDocId)
                  .collection('members')
                  .document(userId);

              await groupMemberRef.updateData({
                'role': MemberRole.member.index,
                'name': userData.data['name'] ?? '',
                'nickname': userData.data['name'] ?? '',
                'alwaysAvailable': false,
                'timesAvailable': [],
                'timesUnavailable': [],
              });
            }
          });
  }

  // [Member] declines [Group] invitation
  Future declineGroupInvitation(String groupDocId) async {
    if (!(await dbCheckInternetConnection())) {
      return null;
    }

    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : await groupsCollection.document(groupDocId).updateData({
            'members': FieldValue.arrayRemove([userId])
          }).then((_) async {
            await groupsCollection
                .document(groupDocId)
                .collection('members')
                .document(userId)
                .delete();
          });
  }

  // [Member] leaves [Group]
  Future leaveGroup(String groupDocId) async {
    if (!(await dbCheckInternetConnection())) {
      return null;
    }

    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : await groupsCollection
            .document(groupDocId)
            .collection('members')
            .document(userId)
            .delete();
  }

  // get [Group][Member] data of me as stream
  Future<Member> getGroupMemberMe(String groupDocId) async {
    if (!(await dbCheckInternetConnection())) {
      return null;
    }

    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : groupsCollection
            .document(groupDocId)
            .collection('members')
            .document(userId)
            .get()
            .then((member) => _memberFromSnapshot(member))
            .catchError((_) => null);
  }

  // --------------------------------------------------------------------------------
  // Modifying methods for Subject
  // --------------------------------------------------------------------------------

  Future<OperationStatus> addGroupSubject(
      String groupDocId, Subject newSubject) async {
    if (!(await dbCheckInternetConnection())) {
      return OperationStatus(OperationResult.abort, '');
    }

    return groupDocId == null ||
            groupDocId.trim() == '' ||
            newSubject == null ||
            newSubject.docId == null ||
            newSubject.docId.trim() == ''
        ? OperationStatus(OperationResult.fail, 'Failed to add subject')
        : await groupsCollection
            .document(groupDocId)
            .collection('subjects')
            .document(newSubject.docId)
            .get()
            .then((subject) async => subject.exists
                ? OperationStatus(OperationResult.fail,
                    'Subject ${newSubject.docId} already exists')
                : await groupsCollection
                    .document(groupDocId)
                    .collection('subjects')
                    .document(newSubject.docId)
                    .setData(
                      {
                        'name': newSubject.name,
                        'nickname': newSubject.nickname,
                      },
                    )
                    .then((_) => OperationStatus(OperationResult.success,
                        'Successfully added ${newSubject.display}'))
                    .catchError((_) => OperationStatus(OperationResult.fail,
                        'Failed to add ${newSubject.display}')))
            .catchError((_) => OperationStatus(
                OperationResult.fail, 'Failed to add ${newSubject.display}'));
  }

  Future<OperationStatus> updateGroupSubject(
    String groupDocId,
    Subject editSubject,
  ) async {
    if (!(await dbCheckInternetConnection())) {
      return OperationStatus(OperationResult.abort, '');
    }

    return groupDocId == null ||
            groupDocId.trim() == '' ||
            editSubject == null ||
            editSubject.docId == null ||
            editSubject.docId.trim() == ''
        ? OperationStatus(OperationResult.fail, 'Failed to update subject')
        : await groupsCollection
            .document(groupDocId)
            .collection('subjects')
            .document(editSubject.docId)
            .get()
            .then((subject) async => subject.exists
                ? await groupsCollection
                    .document(groupDocId)
                    .collection('subjects')
                    .document(editSubject.docId)
                    .updateData(
                      {
                        'name': editSubject.name,
                        'nickname': editSubject.nickname,
                      },
                    )
                    .then((_) => OperationStatus(OperationResult.success,
                        'Successfully updated ${editSubject.display}'))
                    .catchError((_) => OperationStatus(
                        OperationResult.fail, 'Failed to update subject'))
                : OperationStatus(OperationResult.fail, 'Subject not found'))
            .catchError((_) => OperationStatus(OperationResult.fail,
                'Failed to update ${editSubject.display}'));
  }

  Future<OperationStatus> removeGroupSubject(
      String groupDocId, Subject subject) async {
    if (!(await dbCheckInternetConnection())) {
      return OperationStatus(OperationResult.abort, '');
    }

    return groupDocId == null ||
            groupDocId.trim() == '' ||
            subject == null ||
            subject.docId == null ||
            subject.docId.trim() == ''
        ? OperationStatus(OperationResult.fail, 'Failed to remove subject')
        : await groupsCollection
            .document(groupDocId)
            .collection('subjects')
            .document(subject.docId)
            .delete()
            .then((_) => OperationStatus(OperationResult.success,
                'Successfully removed ${subject.display}'))
            .catchError((_) => OperationStatus(
                OperationResult.fail, 'Failed to remove ${subject.display}'));
  }

  Future<OperationStatus> updateGroupSubjectsOrder(
      String groupDocId, List<String> subjectMetadatas) async {
    if (!(await dbCheckInternetConnection())) {
      return OperationStatus(OperationResult.abort, '');
    }

    return groupDocId == null ||
            groupDocId.trim() == '' ||
            subjectMetadatas == null
        ? OperationStatus(OperationResult.fail, 'Failed to update subjects')
        : await groupsCollection
            .document(groupDocId)
            .updateData({'subjects': subjectMetadatas})
            .then((_) => OperationStatus(
                OperationResult.success, 'Successfully updated subjects order'))
            .catchError((_) => OperationStatus(
                OperationResult.fail, 'Failed to update subjects order'));
  }

  // --------------------------------------------------------------------------------
  // Modifying methods for Timetable
  // --------------------------------------------------------------------------------

  // update [Group][Timetable]'s data
  Future updateGroupTimetable(
    String groupDocId,
    EditTimetable editTtb,
  ) async {
    if (!(await dbCheckInternetConnection())) {
      return null;
    }

    CollectionReference timetablesRef =
        groupsCollection.document(groupDocId).collection('timetables');

    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : timetablesRef.document(editTtb.docId).get().then((timetable) async {
            // update timetable metadata to Group
            return timetable.exists
                ? timetablesRef
                    .document(editTtb.docId)
                    .updateData(editTtb.asFirestoreMap())
                : timetablesRef
                    .document(editTtb.docId)
                    .setData(editTtb.asFirestoreMap());
          });
  }

  // update [Group][Timetable]'s documentID by cloning document with a new ID
  Future<OperationStatus> updateGroupTimetableDocId(
    String groupDocId,
    TimetableMetadata oldTimetableMetadata,
    TimetableMetadata newTimetableMetadata,
  ) async {
    if (!(await dbCheckInternetConnection())) {
      return OperationStatus(OperationResult.abort, '');
    }

    CollectionReference timetablesRef =
        groupsCollection.document(groupDocId).collection('timetables');
    return groupDocId == null || groupDocId.trim() == ''
        ? OperationResult.fail
        : await timetablesRef
            .document(newTimetableMetadata.docId)
            .get()
            .then((groupData) async {
            // If there is another timetable with the same ID
            // Then, it doesn't replace the pre-existing timetable
            if (!groupData.exists) {
              return timetablesRef
                  .document(oldTimetableMetadata.docId)
                  .get()
                  .then((groupData) async {
                List<Future> futures = [];

                futures.add(timetablesRef
                    .document(newTimetableMetadata.docId)
                    .setData(groupData.data));

                futures.add(timetablesRef
                    .document(oldTimetableMetadata.docId)
                    .delete());

                return Future.wait(futures);
              }).then((_) => OperationStatus(OperationResult.success,
                      'Successfully updated timetable name'));
            } else {
              return OperationStatus(
                  OperationResult.fail, 'Timetable name already exists');
            }
          });
  }

  Future deleteGroupTimetable(
    String groupDocId,
    String timetableId,
  ) async {
    if (!(await dbCheckInternetConnection())) {
      return null;
    }

    return groupsCollection
        .document(groupDocId)
        .collection('timetables')
        .document(timetableId)
        .delete()
        .then((_) {
      // groupsCollection.document(groupDocId).get().then((group) async {
      //   return groupsCollection.document(groupDocId).updateData({
      //     'timetables': _getUpdatedGroupTimetablesMetadataAfterRemove(
      //         timetablesSnapshot: group.data['timetables'],
      //         timetableId: timetableId)
      //   });
      // });
    });
  }

  // --------------------------------------------------------------------------------
  // Modifying methods for Times
  // --------------------------------------------------------------------------------

  Future updateGroupMemberAlwaysAvailable(
    String groupDocId,
    String memberDocId,
    bool alwaysAvailable,
  ) async {
    if (!(await dbCheckInternetConnection())) {
      return null;
    }
    memberDocId =
        memberDocId == null || memberDocId.trim() == '' ? userId : memberDocId;

    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : await groupsCollection
            .document(groupDocId)
            .collection('members')
            .document(memberDocId)
            .updateData({'alwaysAvailable': alwaysAvailable ?? false});
  }

  // add new time in [Group][Member]'s available  or unavailable times
  Future addGroupMemberTime(
    String groupDocId,
    String memberDocId,
    Time newTime,
    bool alwaysAvailable,
  ) async {
    if (!(await dbCheckInternetConnection())) {
      return null;
    }

    String targetList = alwaysAvailable ? 'timesUnavailable' : 'timesAvailable';

    memberDocId =
        memberDocId == null || memberDocId.trim() == '' ? userId : memberDocId;

    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : await groupsCollection
            .document(groupDocId)
            .collection('members')
            .document(memberDocId)
            .get()
            .then((member) async {
            Map<String, Timestamp> timestamp = {
              'startTime': Timestamp.fromDate(newTime.startTime),
              'endTime': Timestamp.fromDate(newTime.endTime),
            };

            // add new times to Firestore
            return member.exists
                ? await groupsCollection
                    .document(groupDocId)
                    .collection('members')
                    .document(memberDocId)
                    .updateData({
                    targetList: FieldValue.arrayUnion([timestamp])
                  })
                : null;
          });
  }

  // update [Group][Member]'s available or unavailable times
  Future updateGroupMemberTimes(
    String groupDocId,
    String memberDocId,
    List<Time> newTimes,
    bool alwaysAvailable,
  ) async {
    if (!(await dbCheckInternetConnection())) {
      return null;
    }

    String targetList = alwaysAvailable ? 'timesUnavailable' : 'timesAvailable';

    memberDocId =
        memberDocId == null || memberDocId.trim() == '' ? userId : memberDocId;

    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : await groupsCollection
            .document(groupDocId)
            .collection('members')
            .document(memberDocId)
            .get()
            .then((member) async {
            List<Future> futures = [];

            if (member.exists) {
              List<Time> prevTimes;
              List<Map<String, Timestamp>> removeTimestamps = [];
              List<Map<String, Timestamp>> newTimestamps = [];

              // convert [List<Time>] into [List<Map<String, Timestamp>]
              newTimes.forEach((time) {
                newTimestamps.add({
                  'startTime': Timestamp.fromDate(time.startTime),
                  'endTime': Timestamp.fromDate(time.endTime),
                });
              });

              // get previous times and remove times on the same day
              if (member.data[targetList] != null) {
                prevTimes = _timesFromDynamicList(member.data[targetList]);

                prevTimes.forEach((pTime) {
                  newTimes.forEach((nTime) {
                    if ((pTime.startTime.year == nTime.startTime.year &&
                            pTime.startTime.month == nTime.startTime.month &&
                            pTime.startTime.day == nTime.startTime.day) ||
                        (pTime.endTime.year == nTime.endTime.year &&
                            pTime.endTime.month == nTime.endTime.month &&
                            pTime.endTime.day == nTime.endTime.day)) {
                      removeTimestamps.add({
                        'startTime': Timestamp.fromDate(pTime.startTime),
                        'endTime': Timestamp.fromDate(pTime.endTime),
                      });
                    }
                  });
                });

                futures.add(
                  groupsCollection
                      .document(groupDocId)
                      .collection('members')
                      .document(memberDocId)
                      .updateData({
                    targetList: FieldValue.arrayRemove(removeTimestamps)
                  }).then((_) async {
                    // add new times to Firestore
                    return groupsCollection
                        .document(groupDocId)
                        .collection('members')
                        .document(memberDocId)
                        .updateData(
                            {targetList: FieldValue.arrayUnion(newTimestamps)});
                  }),
                );
              } else {
                // add new times to Firestore
                futures.add(groupsCollection
                    .document(groupDocId)
                    .collection('members')
                    .document(memberDocId)
                    .updateData(
                        {targetList: FieldValue.arrayUnion(newTimestamps)}));
              }
            }

            return Future.wait(futures);
          });
  }

  // remove [Group][Member]'s available schedule times
  Future removeGroupMemberTimes(
    String groupDocId,
    String memberDocId,
    List<Time> removeTimes,
    bool alwaysAvailable,
  ) async {
    if (!(await dbCheckInternetConnection())) {
      return null;
    }
    String targetList = alwaysAvailable ? 'timesUnavailable' : 'timesAvailable';

    memberDocId =
        memberDocId == null || memberDocId.trim() == '' ? userId : memberDocId;

    List<Time> prevTimes = [];
    List<Time> timesOnSameDay = [];
    List<Map<String, Timestamp>> removeTimestamps = [];

    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : await groupsCollection
            .document(groupDocId)
            .collection('members')
            .document(memberDocId)
            .get()
            .then((member) async {
            if (member.data[targetList] != null) {
              prevTimes = _timesFromDynamicList(member.data[targetList]);

              for (int p = 0; p < prevTimes.length; p++) {
                for (int r = 0; r < removeTimes.length; r++) {
                  // keep times with times on same day
                  if ((prevTimes[p].startTime.year ==
                              removeTimes[r].startTime.year &&
                          prevTimes[p].startTime.month ==
                              removeTimes[r].startTime.month &&
                          prevTimes[p].startTime.day ==
                              removeTimes[r].startTime.day) ||
                      (prevTimes[p].endTime.year ==
                              removeTimes[r].endTime.year &&
                          prevTimes[p].endTime.month ==
                              removeTimes[r].endTime.month &&
                          prevTimes[p].endTime.day ==
                              removeTimes[r].endTime.day)) {
                    // add to list
                    timesOnSameDay.add(prevTimes[p]);
                  }
                }
              }

              // convert [List<Time>] to [List<Map<String, Timestamp>]
              timesOnSameDay.forEach((time) {
                Timestamp startTimestamp = Timestamp.fromDate(time.startTime);
                Timestamp endTimestamp = Timestamp.fromDate(time.endTime);
                removeTimestamps.add({
                  'startTime': startTimestamp,
                  'endTime': endTimestamp,
                });
              });

              await groupsCollection
                  .document(groupDocId)
                  .collection('members')
                  .document(memberDocId)
                  .updateData(
                      {targetList: FieldValue.arrayRemove(removeTimestamps)});
            }
          });
  }

  // --------------------------------------------------------------------------------
  // Auxiliary methods
  // --------------------------------------------------------------------------------

  // convert snapshot to [User]
  User _userFromSnapshot(DocumentSnapshot snapshot) {
    return snapshot.data != null
        ? User(
            email: snapshot.documentID ?? '',
            name: snapshot.data['name'] ?? '',
          )
        : User();
  }

  // convert snapshot to [Group]
  Group _groupFromSnapshot(DocumentSnapshot snapshot) {
    return snapshot.data != null
        ? Group(
            docId: snapshot.documentID,
            name: snapshot.data['name'] ?? '',
            colorShade: ColorShade(
              themeId: snapshot.data['colorShade']['themeId'],
              shade: Shade.values[snapshot.data['colorShade']['shade']],
            ),
            ownerEmail: snapshot.data['owner']['email'] ?? '',
            ownerName: snapshot.data['owner']['name'] ?? '',
            memberMetadatas:
                _stringsFromDynamicList(snapshot.data['members'] ?? []),
            subjectMetadatas:
                _stringsFromDynamicList(snapshot.data['subjects'] ?? []),
            timetableMetadatas: _timetableMetadatasFromDynamicList(
              snapshot.data['timetables'] ?? [],
            ))
        : null;
  }

  // convert snapshot to [Member]
  Member _memberFromSnapshot(DocumentSnapshot snapshot) {
    return snapshot.data != null
        ? Member(
            docId: snapshot.documentID,
            name: snapshot.data['name'],
            nickname: snapshot.data['nickname'] ?? snapshot.data['name'],
            description: snapshot.data['description'],
            role: MemberRole.values[snapshot.data['role']],
            timesAvailable:
                _timesFromDynamicList(snapshot.data['timesAvailable'] ?? []),
            timeUnavailable:
                _timesFromDynamicList(snapshot.data['timesUnavailable'] ?? []),
            alwaysAvailable: snapshot.data['alwaysAvailable'] ?? false,
            // colorShade: ColorShade(
            //   themeId: snapshot.data['colorShade']['themeId'],
            //   shade: snapshot.data['colorShade']['shade'],
            // ),
          )
        : Member(docId: null);
  }

  // convert snapshot to [Subject]
  Subject _subjectFromSnapshot(DocumentSnapshot snapshot) {
    return snapshot.data != null
        ? Subject(
            docId: snapshot.documentID,
            name: snapshot.data['name'],
            nickname: snapshot.data['nickname'],
          )
        : Subject(docId: null);
  }

  Timetable _timetableFromSnapshot(DocumentSnapshot snapshot) {
    return snapshot.data != null
        ? Timetable(
            docId: snapshot.documentID,
            startDate: snapshot.data['startDate'] ?? null,
            endDate: snapshot.data['endDate'] ?? null,
            gridAxisOfDay: snapshot.data['gridAxisOfDay'] == null
                ? GridAxis.x
                : GridAxis.values[snapshot.data['gridAxisOfDay']],
            gridAxisOfTime: snapshot.data['gridAxisOfTime'] == null
                ? GridAxis.y
                : GridAxis.values[snapshot.data['gridAxisOfTime']],
            gridAxisOfCustom: snapshot.data['gridAxisOfCustom'] == null
                ? GridAxis.z
                : GridAxis.values[snapshot.data['gridAxisOfCustom']],
            groups: _timetableGroupsFromDynamicList(snapshot.data['groups']))
        : Timetable(docId: '');
  }

  // convert document snapshots into [User]s
  List<User> _usersFromSnapshots(QuerySnapshot query) {
    return query.documents.map(_userFromSnapshot).toList();
  }

  // convert document snapshots into [Group]s
  List<Group> _groupsFromSnapshots(QuerySnapshot query) {
    return query.documents.map(_groupFromSnapshot).toList();
  }

  // convert document snapshots into [Member]s
  List<Member> _membersFromSnapshots(QuerySnapshot query) {
    return query.documents.map(_memberFromSnapshot).toList();
  }

  // convert document snapshots into [Subject]s
  List<Subject> _subjectsFromSnapshots(QuerySnapshot query) {
    return query.documents.map(_subjectFromSnapshot).toList();
  }

  // convert document snapshots into [Timetable]s
  List<Timetable> _timetablesFromSnapshots(QuerySnapshot query) {
    return query.documents.map(_timetableFromSnapshot).toList();
  }

  // convert [List<dynamic>] into [List<TimetableMetadata]
  List<TimetableMetadata> _timetableMetadatasFromDynamicList(
      List<dynamic> timetables) {
    List<TimetableMetadata> timetableMetadatas = [];

    timetables.forEach((elem) {
      Map map = elem as Map;
      timetableMetadatas.add(
        TimetableMetadata(
          docId: map['docId'],
          startDate: map['startDate'],
          endDate: map['endDate'],
        ),
      );
    });

    return timetableMetadatas;
  }

  // convert [List<dynamic>] into [List<Weekday]
  List<Weekday> _weekdaysFromDynamicList(List<dynamic> weekdaysDynamic) {
    return weekdaysDynamic.map((elem) => Weekday.values[elem]).toList();
  }

  // convert [List<dynamic>] into [List<Time>]
  List<Time> _timesFromDynamicList(List<dynamic> timesDynamic) {
    return timesDynamic
        .map((elem) => Time(
            startTime: elem['startTime'].toDate(),
            endTime: elem['endTime'].toDate()))
        .toList();
  }

  // convert [List<String>] into [List<String>]
  List<String> _stringsFromDynamicList(List<dynamic> list) {
    return list.map((elem) => (elem as String)).toList();
  }

  List<TimetableGroup> _timetableGroupsFromDynamicList(List<dynamic> list) {
    List<TimetableGroup> timetableGroups = [];

    for (dynamic elem in list) {
      Map map = elem as Map;
      timetableGroups.add(TimetableGroup(
          axisDay: _weekdaysFromDynamicList(map['axisDay']),
          axisTime: _timesFromDynamicList(map['axisTime']),
          axisCustom: _stringsFromDynamicList(map['axisCustom']),
          gridDataList: _gridDataListFromDynamicList(map['gridDataList'])));
    }

    return timetableGroups;
  }

  // convert [Map] into [TimetableGridData]
  TimetableGridData _gridDataFromMap(Map gridData) {
    return TimetableGridData(
      coord: TimetableCoord(
          day: Weekday.values[gridData['coord']['day']],
          time: Time(
            startTime: gridData['coord']['time']['startTime'].toDate(),
            endTime: gridData['coord']['time']['endTime'].toDate(),
          ),
          custom: gridData['coord']['custom']),
      dragData: TimetableDragSubjectMember(
        subject: TimetableDragSubject(
          docId: gridData['subject']['docId'],
          display: gridData['subject']['display'],
        ),
        member: TimetableDragMember(
          docId: gridData['member']['docId'],
          display: gridData['member']['display'],
        ),
      ),
      available: gridData['available'],
    );
  }

  // convert [List<dynamic>] into [List<TimetableGridData]
  TimetableGridDataList _gridDataListFromDynamicList(List<dynamic> list) {
    List<TimetableGridData> gridDataList = [];

    list.forEach((elem) {
      Map map = elem as Map;

      gridDataList.add(_gridDataFromMap(map));
    });

    return TimetableGridDataList(value: gridDataList);
  }
}

enum OperationResult { success, fail, abort }

class OperationStatus {
  // properties
  OperationResult _result;
  String _message;

  // constructor
  OperationStatus(
    OperationResult result,
    String message,
  )   : this._result = result,
        this._message = message;

  bool get completed =>
      this._result == OperationResult.success ||
      this._result == OperationResult.fail;
  bool get success => this._result == OperationResult.success;
  bool get fail => this._result == OperationResult.fail;
  bool get abort => this._result == OperationResult.abort;
  String get message => this._message ?? '';
}
