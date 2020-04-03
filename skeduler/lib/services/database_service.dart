import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skeduler/models/color_shade.dart';
import 'package:skeduler/models/group.dart';
import 'package:skeduler/models/user.dart';

class DatabaseService {
  /// properties
  final String userId;

  /// collection reference
  final CollectionReference usersCollection =
      Firestore.instance.collection('users');
  final CollectionReference groupsCollection =
      Firestore.instance.collection('groups');

  /// constructor method
  DatabaseService({this.userId});

  /// getter methods
  /// get [User] data
  Stream<User> get user {
    return usersCollection.document(userId).snapshots().map(_userFromSnapshot);
  }

  /// get [Group] data
  Stream<Group> getGroup(String groupDocId) {
    return groupsCollection
        .document(groupDocId)
        .snapshots()
        .map(_groupFromSnapshot);
  }

  /// get ['users'] collection
  Stream<List<User>> get users {
    return usersCollection.snapshots().map(_usersFromSnapshot);
  }

  /// get ['groups'] collection
  Stream<List<Group>> get groups {
    return groupsCollection.snapshots().map(_groupsFromSnapshot);
  }

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
    return await groupsCollection.document().setData({
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
    });
  }

  Future deleteGroup(String docId) async {
    return await groupsCollection.document(docId).delete();
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
  Future<String> addMemberToGroup(
    String groupDocId,
    String newMemberEmail,
  ) async {
    String errorMsg;
    DocumentReference groupRef = groupsCollection.document(groupDocId);
    try {
      await groupRef.get().then((group) async {
        if (group.exists) {
          if (!(group.data['members'] as List).contains(newMemberEmail)) {
            await usersCollection.document(newMemberEmail).get().then((user) {
              if (user.exists) {
                groupRef.updateData({
                  'members': FieldValue.arrayUnion([user.documentID]),
                });
              } else {
                errorMsg = 'User not found';
                throw Exception();
              }
            });
          } else {
            errorMsg = 'User is already in the group';
            throw Exception();
          }
        } else {
          errorMsg = 'Group not found';
          throw Exception();
        }
      });
      return null;
    } catch (e) {
      return errorMsg;
    }
  }

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
            snapshot.documentID,
            name: snapshot.data['name'] ?? '',
            description: snapshot.data['description'] ?? '',
            colorShade: ColorShade(
              themeId: snapshot.data['colorShade']['themeId'],
              shade: Shade.values[snapshot.data['colorShade']['shade']],
            ),
            ownerEmail: snapshot.data['owner']['email'] ?? '',
            ownerName: snapshot.data['owner']['name'] ?? '',
          )
        : Group('');
  }

  /// convert document snapshots into [User]s
  List<User> _usersFromSnapshot(QuerySnapshot query) {
    return query.documents.map(_userFromSnapshot).toList();
  }

  /// convert document snapshots into [Group]s
  List<Group> _groupsFromSnapshot(QuerySnapshot query) {
    return query.documents.map(_groupFromSnapshot).toList();
  }
}
