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
    this._email = email;
    this._name = name;
  }

  // getter methods
  String get email => this._email;
  String get name => this._name;
}
