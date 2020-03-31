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
  Stream<Group> getGroup(String groupId) {
    return groupsCollection
        .document(groupId)
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
      'themeId': colorShade.themeId,
      'shade': colorShade.shadeIndex,
      'ownerEmail': ownerEmail,
      'ownerName': ownerName,
    });
  }

  /// update [Group] data
  Future updateGroupData(
    String groupId, {
    String name,
    String description,
    ColorShade colorShade,
    String ownerEmail,
    String ownerName,
  }) async {
    return await groupsCollection.document(groupId).updateData({
      'name': name,
      'description': description,
      'themeId': colorShade.themeId,
      'shade': colorShade.shade,
      'ownerEmail': ownerEmail,
      'ownerName': ownerName,
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
    return User(
      uid: snapshot.data['uid'] ?? '',
      email: snapshot.data['email'] ?? '',
      name: snapshot.data['name'] ?? '',
    );
  }

  /// convert snapshot to [Group]
  Group _groupFromSnapshot(DocumentSnapshot snapshot) {
    return Group(
      name: snapshot.data['name'] ?? '',
      description: snapshot.data['description'] ?? '',
      colorShade: ColorShade(
        themeId: snapshot.data['themeId'],
        shade: Shade.values[snapshot.data['shade'] as int],
      ),
      ownerEmail: snapshot.data['ownerEmail'] ?? '',
      ownerName: snapshot.data['ownerName'] ?? '',
    );
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
