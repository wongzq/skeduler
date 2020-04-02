import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skeduler/models/color_shade.dart';
import 'package:skeduler/models/group.dart';
import 'package:skeduler/models/user.dart';

class DatabaseService {
  /// properties
  final String uid;

  /// collection reference
  final CollectionReference usersCollection =
      Firestore.instance.collection('users');
  final CollectionReference groupsCollection =
      Firestore.instance.collection('groups');

  /// constructor method
  DatabaseService({this.uid});

  /// getter methods
  /// get [User] data
  Stream<User> get user {
    return usersCollection
        .document(uid)
        .snapshots()
        .map(_currentUserFromSnapshot);
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
    return await usersCollection.document(uid).setData({
      'email': email,
      'name': name,
    });
  }

  /// update [User] data
  Future updateUserData({
    String name,
  }) async {
    return await usersCollection.document(uid).updateData({
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

  /// auxiliary methods
  /// convert snapshot of [currentUser] to [User]
  User _currentUserFromSnapshot(DocumentSnapshot snapshot) {
    return User(
      uid: uid ?? '',
      email: snapshot.data['email'] ?? '',
      name: snapshot.data['name'] ?? '',
    );
  }

  /// convert snapshot to [User]
  User _userFromSnapshot(DocumentSnapshot snapshot) {
    return snapshot.data != null
        ? User(
            uid: snapshot.data['uid'] ?? '',
            email: snapshot.data['email'] ?? '',
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
