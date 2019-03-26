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

  final int id;
  final String scheduler;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String datePosted;
  final List<String> diseases;
  final List<String> places;

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

  factory Schedule.fromMap(dynamic scheduleMap) {
    List _diseases = jsonDecode(scheduleMap[_keyDiseases]);
    List _places = jsonDecode(scheduleMap[_keyPlaces]);
    return Schedule(
      id: scheduleMap[_keyId],
      scheduler: scheduleMap[_keyScheduler],
      title: scheduleMap[_keyTitle],
      description: scheduleMap[_keyDescription],
      startDate: scheduleMap[_keyStartDate],
      endDate: scheduleMap[_keyEndDate],
      datePosted: scheduleMap[_keyDatePosted],
      diseases: _diseases.cast<String>(),
      places: _places.cast<String>(),
    );
  }
}
