class Immunization {
  static final String _keyId = 'id';
  static final String _keyDoi = 'doi';
  static final String _keyBirthCert = 'birthCert';
  static final String _keyChildName = 'childName';
  static final String _keyVaccineBatch = 'vaccineBatch';
  static final String _keyDiseaseName = 'diseaseName';
  static final String _keyPov = 'pov';
  static final String _keyHpId = 'hpId';
  static final String _keyHpName = 'hpName';
  static final String _keyNotes = 'notes';

  int _id = 0;
  String _doi = "";
  String _birthCert = "";
  String _childName = "";
  String _vaccineBatch = "";
  String _diseaseName = "";
  String _pov = "";
  String _hpId = "";
  String _hpName = "";
  String _notes = "";
  bool isSelected = false;

  Immunization(
      this._id,
      this._doi,
      this._birthCert,
      this._childName,
      this._vaccineBatch,
      this._diseaseName,
      this._pov,
      this._hpId,
      this._hpName,
      [this._notes = ""]);

  Immunization.serverParams(this._birthCert, this._vaccineBatch,
      this._diseaseName, this._pov, this._hpId,
      [this._notes = ""]);

  Immunization.fromMap(dynamic immunizationMap) {
    this._id = immunizationMap[_keyId];
    this._doi = immunizationMap[_keyDoi];
    this._birthCert = immunizationMap[_keyBirthCert];
    this._childName = immunizationMap[_keyChildName];
    this._vaccineBatch = immunizationMap[_keyVaccineBatch];
    this._diseaseName = immunizationMap[_keyDiseaseName];
    this._pov = immunizationMap[_keyPov];
    this._hpId = immunizationMap[_keyHpId];
    this._hpName = immunizationMap[_keyHpName];
    this._notes = immunizationMap[_keyNotes];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map[_keyId] = this.id.toString();
    map[_keyDoi] = this.doi;
    map[_keyBirthCert] = this.birthCert;
    map[_keyChildName] = this.childName;
    map[_keyVaccineBatch] = this.vaccineBatch;
    map[_keyDiseaseName] = this.diseaseName;
    map[_keyPov] = this.pov;
    map[_keyHpId] = this.hpId;
    map[_keyHpName] = this.hpName;
    map[_keyNotes] = this.notes;

    return map;
  }

  String get notes => this._notes;

  String get hpName => this._hpName;

  String get hpId => this._hpId;

  String get pov => this._pov;

  String get diseaseName => this._diseaseName;

  String get vaccineBatch => this._vaccineBatch;

  String get childName => this._childName;

  String get birthCert => this._birthCert;

  String get doi => this._doi;

  int get id => this._id;
}
