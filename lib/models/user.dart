class User {
  static final String _keyId = 'uuid';
  static final String _keyIdNo = 'idNo';
  static final String _keySName = 'sName';
  static final String _keyFName = 'fName';
  static final String _keyLName = 'lName';
  static final String _keyEmail = 'email';
  static final String _keyRole = 'role';
  static final String _keyMobileNo = 'mobileNo';
  static final String _keyVerified = 'verified';
  static final String _keyPassword = 'password';
  static final String _keyImage = 'image';

  String _id;
  String _idNo;
  String _sName;
  String _fName;
  String _lName;
  String _email;
  String _role;
  String _mobileNo;
  bool _isVerified = false;
  bool isSelected = false;

  User(this._id, this._idNo, this._sName, this._fName, this._lName, this._email,
      this._role, this._mobileNo, this._isVerified);

  User.serverParams(this._idNo, this._sName, this._fName, this._lName,
      this._email, this._role);

  User.fromMap(dynamic userMap) {
    this._id = userMap[_keyId];
    this._idNo = userMap[_keyIdNo];
    this._sName = userMap[_keySName];
    this._fName = userMap[_keyFName];
    this._lName = userMap[_keyLName];
    this._email = userMap[_keyEmail];
    this._role = userMap[_keyRole];
    this._mobileNo = userMap[_keyMobileNo];
    this._isVerified = userMap[_keyVerified] == 1 ? true : false;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map[_keyId] = this.id;
    map[_keyIdNo] = this.idNo;
    map[_keySName] = this.sName;
    map[_keyFName] = this.fName;
    map[_keyLName] = this.lName;
    map[_keyEmail] = this.email;
    map[_keyRole] = this.role;
    map[_keyMobileNo] = this.mobileNo;
    map[_keyVerified] = this.isVerified;

    return map;
  }

  Map<String, dynamic> toMapForProfileUpdate({String image = ""}) {
    Map<String, dynamic> map = Map();
    map[_keyId] = this.id;
    map[_keySName] = this.sName;
    map[_keyFName] = this.fName;
    map[_keyLName] = this.lName;
    map[_keyEmail] = this.email;
    map[_keyRole] = this.role;
    map[_keyMobileNo] = this.mobileNo;
    map[_keyImage] = image;

    return map;
  }

  Map<String, dynamic> toMapForSignUp(String password) {
    Map<String, dynamic> map = Map();
    map[_keyIdNo] = this.idNo;
    map[_keySName] = this.sName;
    map[_keyFName] = this.fName;
    map[_keyLName] = this.lName;
    map[_keyEmail] = this.email;
    map[_keyRole] = this.role;
    map[_keyPassword] = password;

    return map;
  }

  bool get isVerified => _isVerified;

  String get mobileNo => _mobileNo;

  String get role => _role;

  String get email => _email;

  String get lName => _lName.isNotEmpty ? _lName : "";

  String get fName => _fName;

  String get sName => _sName.isNotEmpty ? _sName : "";

  String get idNo => _idNo;

  String get id => _id;
}
