class AuthUser {
  final String uid;
  final String email;

  AuthUser({this.uid, this.email});
}

class User {
  String _email;
  String _name;

  User({
    email = '',
    name = '',
  }) {
    _email = email;
    _name = name;
  }

  // getter methods
  String get email => _email;
  String get name => _name;
}
