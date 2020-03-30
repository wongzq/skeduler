import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skeduler/models/group.dart';
import 'package:skeduler/models/my_app_themes.dart';
import 'package:skeduler/models/user.dart';

class DatabaseService {
  /// properties
  final String uid;

  /// constructor
  DatabaseService({this.uid});

  /// collection reference
  final CollectionReference usersCollection =
      Firestore.instance.collection('users');
  final CollectionReference groupsCollection =
      Firestore.instance.collection('groups');

  /// getter methods
  /// get user data
  Stream<User> get user {
    return usersCollection.document(uid).snapshots().map(_userFromSnapshot);
  }

  /// convert snapshot to [AuthUser]
  User _userFromSnapshot(DocumentSnapshot snapshot) {
    return User(
      uid: uid ?? '',
      email: snapshot.data['email'] ?? '',
      name: snapshot.data['name'] ?? '',
    );
  }

  /// get groups
  Stream<List<Group>> get groups {
    return groupsCollection.snapshots().map(_groupsFromSnapshot);
  }

  /// convert document snapshots into [Group]s
  List<Group> _groupsFromSnapshot(QuerySnapshot query) {
    return query.documents.map(_groupFromSnapshot).toList();
  }

  /// get group data
  Stream<Group> getGroupData(String groupId) {
    return groupsCollection
        .document(groupId)
        .snapshots()
        .map(_groupFromSnapshot);
  }

  /// convert snapshot to [Group]
  Group _groupFromSnapshot(DocumentSnapshot snapshot) {
    return Group(
      name: snapshot.data['name'] ?? '',
      colorStr: snapshot.data['color'] ?? '',
      colorInt: snapshot.data['colorType'] ?? 0,
      ownerEmail: snapshot.data['ownerEmail'] ?? '',
      ownerName: snapshot.data['ownerName'] ?? '',
    );
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
    String color,
    int colorType,
    String ownerEmail,
    String ownerName,
  ) async {
    return await groupsCollection.document().setData({
      'name': name,
      'description': description,
      'color': color,
      'colorType': colorType,
      'ownerEmail': ownerEmail,
      'ownerName': ownerName,
    });
  }

  /// update [Group] data
  Future updateGroupData(
    String groupId, {
    String name,
    String description,
    String color,
    int colorType,
    String groupOwnerEmail,
  }) async {
    return await groupsCollection.document(groupId).updateData({
      'name': name,
      'description': description,
      'color': color,
      'colorType': colorType,
      'owner': groupOwnerEmail,
    });
  }
}
