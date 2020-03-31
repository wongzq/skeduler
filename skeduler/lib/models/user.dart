class AuthUser {
  final String uid;

  AuthUser({this.uid});
}

class User {
  String _uid;
  String _email;
  String _name;

  User({
    uid = '',
    email = '',
    name = '',
  }) {
    _uid = uid;
    _email = email;
    _name = name;
  }

  /// getter methods
  String get uid => _uid;
  String get email => _email;
  String get name => _name;
}
