import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/models/group_data/user.dart';

class DatabaseService {
  /// properties
  final String userId;
  final String _members = 'members';
  final String _timetables = 'timetables';

  /// constructors method
  DatabaseService({this.userId});

  ////////////////////////////////////////////////////////////////////////////////////////////////
  /// Collection References
  ////////////////////////////////////////////////////////////////////////////////////////////////

  final CollectionReference usersCollection =
      Firestore.instance.collection('users');
  final CollectionReference groupsCollection =
      Firestore.instance.collection('groups');

  ////////////////////////////////////////////////////////////////////////////////////////////////
  /// Getter methods
  ////////////////////////////////////////////////////////////////////////////////////////////////

  /// get [User] data as stream
  Stream<User> get user {
    return usersCollection.document(userId).snapshots().map(_userFromSnapshot);
  }

  /// get ['users'] collection of [Group] as stream
  Stream<List<User>> get users {
    return usersCollection.snapshots().map(_usersFromSnapshots);
  }

  /// get ['groups'] collection as stream
  Stream<List<Group>> get groups {
    return groupsCollection
        .where(_members, arrayContains: userId)
        .snapshots()
        .map(_groupsFromSnapshots);
  }

  /// get [Group] data as stream
  Stream<Group> getGroup(String groupDocId) {
    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : groupsCollection
            .document(groupDocId)
            .snapshots()
            .map(_groupFromSnapshot);
  }

  /// get [Group][Member] data of me as stream
  Stream<Member> getGroupMemberMyData(String groupDocId) {
    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : groupsCollection
            .document(groupDocId)
            .collection(_members)
            .document(userId)
            .snapshots()
            .map(_memberFromSnapshot);
  }

  /// get [Group][Member]s' data as stream
  Stream<List<Member>> getGroupMembers(String groupDocId) {
    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : groupsCollection
            .document(groupDocId)
            .collection(_members)
            .snapshots()
            .map(_membersFromSnapshots);
  }

  /// get [Group][Timetable] data
  Future<Timetable> getGroupTimetable(
    String groupDocId,
    String timetableDocId,
  ) async {
    return groupDocId == null ||
            groupDocId.trim() == '' ||
            timetableDocId == null ||
            timetableDocId.trim() == ''
        ? null
        : await groupsCollection
            .document(groupDocId)
            .collection(_timetables)
            .document(timetableDocId)
            .get()
            .then((timetable) {
            return timetable.exists ? _timetableFromSnapshot(timetable) : null;
          });
  }

  /// get [Group][Timetable] data of today as stream
  Stream<Timetable> getGroupTimetableForToday(
    String groupDocId,
    String timetableIdForToday,
  ) {
    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : groupsCollection
            .document(groupDocId)
            .collection(_timetables)
            .document(timetableIdForToday)
            .snapshots()
            .map(_timetableFromSnapshot);
  }

