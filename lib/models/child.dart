import 'package:nvip/models/immunization_dose.dart';

class Child {
  static final String _keyId = 'cuid';
  static final String _keyBirthCertNo = 'birthCertNo';
  static final String _keySName = 'sName';
  static final String _keyFName = 'fName';
  static final String _keyLName = 'lName';
  static final String _keyGender = 'gender';
  static final String _keyDob = 'dob';
  static final String _keyAor = 'aor';
  static final String _keyFatherId = 'fatherId';
  static final String _keyMotherId = 'motherId';
  static final _keyImmunizationDoses = 'immunizationDoses';

  String _id = "";
  String _birthCertNo = "";
  String _sName = ""; // Sir name...
  String _fName = ""; // First name...
  String _lName = ""; // Last name...
  String _gender = ""; // Last name...
  String _dob = "";
  String _aor = "";
  String _fatherId = "";
  String _motherId = "";
  List<ImmunizationDose> _immunizationDoses = List();

  bool isSelected = false;

  Child(
      this._id,
      this._birthCertNo,
      this._sName,
      this._fName,
      this._lName,
      this._gender,
      this._dob,
      this._aor,
      this._fatherId,
      this._motherId,
      this._immunizationDoses);

  Child.serverParams(this._birthCertNo, this._sName, this._fName, this._lName,
      this._gender, this._dob, this._aor, this._fatherId, this._motherId,
      [this._immunizationDoses]);

  Child.fromMap(dynamic childMap) {
    List doses = childMap[_keyImmunizationDoses];
    this._id = childMap[_keyId];
    this._birthCertNo = childMap[_keyBirthCertNo];
    this._sName = childMap[_keySName];
    this._fName = childMap[_keyFName];
    this._lName = childMap[_keyLName];
    this._gender = childMap[_keyGender];
    this._dob = childMap[_keyDob];
    this._aor = childMap[_keyAor];
    this._fatherId = childMap[_keyFatherId];
    this._motherId = childMap[_keyMotherId];
    this._immunizationDoses =
        doses.map((dataMap) => ImmunizationDose.fromMap(dataMap)).toList();
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map[_keyId] = this.id;
    map[_keyBirthCertNo] = this.birthCertNo;
    map[_keySName] = this.sName;
    map[_keyFName] = this.fName;
    map[_keyLName] = this.lName;
    map[_keyGender] = this.gender;
    map[_keyDob] = this.dob;
    map[_keyAor] = this.aor;
    map[_keyFatherId] = this.fatherId;
    map[_keyMotherId] = this.motherId;

    return map;
  }

  List<ImmunizationDose> get immunizationDoses => this._immunizationDoses;

  String get motherId => this._motherId;

  String get fatherId => this._fatherId;

  String get aor => this._aor;

  String get dob => this._dob;

  String get gender => this._gender;

  String get lName => this._lName;

  String get fName => this._fName;

  String get sName => this._sName;

  String get birthCertNo => this._birthCertNo;

  String get id => this._id;
}
