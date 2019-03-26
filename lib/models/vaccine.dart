class Vaccine {
  static final String _keyId = 'id';
  static final String _keyVIdNo = 'vIdNo';
  static final String _keyBatchNo = 'batchNo';
  static final String _keyName = 'name';
  static final String _keyTd = 'disease';
  static final String _keyManufacturer = 'manufacturer';
  static final String _keyManDate = 'manDate';
  static final String _keyExpDate = 'expDate';
  static final String _keyDeliveryMode = 'deliveryMode';
  static final String _keyIsShared = 'isShared';
  static final String _keyIsUsed = 'isUsed';
  static final String _keyDescription = 'description';

  int _id = 0;
  String _vIdNo; // also vIdNo / Vaccine ID Number
  String _batchNo;
  String _name;
  String _targetDisease;
  String _manufacturer;
  String _manufactureDate;
  String _expiryDate;
  String _deliveryMode;
  bool _isShared = false;
  bool _isUsed = false;
  String _description;
  bool isSelected = false;

  Vaccine(
    this._id,
    this._vIdNo,
    this._batchNo,
    this._name,
    this._targetDisease,
    this._manufacturer,
    this._manufactureDate,
    this._expiryDate,
    this._deliveryMode,
    this._isShared,
    this._isUsed,
    this._description,
    this.isSelected,
  );

  Vaccine.serverParams(
    this._vIdNo,
    this._batchNo,
    this._name,
    this._targetDisease,
    this._manufacturer,
    this._manufactureDate,
    this._expiryDate,
    this._deliveryMode,
    this._isShared,
    this._description,
  );

  Vaccine.fromMap(dynamic vaccineMap) {
    this._id = vaccineMap[_keyId];
    this._vIdNo = vaccineMap[_keyVIdNo];
    this._batchNo = vaccineMap[_keyBatchNo];
    this._name = vaccineMap[_keyName];
    this._targetDisease = vaccineMap[_keyTd];
    this._manufacturer = vaccineMap[_keyManufacturer];
    this._manufactureDate = vaccineMap[_keyManDate];
    this._expiryDate = vaccineMap[_keyExpDate];
    this._deliveryMode = vaccineMap[_keyDeliveryMode];
    this._isShared = vaccineMap[_keyIsShared];
    this._isUsed = vaccineMap[_keyIsUsed];
    this._description = vaccineMap[_keyDescription];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map[_keyId] = this.id.toString();
    map[_keyVIdNo] = this.vIdNo;
    map[_keyBatchNo] = this.batchNo;
    map[_keyName] = this.name;
    map[_keyTd] = this.targetDisease;
    map[_keyManufacturer] = this.manufacturer;
    map[_keyManDate] = this.manufactureDate;
    map[_keyExpDate] = this.expiryDate;
    map[_keyDeliveryMode] = this.deliveryMode;
    map[_keyIsShared] = this.isShared ? "1" : "0";
    map[_keyDescription] = this.description;

    return map;
  }

  String get description => this._description;

  String get deliveryMode => _deliveryMode;

  String get expiryDate => this._expiryDate;

  String get manufactureDate => this._manufactureDate;

  String get manufacturer => this._manufacturer;

  String get targetDisease => this._targetDisease;

  String get name => this._name;

  String get batchNo => this._batchNo;

  String get vIdNo => this._vIdNo;

  int get id => this._id;

  bool get isShared => _isShared;

  bool get isUsed => _isUsed;
}
