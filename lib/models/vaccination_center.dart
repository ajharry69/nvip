class VaccineCenter {
  static final String _keyId = 'id';
  static final String _keyCounty = 'county';
  static final String _keyConstituents = 'constituencies';

  int _id = 0;
  String _county;
  List<String> _constituencies = List();
  bool isSelected = false;

  VaccineCenter(this._id, this._county);

  VaccineCenter.serverParams(this._county);

  VaccineCenter.fromMap(dynamic centerMap) {
    this._id = centerMap[_keyId];
    this._county = centerMap[_keyCounty];
    List cs = centerMap[_keyConstituents];
    this._constituencies = cs.cast<String>();
  }

  Map<String, dynamic> toMap() => {
        _keyId: this.id.toString(),
        _keyCounty: this.county,
      };

  int get id => this._id;

  String get county => this._county;

  List<String> get constituencies => this._constituencies;
}
