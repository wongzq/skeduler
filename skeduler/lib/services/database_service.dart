import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/member.dart';
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
    return groupsCollection
        .document(groupDocId)
        .snapshots()
        .map(_groupFromSnapshot);
  }

  /// get [Group][Member] data of me
  Stream<Member> getGroupMemberMyData(String groupDocId) {
    return groupsCollection
        .document(groupDocId)
        .collection('members')
        .document(userId)
        .snapshots()
        .map(_memberFromSnapshot);
  }

  /// get [Group][Member]s' data
  Stream<List<Member>> getGroupMembers(String groupDocId) {
    return groupsCollection
        .document(groupDocId)
        .collection('members')
        .snapshots()
        .map(_membersFromSnapshots);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////
  /// Setter methods
  ////////////////////////////////////////////////////////////////////////////////////////////////

  /// setter methods
  /// set [User] data
  Future setUserData(
    String email,
    String name,
  ) async {
    return await usersCollection.document(email).setData({
      'name': name,
    });
  }

  /// update [User] data
  Future updateUserData({
    String name,
  }) async {
    return await usersCollection.document(userId).updateData({
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
    }).then((onValue) {
      addMemberToGroup(
        groupDocId: newGroupDoc.documentID,
        newMemberEmail: ownerEmail,
        memberRole: MemberRole.owner,
      );
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////
  /// Modifying methods
  ////////////////////////////////////////////////////////////////////////////////////////////////

  Future deleteGroup(String groupDocId) async {
    // Cloud function to delete all subcollections
    // temporary replacement
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

  Future leaveGroup(String groupDocId) async {
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

  /// update [Group] data
  Future updateGroupData(
    String groupDocId, {
    String name,
    String description,
    ColorShade colorShade,
    String ownerEmail,
    String ownerName,
  }) async {
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

  /// add [User] to [Group]
  Future<String> addMemberToGroup({
    @required String groupDocId,
    @required String newMemberEmail,
    MemberRole memberRole = MemberRole.pending,
  }) async {
    DocumentReference groupMemberRef = groupsCollection
        .document(groupDocId)
        .collection('members')
        .document(newMemberEmail);
    String errorMsg;

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

  ////////////////////////////////////////////////////////////////////////////////////////////////
  /// Auxiliary methods
  ////////////////////////////////////////////////////////////////////////////////////////////////

  /// auxiliary methods
  Future<DocumentSnapshot> findGroup(String groupDocId) async {
    return await groupsCollection.document(groupDocId).get();
  }

  Future<DocumentSnapshot> findUser(String userId) async {
    return await usersCollection.document(userId).get();
  }

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
          )
        : Member(email: null);
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
}
