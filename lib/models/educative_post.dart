class EducativePost {
  static final _keyId = 'id';
  static final _keyTitle = 'title';
  static final _keyDescription = 'desc';
  static final _keyPostImage = 'image';
  static final _keyPostImageUrl = 'postImageUrl';
  static final _keyOwnerName = 'ownerName';
  static final _keyOwnerImageUrl = 'ownerImageUrl';
  static final _keyDatePosted = 'datePosted';
  static final _keyPostFlags = 'postFlags';

  int _id = 0;
  String _title = "";
  String _description = "";
  String _imageUrl = "";
  String _ownerName = "";
  String _ownerImageUrl = "";
  String _datePosted = "";
  List<PostFlag> _postFlags = List();
  final List<String> flaggers = List();

  EducativePost(this._id, this._title, this._description, this._imageUrl,
      [this._ownerName, this._ownerImageUrl, this._datePosted]);

  EducativePost.fromMap(dynamic postMap) {
    this._id = postMap[_keyId];
    this._title = postMap[_keyTitle];
    this._description = postMap[_keyDescription];
    this._imageUrl = postMap[_keyPostImageUrl];
    this._ownerName = postMap[_keyOwnerName];
    this._ownerImageUrl = postMap[_keyOwnerImageUrl];
    this._datePosted = postMap[_keyDatePosted];
    List flags = postMap[_keyPostFlags];
    this._postFlags = flags.map((flagMap) {
      var postFlag = PostFlag.fromMap(flagMap);
      flaggers.add(postFlag.flaggedBy);
      return postFlag;
    }).toList();
  }

  Map<String, dynamic> toMap() => {
        _keyId: this.id.toString(),
        _keyTitle: this.title,
        _keyDescription: this.description,
        _keyPostImage: this.imageUrl,
        _keyOwnerName: this.ownerName,
        _keyOwnerImageUrl: this.ownerImageUrl,
        _keyDatePosted: this.datePosted,
      };

  List<PostFlag> get postFlags => this._postFlags;

  String get datePosted => this._datePosted;

  String get ownerImageUrl => this._ownerImageUrl;

  String get ownerName => this._ownerName;

  String get imageUrl => this._imageUrl;

  String get description => this._description;

  String get title => this._title;

  int get id => this._id;
}

class PostFlag {
  static final _keyId = "id";
  static final _keyPostId = "postId";
  static final _keyFlaggedBy = "flaggedBy";
  static final _keyTimeFlagged = "timeFlagged";

  int _id;
  int _postId;
  String _flaggedBy;
  DateTime _timeFlagged;

  PostFlag([this._id = 0, this._postId, this._flaggedBy, this._timeFlagged]);

  PostFlag.withNamedParams(
      {int id = 0, int postId, String flaggedBy, DateTime timeFlagged}) {
    this._id = id;
    this._postId = postId;
    this._flaggedBy = flaggedBy;
    this._timeFlagged = timeFlagged;
  }

  PostFlag.fromMap(dynamic flagMap) {
//    this._id = int.tryParse(flagMap[_keyId]);
//    this._postId = int.tryParse(flagMap[_keyPostId]);
    this._id = flagMap[_keyId];
    this._postId = flagMap[_keyPostId];
    this._flaggedBy = flagMap[_keyFlaggedBy];
    this._timeFlagged = DateTime.tryParse(flagMap[_keyTimeFlagged]);
  }

  Map<String, dynamic> toMap() => {
        _keyId: this.id.toString() ?? "iiii",
        _keyPostId: this.postId.toString() ?? "kkkk",
        _keyFlaggedBy: this.flaggedBy ?? "jjjj",
        _keyTimeFlagged: this.timeFlagged.toString() ?? "dddd"
      };

  int get id => this._id;

  int get postId => this._postId;

  String get flaggedBy => this._flaggedBy;

  DateTime get timeFlagged => this._timeFlagged;
}
