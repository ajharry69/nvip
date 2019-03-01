class VaccineCenter {
  static final String _keyId = 'id';
  static final String _keyName = 'name';

  int _id = 0;
  String _name;
  bool isSelected = false;

  VaccineCenter(this._id, this._name);

  VaccineCenter.serverParams(this._name);

  VaccineCenter.fromMap(dynamic centerMap) {
    this._id = centerMap[_keyId];
    this._name = centerMap[_keyName];
  }

  Map<String, dynamic> toMap() => {
        _keyId: this.id.toString(),
        _keyName: this.name,
      };

  int get id => this._id;

  String get name => this._name;
}
