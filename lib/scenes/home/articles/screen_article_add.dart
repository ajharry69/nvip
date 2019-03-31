import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/educative_posts_repo.dart';
import 'package:nvip/models/article.dart';
import 'package:nvip/widgets/post_image_widget.dart';

class ArticleAddScreen extends StatelessWidget {
  final Article article;

  const ArticleAddScreen({Key key, this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) => _ArticleAddScreenBody(
        article: article,
      );
}

class _ArticleAddScreenBody extends StatefulWidget {
  final Article article;

  const _ArticleAddScreenBody({Key key, this.article}) : super(key: key);

  @override
  _ArticleAddScreenBodyState createState() =>
      _ArticleAddScreenBodyState(article);
}

class _ArticleAddScreenBodyState extends State<_ArticleAddScreenBody> {
  final Article article;
  final defaultImage = "images/no_image.png";
  final imageHeight = 194.0;
  bool _isRequestSent = false;
  File _imageFile;
  Connectivity _connectivity;
  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _titleController;
  TextEditingController _descController;

  _ArticleAddScreenBodyState(this.article);

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _titleController = TextEditingController();
    _descController = TextEditingController();

    if (article != null) {
      _titleController.text = article.title;
      _descController.text = article.description;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _descController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, Routes.keyHome);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Constants.backIcon),
            onPressed: () {
              Navigator.pushReplacementNamed(context, Routes.keyHome);
            },
          ),
          title: Text("Add Post"),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(
              top: Dimensions.defaultPadding * 4,
              left: Dimensions.defaultPadding * 4,
              right: Dimensions.defaultPadding * 4,
              bottom: Dimensions.defaultPadding * 2,
            ),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: Dimensions.defaultPadding),
                  child: GestureDetector(
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    GestureDetector(
                                      child: Text("Capture from Camera"),
                                      onTap: () {
                                        _fetchImage(ctx, ImageSource.camera);
                                      },
                                    ),
                                    Divider(color: Colors.black54),
                                    GestureDetector(
                                      child: Text("Pick from Gallery"),
                                      onTap: () {
                                        _fetchImage(ctx, ImageSource.gallery);
                                      },
                                    ),
                                    Divider(color: Colors.black54),
                                    GestureDetector(
                                      child: Text("Remove Image"),
                                      onTap: () {
                                        setState(() {
                                          _imageFile = null;
                                        });
                                        Navigator.pop(ctx);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      );
                    },
                    child: _imageFile == null
                        ? CustomFadeInImageView(
                            imageUrl: article != null ? article.imageUrl : null)
                        : Image.file(
                            _imageFile,
                            width: double.maxFinite,
                            height: imageHeight,
                            fit: BoxFit.fill,
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: Dimensions.defaultPadding * 2),
                  child: TextFormField(
                    controller: _titleController,
                    validator: (String title) {
                      if (title.isEmpty) {
                        return 'Title is required';
                      } else if (title.length > 150) {
                        return 'Characters count should be less than 151';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Title',
                      helperText: 'post heading',
                      counterText: '150',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: Dimensions.defaultPadding * 2),
                  child: TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    validator: (String title) {
                      if (title.isEmpty) {
                        return 'Description is required';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Description',
                      helperText: 'short description of the post',
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: Dimensions.defaultPadding),
                  child: RaisedButton(
                    child: Text(
                      (article == null ? 'Submit' : 'Update').toUpperCase(),
                      textScaleFactor: Dimensions.defaultScaleFactor,
                      style: Styles.btnTextStyle,
                    ),
                    onPressed: _isRequestSent
                        ? null
                        : () {
                            if (_formKey.currentState.validate()) {
                              submitPost();
                            }
                          },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void submitPost() async {
    var _title = _titleController.text;
    var _description = _descController.text;
    String base64Image =
        _imageFile != null ? base64Encode(_imageFile.readAsBytesSync()) : "";
//    String fileName = _imageFile.path.split('/').last;

    try {
      var result = await _connectivity.checkConnectivity();

      if (result != ConnectivityResult.none) {
        var post = Article(0, _title, _description, base64Image, "", "", "");

        if (!_isRequestSent) {
          _isRequestSent = true;

          var educativePostDataRepo = EducativePostDataRepo();
          await (article == null
              ? educativePostDataRepo.addPost(post)
              : educativePostDataRepo.updatePost(post));

          Navigator.pushReplacementNamed(context, Routes.keyHome);
        }
      } else {
        Constants.showSnackBar(_scaffoldKey, Constants.connectionLost,
            isNetworkConnected: false);
      }
    } on Exception catch (err) {
      var errorMessage = Constants.refinedExceptionMessage(err);
      errorMessage.contains(Constants.tokenErrorType)
          ? Constants.showSignInRequestDialog(ctx: context)
          : Constants.showSnackBar(_scaffoldKey, errorMessage);
    } finally {
      _isRequestSent = false;
    }
  }

  void _fetchImage(BuildContext ctx, ImageSource imgSource) async {
    try {
      var file = await ImagePicker.pickImage(
        source: imgSource,
        maxWidth: 1024.0,
        maxHeight: 1024.0,
      );

      setState(() {
        _imageFile = file;
      });
      Navigator.pop(ctx);
    } on Exception catch (_) {
//      Constants.showSnackBar(
//          _scaffoldKey, Constants.refinedExceptionMessage(err));
    }
  }
}
