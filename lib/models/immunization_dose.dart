class ImmunizationDose {
  static final _keyDisease = 'disease';
  static final _keyVaccine = 'vaccine';
  static final _keyLastImmunizationDate = 'lastImmunizationDate';
  static final _keyNextImmunizationDate = 'nextImmunizationDate';
  static final _keyDaysToNext = 'daysToNext';
  static final _keyAdministered = 'administered';
  static final _keyRecommended = 'recommended';

  final String disease, vaccine, lastImmunizationDate, nextImmunizationDate;
  final int recommended, administered, daysToNext;

  ImmunizationDose(
      {this.disease,
      this.vaccine,
      this.lastImmunizationDate,
      this.nextImmunizationDate,
      this.daysToNext,
      this.recommended,
      this.administered});

  factory ImmunizationDose.fromMap(dynamic dataMap) {
    return ImmunizationDose(
      disease: dataMap[_keyDisease],
      vaccine: dataMap[_keyVaccine],
      lastImmunizationDate: dataMap[_keyLastImmunizationDate],
      nextImmunizationDate: dataMap[_keyNextImmunizationDate],
      daysToNext: dataMap[_keyDaysToNext],
      recommended: dataMap[_keyRecommended],
      administered: dataMap[_keyAdministered],
    );
  }
}
