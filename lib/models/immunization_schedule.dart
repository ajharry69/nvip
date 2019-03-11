import 'dart:convert';

class Schedule {
  static final _keyId = 'id';
  static final _keyScheduler = 'scheduler';
  static final _keyTitle = 'title';
  static final _keyDescription = 'description';
  static final _keyStartDate = 'startDate';
  static final _keyEndDate = 'endDate';
  static final _keyDatePosted = 'datePosted';
  static final _keyDiseases = 'diseases';
  static final _keyPlaces = 'places';

  int id;
  String scheduler;
  String title;
  String description;
  String startDate;
  String endDate;
  String datePosted;
  List<dynamic> diseases;
  List<dynamic> places;

  Schedule(
      {this.id = 0,
      this.scheduler = "_",
      this.title = "_",
      this.description = "_",
      this.startDate = "_",
      this.endDate = "_",
      this.datePosted = "_",
      this.diseases,
      this.places});

  Map<String, String> toMap() => {
        _keyId: id.toString(),
        _keyScheduler: scheduler,
        _keyTitle: title,
        _keyDescription: description,
        _keyStartDate: startDate,
        _keyEndDate: endDate,
        _keyDatePosted: datePosted,
        _keyDiseases: jsonEncode(diseases),
        _keyPlaces: jsonEncode(places)
      };

  Schedule.fromMap(dynamic scheduleMap) {
    id = scheduleMap[_keyId];
    scheduler = scheduleMap[_keyScheduler];
    title = scheduleMap[_keyTitle];
    description = scheduleMap[_keyDescription];
    startDate = scheduleMap[_keyStartDate];
    endDate = scheduleMap[_keyEndDate];
    datePosted = scheduleMap[_keyDatePosted];
    diseases = jsonDecode(scheduleMap[_keyDiseases]);
    places = jsonDecode(scheduleMap[_keyPlaces]);
  }
}
