class EducativePost {
  static final _keyId = 'id';
  static final _keyTitle = 'title';
  static final _keyDescription = 'desc';
  static final _keyPostImage = 'image';
  static final _keyPostImageUrl = 'postImageUrl';
  static final _keyOwnerName = 'ownerName';
  static final _keyOwnerImageUrl = 'ownerImageUrl';
  static final _keyDatePosted = 'datePosted';

  int _id = 0;
  String _title = "";
  String _description = "";
  String _imageUrl = "";
  String _ownerName = "";
  String _ownerImageUrl = "";
  String _datePosted = "";

  EducativePost(this._id, this._title, this._description, this._imageUrl,
      [this._ownerName, this._ownerImageUrl, this._datePosted]);

  EducativePost.fromMap(dynamic postMap) {
    this._id = int.tryParse(postMap[_keyId]);
    this._title = postMap[_keyTitle];
    this._description = postMap[_keyDescription];
    this._imageUrl = postMap[_keyPostImageUrl];
    this._ownerName = postMap[_keyOwnerName];
    this._ownerImageUrl = postMap[_keyOwnerImageUrl];
    this._datePosted = postMap[_keyDatePosted];
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

  String get datePosted => this._datePosted;

  String get ownerImageUrl => this._ownerImageUrl;

  String get ownerName => this._ownerName;

  String get imageUrl => this._imageUrl;

  String get description => this._description;

  String get title => this._title;

  int get id => this._id;
}
