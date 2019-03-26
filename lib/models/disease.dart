import 'dart:convert';

class Disease {
  static final String _keyId = 'id';
  static final String _keyName = 'name';
  static final String _keyVaccine = 'vaccine';
  static final String _keySpreadBy = 'spreadBy';
  static final String _keySymptoms = 'symptoms';
  static final String _keyComplications = 'complications';

  int _id = 0;
  String _name, _vaccine;
  List<String> _spreadBy = List();
  List<String> _symptoms = List();
  List<String> _complications = List();
  bool isSelected = false;

  Disease(this._id, this._name,
      [this._vaccine, this._spreadBy, this._symptoms, this._complications]);

  Disease.serverParams(this._name,
      [this._vaccine, this._spreadBy, this._symptoms, this._complications]);

  Disease.fromMap(dynamic diseaseMap) {
    List spreadBy = jsonDecode(diseaseMap[_keySpreadBy]);
    List symptoms = jsonDecode(diseaseMap[_keySymptoms]);
    List complications = jsonDecode(diseaseMap[_keyComplications]);

    this._id = diseaseMap[_keyId];
    this._name = diseaseMap[_keyName];
    this._vaccine = diseaseMap[_keyVaccine];
    this._spreadBy = spreadBy.cast<String>();
    this._symptoms = symptoms.cast<String>();
    this._complications = complications.cast<String>();
  }

  Map<String, dynamic> toMap() => {
        _keyId: this.id.toString(),
        _keyName: this.name,
        _keyVaccine: this.vaccine,
        _keySpreadBy: jsonEncode(this.spreadBy),
        _keySymptoms: jsonEncode(this.symptoms),
        _keyComplications: jsonEncode(this.complications),
      };

  List<String> get complications => this._complications;

  List<String> get symptoms => this._symptoms;

  List<String> get spreadBy => this._spreadBy;

  String get vaccine => this._vaccine;

  String get name => this._name;

  int get id => this._id;
}
