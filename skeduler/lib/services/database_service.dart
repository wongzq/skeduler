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

  /// constructor method
  DatabaseService({this.userId});

  ////////////////////////////////////////////////////////////////////////////////////////////////
  /// Collection References
  ////////////////////////////////////////////////////////////////////////////////////////////////

  /// collection reference
  final CollectionReference usersCollection =
      Firestore.instance.collection('users');
  final CollectionReference groupsCollection =
      Firestore.instance.collection('groups');

  ////////////////////////////////////////////////////////////////////////////////////////////////
  /// Getter methods
  ////////////////////////////////////////////////////////////////////////////////////////////////

  /// getter methods
  /// get [User] data
  Stream<User> get user {
    return usersCollection.document(userId).snapshots().map(_userFromSnapshot);
  }

  /// get ['users'] collection
  Stream<List<User>> get users {
    return usersCollection.snapshots().map(_usersFromSnapshots);
  }

  /// get ['groups'] collection
  Stream<List<Group>> get groups {
    return groupsCollection
        .where('members', arrayContains: userId)
        .snapshots()
        .map(_groupsFromSnapshots);
  }

  /// get [Group] data
  Stream<Group> getGroup(String groupDocId) {
    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : groupsCollection
            .document(groupDocId)
            .snapshots()
            .map(_groupFromSnapshot);
  }

  /// get [Group][Member] data of me
  Stream<Member> getGroupMemberMyData(String groupDocId) {
    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : groupsCollection
            .document(groupDocId)
            .collection('members')
            .document(userId)
            .snapshots()
            .map(_memberFromSnapshot);
  }

  /// get [Group][Member]s' data
  Stream<List<Member>> getGroupMembers(String groupDocId) {
    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : groupsCollection
            .document(groupDocId)
            .collection('members')
            .snapshots()
            .map(_membersFromSnapshots);
  }

  /// get [Group][Timetable] data
  Stream<List<Timetable>> getGroupTimetables(String groupDocId) {
    return groupDocId == null || groupDocId.trim() == ''
        ? null
        : groupsCollection
            .document(groupDocId)
            .collection('timetables')
            .snapshots()
            .map(_timetablesFromSnapshots);
  }

  Future<Timetable> getGroupTimetable(String groupDocId, String timetableDocId) async {
    if (groupDocId == null ||
        groupDocId.trim() == '' ||
        timetableDocId == null ||
        timetableDocId.trim() == '') {
      return null;
    } else {
      return await groupsCollection
          .document(groupDocId)
          .collection('timetables')
          .document(timetableDocId)
          .get()
          .then((timetable) {
        if (timetable.exists) {
          return _timetableFromSnapshot(timetable);
        } else {
          return null;
        }
      });
    }
  }

  Stream<List<Timetable>> getGroupTimetableForToday(String groupDocId) {
    return groupDocId != null && groupDocId.trim() != ''
        ? groupsCollection
            .document(groupDocId)
            .collection('timetables')
            .where('startTime', isLessThanOrEqualTo: Timestamp.now())
            .where('endTime', isGreaterThanOrEqualTo: Timestamp.now())
            .limit(1)
            .snapshots()
            .map(_timetablesFromSnapshots)
        : null;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////
  /// Setter methods
  ////////////////////////////////////////////////////////////////////////////////////////////////

  /// setter methods
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
      'members': [ownerEmail],
    }).then((onValue) async {
      await inviteMemberToGroup(
        groupDocId: newGroupDoc.documentID,
        newMemberEmail: ownerEmail,
        memberRole: MemberRole.owner,
      );
      await usersCollection.document(userId).get().then((onValue) async {
        await groupsCollection
            .document(newGroupDoc.documentID)
            .collection('members')
            .document(userId)
            .updateData({
          'name': onValue.data['name'],
          'nickname': onValue.data['name'],
        });
      });
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////
  /// Modifying methods
  ////////////////////////////////////////////////////////////////////////////////////////////////

  /// update [User] data
  Future updateUserData({String name}) async {
    return await usersCollection.document(userId).updateData({
      'name': name,
    });
  }

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

  /// add [User] to [Group]
  Future<String> inviteMemberToGroup({
    @required String groupDocId,
    @required String newMemberEmail,
    MemberRole memberRole = MemberRole.pending,
  }) async {
    String errorMsg;

    DocumentReference groupMemberRef = groupsCollection
        .document(groupDocId)
        .collection('members')
        .document(newMemberEmail);

    await usersCollection.document(newMemberEmail).get().then((user) async {
      if (user.exists) {
        await groupMemberRef.get().then((member) async {
          if (!member.exists) {
            await groupsCollection.document(groupDocId).updateData({
              'members': FieldValue.arrayUnion([newMemberEmail])
            });
            await groupMemberRef.setData({'role': memberRole.index});
          } else {
            errorMsg = 'User is already in the group';
          }
        });
      } else {
        errorMsg = 'User not found';
      }
    });
    return errorMsg;
  }

  /// remove [User] from [Group]
  Future removeMemberFromGroup({
    @required String groupDocId,
    @required String memberDocId,
  }) async {
    await groupsCollection.document(groupDocId).updateData({
      'members': FieldValue.arrayRemove([memberDocId])
    });
    return await groupsCollection
        .document(groupDocId)
        .collection('members')
        .document(memberDocId)
        .delete();
  }

  Future changeMemberRoleInGroup({
    @required String groupDocId,
    @required String memberDocId,
    @required MemberRole role,
  }) async {
    return await groupsCollection
        .document(groupDocId)
        .collection('members')
        .document(memberDocId)
        .updateData({'role': role.index});
  }

  Future acceptGroupInvitation(String groupDocId) async {
    if (groupDocId == null || groupDocId.trim() == '') {
      return null;
    } else {
      return await usersCollection.document(userId).get().then((onValue) async {
        if (onValue.exists) {
          DocumentReference groupMemberRef = groupsCollection
              .document(groupDocId)
              .collection('members')
              .document(userId);

          await groupMemberRef.updateData({
            'role': MemberRole.member.index,
            'name': onValue.data['name'],
            'nickname': onValue.data['name'],
          });
        }
      });
    }
  }

  Future declineGroupInvitation(String groupDocId) async {
    if (groupDocId == null || groupDocId.trim() == '') {
      return null;
    } else {
      await groupsCollection.document(groupDocId).updateData({
        'members': FieldValue.arrayRemove([userId])
      });

      return await groupsCollection
          .document(groupDocId)
          .collection('members')
          .document(userId)
          .delete();
    }
  }

  Future deleteGroup(String groupDocId) async {
    // Cloud function to delete all subcollections
    // temporary replacement
    if (groupDocId == null || groupDocId.trim() == '') {
      return null;
    } else {
      await groupsCollection
          .document(groupDocId)
          .collection('members')
          .getDocuments()
          .then((onValue) {
        for (DocumentSnapshot snap in onValue.documents) {
          snap.reference.delete();
        }
      });

      return await groupsCollection.document(groupDocId).delete();
    }
  }

  Future leaveGroup(String groupDocId) async {
    if (groupDocId == null || groupDocId.trim() == '') {
      return null;
    } else {
      return await groupsCollection
          .document(groupDocId)
          .get()
          .then((onValue) async {
        if (onValue.exists) {
          await groupsCollection.document(groupDocId).updateData({
            'members': FieldValue.arrayRemove([userId])
          });
          await groupsCollection
              .document(groupDocId)
              .collection('members')
              .document(userId)
              .delete();
        }
      });
    }
  }

  Future updateGroupTimetable(
    String groupDocId,
    TempTimetable tempTimetable,
  ) async {
    if (groupDocId != null && groupDocId.trim() != '') {
      DocumentReference timetableRef = groupsCollection
          .document(groupDocId)
          .collection('timetables')
          .document(tempTimetable.docId);

      return await timetableRef.get().then((timetable) async {
        if (!timetable.exists) {
          await timetableRef.setData(firestoreMapFromTimetable(tempTimetable));
          await groupsCollection.document(groupDocId).updateData({
            'timetables': FieldValue.arrayUnion([tempTimetable.docId])
          });
        } else {
          await timetableRef
              .updateData(firestoreMapFromTimetable(tempTimetable));
        }
      });
    } else {
      return null;
    }
  }

  Future updateGroupTimetableDocId(
    String groupDocId,
    String oldTimetableId,
    String newTimetableId,
  ) async {
    if (groupDocId != null && groupDocId.trim() != '') {
      CollectionReference timetablesRef =
          groupsCollection.document(groupDocId).collection('timetables');
      return await timetablesRef
          .document(oldTimetableId)
          .get()
          .then((groupData) async {
        await timetablesRef.document(newTimetableId).setData(groupData.data);

        await groupsCollection.document(groupDocId).updateData({
          'timetables': FieldValue.arrayRemove([oldTimetableId])
        });

        await groupsCollection.document(groupDocId).updateData({
          'timetables': FieldValue.arrayUnion([newTimetableId])
        });
      });
    } else {
      return null;
    }
  }

  Future updateGroupMemberTimes(
    String groupDocId,
    String memberDocId,
    List<Time> newTimes,
  ) async {
    memberDocId =
        memberDocId == null || memberDocId.trim() == '' ? userId : memberDocId;

    if (groupDocId != null && groupDocId.trim() != '') {
      return await groupsCollection
          .document(groupDocId)
          .collection('members')
          .document(memberDocId)
          .get()
          .then((member) async {
        if (member.exists) {
          List<Time> prevTimes;
          List<Time> timesRemoveSameDay;
          List<Map<String, Timestamp>> timestamps = [];

          if (member.data['times'] != null) {
            prevTimes = _timesFromDynamicList(member.data['times']);
            timesRemoveSameDay =
                generateTimesRemoveSameDay(prevTimes, newTimes);

            /// remove previous times
            await groupsCollection
                .document(groupDocId)
                .collection('members')
                .document(memberDocId)
                .updateData({'times': FieldValue.delete()});

            timesRemoveSameDay.forEach((time) {
              Timestamp startTimestamp =
                  Timestamp(time.startTime.millisecondsSinceEpoch ~/ 1000, 0);
              Timestamp endTimestamp =
                  Timestamp(time.endTime.millisecondsSinceEpoch ~/ 1000, 0);

              timestamps
                  .add({'startTime': startTimestamp, 'endTime': endTimestamp});
            });
          } else {
            newTimes.forEach((time) {
              Timestamp startTimestamp =
                  Timestamp(time.startTime.millisecondsSinceEpoch ~/ 1000, 0);
              Timestamp endTimestamp =
                  Timestamp(time.endTime.millisecondsSinceEpoch ~/ 1000, 0);

              timestamps
                  .add({'startTime': startTimestamp, 'endTime': endTimestamp});
            });
          }

          /// add new times
          await groupsCollection
              .document(groupDocId)
              .collection('members')
              .document(memberDocId)
              .updateData({'times': FieldValue.arrayUnion(timestamps)});
        }
      });
    } else {
      return null;
    }
  }

  Future removeGroupMemberTimes(
    String groupDocId,
    String memberDocId,
    List<Time> removeTimes,
  ) async {
    memberDocId =
        memberDocId == null || memberDocId.trim() == '' ? userId : memberDocId;

    List<Time> prevTimes = [];
    List<Time> timesOfSameDay = [];
    List<Map<String, Timestamp>> removeTimestamps = [];

    if (groupDocId != null && groupDocId.trim() != '') {
      return await groupsCollection
          .document(groupDocId)
          .collection('members')
          .document(memberDocId)
          .get()
          .then((member) async {
        if (member.data['times'] != null) {
          prevTimes = _timesFromDynamicList(member.data['times']);

          for (int p = 0; p < prevTimes.length; p++) {
            for (int r = 0; r < removeTimes.length; r++) {
              if ((prevTimes[p].startTime.year ==
                          removeTimes[r].startTime.year &&
                      prevTimes[p].startTime.month ==
                          removeTimes[r].startTime.month &&
                      prevTimes[p].startTime.day ==
                          removeTimes[r].startTime.day) ||
                  (prevTimes[p].endTime.year == removeTimes[r].endTime.year &&
                      prevTimes[p].endTime.month ==
                          removeTimes[r].endTime.month &&
                      prevTimes[p].endTime.day == removeTimes[r].endTime.day)) {
                timesOfSameDay.add(prevTimes[p]);
              }
            }
          }

          timesOfSameDay.forEach((time) {
            Timestamp startTimestamp =
                Timestamp(time.startTime.millisecondsSinceEpoch ~/ 1000, 0);
            Timestamp endTimestamp =
                Timestamp(time.endTime.millisecondsSinceEpoch ~/ 1000, 0);

            Map<String, Timestamp> removeTimestamp = {
              'startTime': startTimestamp,
              'endTime': endTimestamp
            };

            removeTimestamps.add(removeTimestamp);
          });

          await groupsCollection
              .document(groupDocId)
              .collection('members')
              .document(memberDocId)
              .updateData({'times': FieldValue.arrayRemove(removeTimestamps)});
        }
      });
    } else {
      return null;
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////
  /// Auxiliary methods
  ////////////////////////////////////////////////////////////////////////////////////////////////

  /// auxiliary methods
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
            groupDocId: snapshot.documentID,
            name: snapshot.data['name'] ?? '',
            description: snapshot.data['description'] ?? '',
            colorShade: ColorShade(
              themeId: snapshot.data['colorShade']['themeId'],
              shade: Shade.values[snapshot.data['colorShade']['shade']],
            ),
            ownerEmail: snapshot.data['owner']['email'] ?? '',
            ownerName: snapshot.data['owner']['name'] ?? '',
            members: snapshot.data['members'] ?? [],
            timetables: snapshot.data['timetables'] ?? [],
          )
        : Group(groupDocId: null);
  }

  Member _memberFromSnapshot(DocumentSnapshot snapshot) {
    return snapshot.data != null
        ? Member(
            email: snapshot.documentID,
            name: snapshot.data['name'],
            nickname: snapshot.data['nickname'] ?? snapshot.data['name'],
            description: snapshot.data['description'],
            role: MemberRole.values[snapshot.data['role']],
            colorShade: snapshot.data['colorShade'] != null
                ? ColorShade(
                    themeId: snapshot.data['colorShade']['themeId'],
                    shade: snapshot.data['colorShade']['shade'],
                  )
                : null,
            times: _timesFromDynamicList(snapshot.data['times'] ?? []),
          )
        : Member(email: null);
  }

  Timetable _timetableFromSnapshot(DocumentSnapshot snapshot) {
    return snapshot.data != null
        ? Timetable(
            docId: snapshot.documentID,
            startDate: snapshot.data['startDate'] ?? Timestamp.now(),
            endDate: snapshot.data['endDate'] ?? Timestamp.now(),
            axisDays: snapshot.data['axisDays'] ?? [],
            axisTimes: snapshot.data['axisTimes'] ?? [],
            axisCustom: snapshot.data['axisCustom'] ?? [],
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

  /// convert document snapshots into [Timetable]s
  List<Timetable> _timetablesFromSnapshots(QuerySnapshot query) {
    return query.documents.map(_timetableFromSnapshot).toList();
  }

  List<Time> _timesFromDynamicList(List timesDynamic) {
    List<Time> times = [];

    timesDynamic.forEach((elem) {
      Map map = elem as Map;

      times.add(Time(map['startTime'].toDate(), map['endTime'].toDate()));
    });

    return times;
  }
}