  Future<String> getGroupTimetableIdForToday(String groupDocId) async {
    String timetableIdForToday;

    return await groupsCollection.document(groupDocId).get().then((group) {
      /// get timetable metadatas from group document's field value
      _timetableMetadatasFromDynamicList(group.data[_timetables] ?? [])
          .forEach((metadata) {
        if (

            /// If startDate is before or equal to now
            (metadata.startDate.toDate().isBefore(DateTime.now()) ||
                    metadata.startDate
                        .toDate()
                        .isAtSameMomentAs(DateTime.now())) &&

                /// If endDate + 1 day is after or equal to now
                (metadata.endDate
                        .toDate()
                        .add(Duration(days: 1))
                        .isAfter(DateTime.now()) ||
                    metadata.endDate
                        .toDate()
                        .add(Duration(days: 1))
                        .isAtSameMomentAs(DateTime.now()))) {
          timetableIdForToday = metadata.id;
        }
      });
    }).then((_) => timetableIdForToday);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////
  /// Setter methods
  ////////////////////////////////////////////////////////////////////////////////////////////////

  /// set [User] data
  Future setUserData(String email, String name) async {
    return await usersCollection.document(email).setData({
      'name': name,
    });
  }

  /// set [Group] data
  Future setGroupData(
    String name,
    String description,
    ColorShade colorShade,
    String ownerEmail,
    String ownerName,
  ) async {
    DocumentReference newGroupDoc = groupsCollection.document();
    return await newGroupDoc.setData({
      'name': name,
      'description': description,
      'colorShade': {
        'themeId': colorShade.themeId,
        'shade': colorShade.shadeIndex,
      },
      'owner': {
        'email': ownerEmail,
        'name': ownerName,
      },
      _members: [ownerEmail],
    }).then((_) async {
      await inviteMemberToGroup(
        groupDocId: newGroupDoc.documentID,
        newMemberEmail: ownerEmail,
        memberRole: MemberRole.owner,
      );
      await usersCollection.document(userId).get().then((groupData) async {
        await groupsCollection
            .document(newGroupDoc.documentID)
            .collection(_members)
            .document(userId)
            .updateData({
          'name': groupData.data['name'],
          'nickname': groupData.data['name'],
        });
      });
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////
  /// Modifying methods for User
  ////////////////////////////////////////////////////////////////////////////////////////////////

  /// update [User] data
  Future updateUserData({String name}) async {
    return await usersCollection.document(userId).updateData({
      'name': name,
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////
  /// Modifying methods for Group
  ////////////////////////////////////////////////////////////////////////////////////////////////

  /// update [Group] data
  Future updateGroupData(
    String groupDocId, {
    String name,
    String description,
    ColorShade colorShade,
    String ownerEmail,
    String ownerName,
  }) async {
    if (groupDocId == null || groupDocId.trim() == '') {
      return null;
    } else {
      return await groupsCollection.document(groupDocId).updateData({
        'name': name,
        'description': description,
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

  /// Delete [Group]
  Future deleteGroup(String groupDocId) async {
    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : await groupsCollection
            .document(groupDocId)
            .collection(_members)
            .getDocuments()
            .then((members) {
            for (DocumentSnapshot snap in members.documents) {
              snap.reference.delete();
            }
          }).then((_) async {
            await groupsCollection.document(groupDocId).delete();
          });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////
  /// Modifying methods for Member
  ////////////////////////////////////////////////////////////////////////////////////////////////

  /// add Dummy to [Group]
  Future<String> inviteDummyToGroup({
    @required String groupDocId,
    @required String newDummyName,
  }) async {
    String errorMsg;

    DocumentReference groupDummyRef = groupsCollection
        .document(groupDocId)
        .collection(_members)
        .document(newDummyName);

    await groupDummyRef.get().then((member) async {
      !member.exists
          ? await groupsCollection.document(groupDocId).updateData({
              _members: FieldValue.arrayUnion([newDummyName])
            }).then((_) async {
              await groupDummyRef.setData({
                'role': MemberRole.dummy.index,
                'name': newDummyName,
                'nickname': newDummyName,
              });
            })
          : errorMsg = 'Dummy is already in the group';
    });

    return errorMsg;
  }

  /// add [Member] to [Group]
  Future<String> inviteMemberToGroup({
    @required String groupDocId,
    @required String newMemberEmail,
    MemberRole memberRole = MemberRole.pending,
  }) async {
    String errorMsg;

    DocumentReference groupMemberRef = groupsCollection
        .document(groupDocId)
        .collection(_members)
        .document(newMemberEmail);

    await usersCollection.document(newMemberEmail).get().then((user) async {
      user.exists
          ? await groupMemberRef.get().then((member) async {
              !member.exists
                  ? await groupsCollection.document(groupDocId).updateData({
                      _members: FieldValue.arrayUnion([newMemberEmail])
                    }).then((_) async {
                      await groupMemberRef.setData({'role': memberRole.index});
                    })
                  : errorMsg = 'User is already in the group';
            })
          : errorMsg = 'User not found';
    });

    return errorMsg;
  }

  /// remove [Member] from [Group]
  Future removeMemberFromGroup({
    @required String groupDocId,
    @required String memberDocId,
  }) async {
    return await groupsCollection.document(groupDocId).updateData({
      _members: FieldValue.arrayRemove([memberDocId])
    }).then((_) async {
      await groupsCollection
          .document(groupDocId)
          .collection(_members)
          .document(memberDocId)
          .delete();
    });
  }

  /// update [Member]'s role in group
  Future updateMemberRoleInGroup({
    @required String groupDocId,
    @required String memberDocId,
    @required MemberRole role,
  }) async {
    return await groupsCollection
        .document(groupDocId)
        .collection(_members)
        .document(memberDocId)
        .updateData({'role': role.index});
  }

  /// [Member] accepts [Group] invitation
  Future acceptGroupInvitation(String groupDocId) async {
    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : await usersCollection.document(userId).get().then((userData) async {
            if (userData.exists) {
              DocumentReference groupMemberRef = groupsCollection
                  .document(groupDocId)
                  .collection(_members)
                  .document(userId);

              await groupMemberRef.updateData({
                'role': MemberRole.member.index,
                'name': userData.data['name'],
                'nickname': userData.data['name'],
              });
            }
          });
  }

  /// [Member] declines [Group] invitation
  Future declineGroupInvitation(String groupDocId) async {
    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : await groupsCollection.document(groupDocId).updateData({
            _members: FieldValue.arrayRemove([userId])
          }).then((_) async {
            await groupsCollection
                .document(groupDocId)
                .collection(_members)
                .document(userId)
                .delete();
          });
  }

  /// [Member] leaves [Group]
  Future leaveGroup(String groupDocId) async {
    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : await groupsCollection
            .document(groupDocId)
            .get()
            .then((groupData) async {
            if (groupData.exists) {
              await groupsCollection.document(groupDocId).updateData({
                _members: FieldValue.arrayRemove([userId])
              }).then((_) async {
                await groupsCollection
                    .document(groupDocId)
                    .collection(_members)
                    .document(userId)
                    .delete();
              });
            }
          });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////
  /// Modifying methods for Timetable
  ////////////////////////////////////////////////////////////////////////////////////////////////

  /// update [Group][Timetable]'s data
  Future updateGroupTimetable(
    String groupDocId,
    EditTimetable ttbStatus,
  ) async {
    CollectionReference timetablesRef =
        groupsCollection.document(groupDocId).collection(_timetables);

    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : await timetablesRef
            .document(ttbStatus.docId)
            .get()
            .then((timetable) async {
            /// update timetable metadata to Group
            await groupsCollection
                .document(groupDocId)
                .get()
                .then((group) async {
              /// update field value
              List<Map<String, dynamic>> timetableMetadatas =
                  _getUpdatedGroupTimetablesMetadatasAfterAdd(
                timetablesSnapshot: group.data[_timetables] ?? [],
                newTimetableMetadata: ttbStatus.metadata,
              );

              if (timetableMetadatas != null) {
                await groupsCollection.document(groupDocId).updateData(
                    {_timetables: timetableMetadatas}).then((_) async {
                  if (timetable.exists) {
                    await timetablesRef
                        .document(ttbStatus.docId)
                        .updateData(firestoreMapFromTimetable(ttbStatus));
                  } else {
                    await timetablesRef
                        .document(ttbStatus.docId)
                        .setData(firestoreMapFromTimetable(ttbStatus));
                  }
                });
              } else {
                throw Error();
              }
            });
          });
  }

  /// get updated [Group]'s [timetablesSnapshot] after adding new [TimetableMetadata]
  List<Map<String, dynamic>> _getUpdatedGroupTimetablesMetadatasAfterAdd({
    List<dynamic> timetablesSnapshot = const [],
    TimetableMetadata newTimetableMetadata,
    TimetableMetadata oldTimetableMetadata,
  }) {
    /// convert to [Lis<TimetableMetadata>]
    List<TimetableMetadata> timetableMetadatas =
        _timetableMetadatasFromDynamicList(timetablesSnapshot);

    /// remove previous metadata
    timetableMetadatas.removeWhere((meta) {
      if (oldTimetableMetadata != null) {
        return meta.id == oldTimetableMetadata.id;
      } else {
        return meta.id == newTimetableMetadata.id;
      }
    });

    /// add new metadata
    if (newTimetableMetadata != null) {
      timetableMetadatas.add(
        TimetableMetadata(
          id: newTimetableMetadata.id,
          startDate: newTimetableMetadata.startDate,
          endDate: newTimetableMetadata.endDate,
        ),
      );
    }

    /// update if timetable dates are consecutive
    if (isConsecutiveTimetables(timetableMetadatas)) {
      return List.generate(timetableMetadatas.length, (index) {
        return timetableMetadatas[index].asMap;
      });
    } else {
      return null;
    }
  }

  /// get updated [Group]'s [timetablesSnapshot] after removing [TimetableMetadata]
  List<Map<String, dynamic>> _getUpdatedGroupTimetablesMetadataAfterRemove({
    List<dynamic> timetablesSnapshot = const [],
    String timetableId = '',
  }) {
    /// convert to [Lis<TimetableMetadata>]
    List<TimetableMetadata> timetableMetadatas =
        _timetableMetadatasFromDynamicList(timetablesSnapshot);

    timetableMetadatas.removeWhere((timetableMetadata) {
      return timetableMetadata.id == timetableId;
    });

    return List.generate(timetableMetadatas.length, (index) {
      return timetableMetadatas[index].asMap;
    });
  }

  /// update [Group][Timetable]'s documentID by cloning document with a new ID
  Future<bool> updateGroupTimetableDocId(
    String groupDocId,
    TimetableMetadata oldTimetableMetadata,
    TimetableMetadata newTimetableMetadata,
  ) async {
    CollectionReference timetablesRef =
        groupsCollection.document(groupDocId).collection(_timetables);
    return groupDocId == null || groupDocId.trim() == ''
        ? false
        : await timetablesRef
            .document(newTimetableMetadata.id)
            .get()
            .then((groupData) async {
            /// If there is another timetable with the same ID
            /// Then, it doesn't replace the pre-existing timetable
            if (!groupData.exists) {
              await timetablesRef
                  .document(oldTimetableMetadata.id)
                  .get()
                  .then((groupData) async {
                await timetablesRef
                    .document(newTimetableMetadata.id)
                    .setData(groupData.data);

                await timetablesRef.document(oldTimetableMetadata.id).delete();

                await groupsCollection
                    .document(groupDocId)
                    .get()
                    .then((group) async {
                  await groupsCollection.document(groupDocId).updateData({
                    _timetables: _getUpdatedGroupTimetablesMetadatasAfterAdd(
                      timetablesSnapshot: group.data[_timetables],
                      newTimetableMetadata: newTimetableMetadata,
                      oldTimetableMetadata: oldTimetableMetadata,
                    )
                  });
                });
              });
              return true;
            } else {
              return false;
            }
          });
  }

  Future deleteGroupTimetable(
    String groupDocId,
    String timetableId,
  ) async {
    return await groupsCollection
        .document(groupDocId)
        .collection(_timetables)
        .document(timetableId)
        .delete()
        .then((_) {
      groupsCollection.document(groupDocId).get().then((group) async {
        return await groupsCollection.document(groupDocId).updateData({
          _timetables: _getUpdatedGroupTimetablesMetadataAfterRemove(
            timetablesSnapshot: group.data[_timetables],
            timetableId: timetableId,
          )
        });
      });
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////
  /// Modifying methods for Times
  ////////////////////////////////////////////////////////////////////////////////////////////////

  /// update [Group][Member]'s available schedule times
  Future updateGroupMemberTimes(
    String groupDocId,
    String memberDocId,
    List<Time> newTimes,
  ) async {
    memberDocId =
        memberDocId == null || memberDocId.trim() == '' ? userId : memberDocId;

    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : await groupsCollection
            .document(groupDocId)
            .collection(_members)
            .document(memberDocId)
            .get()
            .then((member) async {
            if (member.exists) {
              List<Time> prevTimes;
              List<Time> timesRemoveSameDay;
              List<Map<String, Timestamp>> timestamps = [];

              if (member.data['times'] != null) {
                /// get previous times
                prevTimes = _timesFromDynamicList(member.data['times']);

                /// generate new times that overwrites previous times on the same day
                timesRemoveSameDay =
                    generateTimesRemoveSameDay(prevTimes, newTimes);

                /// remove previous times
                await groupsCollection
                    .document(groupDocId)
                    .collection(_members)
                    .document(memberDocId)
                    .updateData({'times': FieldValue.delete()});

                /// convert [List<Time>] into [List<Map<String, Timestamp>] to be stored in Firestore
                timesRemoveSameDay.forEach((time) {
                  Timestamp startTimestamp = Timestamp.fromDate(time.startTime);
                  Timestamp endTimestamp = Timestamp.fromDate(time.endTime);
                  timestamps.add({
                    'startTime': startTimestamp,
                    'endTime': endTimestamp,
                  });
                });
              } else {
                /// convert [List<Time>] into [List<Map<String, Timestamp>] to be stored in Firestore
                newTimes.forEach((time) {
                  Timestamp startTimestamp = Timestamp.fromDate(time.startTime);
                  Timestamp endTimestamp = Timestamp.fromDate(time.endTime);
                  timestamps.add({
                    'startTime': startTimestamp,
                    'endTime': endTimestamp,
                  });
                });
              }

              /// add new times to Firestore
              await groupsCollection
                  .document(groupDocId)
                  .collection(_members)
                  .document(memberDocId)
                  .updateData({'times': FieldValue.arrayUnion(timestamps)});
            }
          });
  }

  /// remove [Group][Member]'s available schedule times
  Future removeGroupMemberTimes(
    String groupDocId,
    String memberDocId,
    List<Time> removeTimes,
  ) async {
    memberDocId =
        memberDocId == null || memberDocId.trim() == '' ? userId : memberDocId;

    List<Time> prevTimes = [];
    List<Time> timesOnSameDay = [];
    List<Map<String, Timestamp>> removeTimestamps = [];

    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : await groupsCollection
            .document(groupDocId)
            .collection(_members)
            .document(memberDocId)
            .get()
            .then((member) async {
            if (member.data['times'] != null) {
              prevTimes = _timesFromDynamicList(member.data['times']);

              for (int p = 0; p < prevTimes.length; p++) {
                for (int r = 0; r < removeTimes.length; r++) {
                  /// keep times with times on same day
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
                    /// add to list
                    timesOnSameDay.add(prevTimes[p]);
                  }
                }
              }

              /// convert [List<Time>] to [List<Map<String, Timestamp>]
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
                  .collection(_members)
                  .document(memberDocId)
                  .updateData(
                      {'times': FieldValue.arrayRemove(removeTimestamps)});
            }
          });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////
  /// Auxiliary methods
  ////////////////////////////////////////////////////////////////////////////////////////////////

  /// convert snapshot to [User]
  User _userFromSnapshot(DocumentSnapshot snapshot) {
    return snapshot.data != null
        ? User(
            email: snapshot.documentID ?? '',
            name: snapshot.data['name'] ?? '',
          )
        : User();
  }

  /// convert snapshot to [Group]
  Group _groupFromSnapshot(DocumentSnapshot snapshot) {
    return snapshot.data != null
        ? Group(
            docId: snapshot.documentID,
            name: snapshot.data['name'] ?? '',
            description: snapshot.data['description'] ?? '',
            colorShade: ColorShade(
              themeId: snapshot.data['colorShade']['themeId'],
              shade: Shade.values[snapshot.data['colorShade']['shade']],
            ),
            ownerEmail: snapshot.data['owner']['email'] ?? '',
            ownerName: snapshot.data['owner']['name'] ?? '',
            members: _stringsFromDynamicList(snapshot.data[_members] ?? []),
            timetableMetadatas: _timetableMetadatasFromDynamicList(
                snapshot.data[_timetables] ?? []),
          )
        : Group(docId: null);
  }

  /// convert snapshot to [Member]
  Member _memberFromSnapshot(DocumentSnapshot snapshot) {
    return snapshot.data != null
        ? Member(
            email: snapshot.documentID,
            name: snapshot.data['name'],
            nickname: snapshot.data['nickname'] ?? snapshot.data['name'],
            description: snapshot.data['description'],
            role: MemberRole.values[snapshot.data['role']],
            // colorShade: ColorShade(
            //   themeId: snapshot.data['colorShade']['themeId'],
            //   shade: snapshot.data['colorShade']['shade'],
            // ),
            times: _timesFromDynamicList(snapshot.data['times'] ?? []),
          )
        : Member(email: null);
  }

  /// convert snapshot to [Timetable]
  Timetable _timetableFromSnapshot(DocumentSnapshot snapshot) {
    return snapshot.data != null
        ? Timetable(
            docId: snapshot.documentID,
            startDate: snapshot.data['startDate'] ?? null,
            endDate: snapshot.data['endDate'] ?? null,
            axisDay: _weekdaysFromDynamicList(snapshot.data['axisDay'] ?? []),
            axisTime: _timesFromDynamicList(snapshot.data['axisTime'] ?? []),
            axisCustom:
                _stringsFromDynamicList(snapshot.data['axisCustom'] ?? []),
          )
        : Timetable(docId: '');
  }

  /// convert document snapshots into [User]s
  List<User> _usersFromSnapshots(QuerySnapshot query) {
    return query.documents.map(_userFromSnapshot).toList();
  }

  /// convert document snapshots into [Group]s
  List<Group> _groupsFromSnapshots(QuerySnapshot query) {
    return query.documents.map(_groupFromSnapshot).toList();
  }

  /// convert document snapshots into [Member]s
  List<Member> _membersFromSnapshots(QuerySnapshot query) {
    return query.documents.map(_memberFromSnapshot).toList();
  }

  /// convert [List<dynamic>] into [List<TimetableMetadata]
  List<TimetableMetadata> _timetableMetadatasFromDynamicList(
      List<dynamic> timetables) {
    List<TimetableMetadata> timetableMetadatas = [];

    timetables.forEach((elem) {
      Map map = elem as Map;
      timetableMetadatas.add(
        TimetableMetadata(
          id: map['id'],
          startDate: map['startDate'],
          endDate: map['endDate'],
        ),
      );
    });

    return timetableMetadatas;
  }

  /// convert [List<dynamic>] into [List<Weekday]
  List<Weekday> _weekdaysFromDynamicList(List<dynamic> weekdaysDynamic) {
    List<Weekday> weekdays = [];

    weekdaysDynamic.forEach((elem) => weekdays.add(Weekday.values[elem]));

    return weekdays;
  }

  /// convert [List<dynamic>] into [List<Time>]
  List<Time> _timesFromDynamicList(List<dynamic> timesDynamic) {
    List<Time> times = [];

    timesDynamic.forEach((elem) {
      Map map = elem as Map;
      times.add(
        Time(
          map['startTime'].toDate(),
          map['endTime'].toDate(),
        ),
      );
    });

    return times;
  }

  /// convert [List<String>] into [List<String>]
  List<String> _stringsFromDynamicList(List<dynamic> list) {
    List<String> listStr = [];

    list.forEach((elem) => listStr.add(elem as String));

    return listStr;
  }
}
