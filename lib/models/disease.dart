import 'dart:convert';

class Disease {
  static final String _keyId = 'id';
  static final String _keyName = 'name';
  static final String _keyVaccine = 'vaccine';
  static final String _keySpreadBy = 'spreadBy';
  static final String _keySymptoms = 'symptoms';
  static final String _keyComplications = 'complications';

  final int id;
  final String name, vaccine;
  final List<String> spreadBy, symptoms, complications;
  bool isSelected = false;

  Disease(
      {this.id,
      this.name,
      this.vaccine,
      this.spreadBy,
      this.symptoms,
      this.complications});

  factory Disease.fromMap(dynamic diseaseMap) {
    List spreadBy = jsonDecode(diseaseMap[_keySpreadBy]);
    List symptoms = jsonDecode(diseaseMap[_keySymptoms]);
    List complications = jsonDecode(diseaseMap[_keyComplications]);

    return Disease(
      id: diseaseMap[_keyId],
      name: diseaseMap[_keyName],
      vaccine: diseaseMap[_keyVaccine],
      spreadBy: spreadBy.cast<String>(),
      symptoms: symptoms.cast<String>(),
      complications: complications.cast<String>(),
    );
  }

  Map<String, dynamic> toMap() => {
        _keyId: this.id.toString(),
        _keyName: this.name,
        _keyVaccine: this.vaccine,
        _keySpreadBy: jsonEncode(this.spreadBy),
        _keySymptoms: jsonEncode(this.symptoms),
        _keyComplications: jsonEncode(this.complications),
      };
}
