import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skeduler/models/group.dart';
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

  /// get group data
  Stream<Group> getGroupData(String groupId) {
    return groupsCollection.document(groupId).snapshots().map(_groupFromSnapshot);
  }

  /// convert snapshot to [AuthUser]
  User _userFromSnapshot(DocumentSnapshot snapshot) {
    return User(
      uid: uid ?? '',
      email: snapshot.data['email'] ?? '',
      name: snapshot.data['name'] ?? '',
    );
  }

  /// convert snapshot to [Group]
  Group _groupFromSnapshot(DocumentSnapshot snapshot) {
    return Group();
  }

  /// setter methods
  /// update [User] data
  Future initUserData({
    String email,
    String name,
  }) async {
    return await usersCollection.document(uid).setData({
      'email': email,
      'name': name,
    });
  }

  Future updateUserData({
    String name,
  }) async {
    return await usersCollection.document(uid).updateData({
      'name': name,
    });
  }

  /// update [Group] data
  Future updateGroupData(
    String groupId, {
    String name,
    String description,
    String color,
  }) async {
    return await groupsCollection.document(groupId).setData({
      'name': name,
      'description': description,
      'color': color,
    });
  }
}
