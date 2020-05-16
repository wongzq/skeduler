import 'package:skeduler/models/auxiliary/color_shade.dart';

class Subject {
  String _docId;
  String _name;
  String _nickname;
  ColorShade _colorShade;

  Subject({
    String docId,
    String name,
    String nickname,
    ColorShade colorShade,
  })  : this._docId = docId,
        this._name = name ?? nickname,
        this._nickname = nickname ?? name,
        this._colorShade = colorShade;

  String get docId => this._docId;
  String get name => this._name;
  String get nickname => this._nickname;
  String get display => this._nickname ?? this._name ?? '';
  ColorShade get colorShade => this._colorShade;

  Map<String, dynamic> get asMap => {
        'name': this._name,
        'nickname': this._nickname,
      };
}
