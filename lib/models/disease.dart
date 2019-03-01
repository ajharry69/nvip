import 'package:nvip/constants.dart';

class Disease {
  static final String _keyId = 'id';
  static final String _keyName = 'name';
  static final String _keyDescription = 'description';

  int _id = 0;
  String _name;
  String _description = "";
  bool isSelected = false;

  Disease(this._id, this._name, [this._description]);

  Disease.serverParams(this._name, [this._description]);

  Disease.fromMap(dynamic diseaseMap) {
    this._id = diseaseMap[_keyId];
    this._name = diseaseMap[_keyName];
    this._description = diseaseMap[_keyDescription];
  }

  Map<String, dynamic> toMapAdd(String userId) {
    Map<String, dynamic> map = Map();
    map[RestKeys.keyUserId] = userId;
    map.addAll(this.toMap());

    return map;
  }

//  Map<String, dynamic> toMapAdd(String userId) {
//    return {
//      RestKeys.keyUserId: userId,
//      _keyId: this.id.toString(),
//      _keyName: this.name,
//      _keyDescription: this.description,
//    };
//  }

  Map<String, dynamic> toMap() => {
        _keyId: this.id.toString(),
        _keyName: this.name,
        _keyDescription: this.description,
      };

  String get description => this._description;

  String get name => this._name;

  int get id => this._id;
}
