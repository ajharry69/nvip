class ImmunizationDose {
  static final _keyDisease = 'disease';
  static final _keyRecommended = 'recommended';
  static final _keyAdministered = 'administered';

  final String disease;
  final int recommended, administered;

  ImmunizationDose({this.disease, this.recommended, this.administered});

  factory ImmunizationDose.fromMap(dynamic dataMap) {
    return ImmunizationDose(
      disease: dataMap[_keyDisease],
      recommended: dataMap[_keyRecommended],
      administered: dataMap[_keyAdministered],
    );
  }
}
