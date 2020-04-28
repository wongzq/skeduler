class Subject {
  String _name;
  String _nickname;

  Subject({
    String name,
    String nickname,
  })  : this._name = name ?? nickname,
        this._nickname = nickname ?? name;

  String get name => this._name;
  String get nickname => this._nickname;
  String get display => this._nickname ?? this._name ?? '';

  Map<String, dynamic> get asMap => {
        'name': _name,
        'nickname': _nickname,
      };
}
