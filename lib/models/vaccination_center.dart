import 'dart:convert';

class VaccineCenter {
  static final String _keySubCountiesCount = 'subCountiesCount';
  static final String _keyCounty = 'county';
  static final String _keySubCounty = 'subCounty';
  static final String _keySubCounties = 'subCounties';

  final int subCountiesCount;
  final String county, subCounty;
  final List<SubCounty> subCounties;
  bool isSelected = false;

  VaccineCenter(
      {this.subCountiesCount, this.county, this.subCounty, this.subCounties});

  factory VaccineCenter.fromMap(dynamic centerMap) {
    List cs = centerMap[_keySubCounties];
    return VaccineCenter(
      county: centerMap[_keyCounty],
      subCountiesCount: centerMap[_keySubCountiesCount],
      subCounties: cs.map((dataMap) => SubCounty.fromMap(dataMap)).toList(),
    );
  }

  factory VaccineCenter.fromCacheMap(dynamic centerMap) {
    List cs = jsonDecode(centerMap[_keySubCounties]);
    return VaccineCenter(
      county: centerMap[_keyCounty],
      subCountiesCount: centerMap[_keySubCountiesCount],
      subCounties: cs.map((dataMap) => SubCounty.fromMap(dataMap)).toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        _keyCounty: this.county,
        _keySubCounty: this.subCounty,
      };

  Map<String, dynamic> toMapForCaching() => {
        _keyCounty: this.county,
        _keySubCountiesCount: this.subCountiesCount,
        _keySubCounties: jsonEncodedSubCountyList
      };

  String get jsonEncodedSubCountyList {
    String xyz = "";
    var i = 0;
    subCounties.forEach((sc) {
      xyz += i < subCounties.length - 1 ? "${sc.toString()}," : sc.toString();
      ++i;
      return sc;
    });

    return "[$xyz]";
  }
}

class SubCounty {
  static final _keyId = "id";
  static final _keyName = "name";
  final int id;
  final String name;

  SubCounty({this.id, this.name});

  factory SubCounty.fromMap(dynamic dataMap) =>
      SubCounty(id: dataMap[_keyId], name: dataMap[_keyName]);

  @override
  String toString() =>
      "{\"$_keyId\":${this.id},\"$_keyName\":\"${this.name}\"}";
}

class TableSubCounty {
  static final _keyId = "id";
  static final _keyName = "name";
  static final String _keyCounty = 'county';

  final int id;
  final String name, county;
  bool isSelected = false;

  TableSubCounty({this.id, this.name, this.county});
}
