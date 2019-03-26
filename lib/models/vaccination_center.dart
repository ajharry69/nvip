class VaccineCenter {
  static final String _keyId = 'id';
  static final String _keyCounty = 'county';
  static final String _keySubCounty = 'subCounty';
  static final String _keySubCounties = 'subCounties';

  int _id = 0;
  String _county;
  String _subCounty;
  List<String> _subCounties = List();
  bool isSelected = false;

  VaccineCenter(this._id, this._county, this._subCounty);

  VaccineCenter.serverParams(this._county, this._subCounty);

  VaccineCenter.fromMap(dynamic centerMap) {
    this._id = centerMap[_keyId];
    this._county = centerMap[_keyCounty];
    List cs = centerMap[_keySubCounties];
    this._subCounties = cs.cast<String>();
  }

  Map<String, dynamic> toMap() => {
        _keyId: this.id.toString(),
        _keyCounty: this.county,
        _keySubCounty: this.subCounty,
      };

  int get id => this._id;

  String get county => this._county;

  String get subCounty => this._subCounty;

  List<String> get subCounties => this._subCounties;
}
