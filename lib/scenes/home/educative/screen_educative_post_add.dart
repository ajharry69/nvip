import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/educative_posts_repo.dart';
import 'package:nvip/models/educative_post.dart';

class AddEducativePostScreen extends StatelessWidget {
  final EducativePost educativePost;

  const AddEducativePostScreen({Key key, this.educativePost}) : super(key: key);

  @override
  Widget build(BuildContext context) => _PostScreenBody(
        educativePost: educativePost,
      );
}

class _PostScreenBody extends StatefulWidget {
  final EducativePost educativePost;

  const _PostScreenBody({Key key, this.educativePost}) : super(key: key);

  @override
  _PostScreenBodyState createState() => _PostScreenBodyState(educativePost);
}

class _PostScreenBodyState extends State<_PostScreenBody> {
  final EducativePost educativePost;
  final defaultImage = "images/no_image.png";
  final imageHeight = 200.0;
  bool _isRequestSent = false;
  File _imageFile;
  Connectivity _connectivity;
  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _titleController;

  TextEditingController _descController;

  _PostScreenBodyState(this.educativePost);

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _titleController = TextEditingController();
    _descController = TextEditingController();

    if (educativePost != null) {
      _titleController.text = educativePost.title;
      _descController.text = educativePost.description;
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
              top: Constants.defaultPadding * 4,
              left: Constants.defaultPadding * 4,
              right: Constants.defaultPadding * 4,
              bottom: Constants.defaultPadding * 2,
            ),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: Constants.defaultPadding),
                  child: GestureDetector(
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                              content: SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      title: Text("Capture from Camera"),
                                      onTap: () {
                                        _fetchImage(ctx, ImageSource.camera);
                                      },
                                    ),
                                    ListTile(
                                      title: Text("Pick from Gallery"),
                                      onTap: () {
                                        _fetchImage(ctx, ImageSource.gallery);
                                      },
                                    ),
                                    ListTile(
                                      title: Text("Remove Image"),
                                      onTap: () {
                                        setState(() {
                                          _imageFile = null;
                                        });
                                        Navigator.pop(ctx);
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                      );
                    },
                    child: _imageFile == null
                        ? educativePost != null &&
                                educativePost.imageUrl != null
                            ? FadeInImage.assetNetwork(
                                placeholder: defaultImage,
                                image: educativePost.imageUrl,
                                width: double.maxFinite,
                                height: imageHeight,
                                fit: BoxFit.fill,
                              )
                            : Image.asset(
                                defaultImage,
                                width: double.maxFinite,
                                height: imageHeight,
                                fit: BoxFit.fill,
                              )
                        : Image.file(
                            _imageFile,
                            width: double.maxFinite,
                            height: 200.0,
                            fit: BoxFit.fill,
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: Constants.defaultPadding * 2),
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
                      bottom: Constants.defaultPadding * 2),
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
                  margin: EdgeInsets.only(bottom: Constants.defaultPadding),
                  child: RaisedButton(
                    child: Text(
                      'Submit'.toUpperCase(),
                      textScaleFactor: Constants.defaultScaleFactor,
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
        var post =
            EducativePost(0, _title, _description, base64Image, "", "", "");

        if (!_isRequestSent) {
          _isRequestSent = true;
          await EducativePostDataRepo().addPost(post);

          Navigator.pushReplacementNamed(context, Routes.keyHome);
        }
      } else {
        Constants.showSnackBar(_scaffoldKey, Constants.connectionLost,
            isNetworkConnected: false);
      }
    } on Exception catch (err) {
      Constants.showSnackBar(
          _scaffoldKey, Constants.refinedExceptionMessage(err));
    } finally {
      _isRequestSent = false;
    }
  }

  void _fetchImage(BuildContext ctx, ImageSource imgSource) {
    ImagePicker.pickImage(
      source: imgSource,
      maxWidth: 1024.0,
      maxHeight: 500.0,
    ).then((file) {
      setState(() {
        _imageFile = file;
      });
    });
    Navigator.pop(ctx);
  }
}
