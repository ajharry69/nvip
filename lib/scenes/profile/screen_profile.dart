import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/cache_db/user_cache.dart';
import 'package:nvip/data_repo/network/user_repo.dart';
import 'package:nvip/models/user.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _ProfileScreenBody();
}

class _ProfileScreenBody extends StatefulWidget {
  @override
  __ProfileScreenBodyState createState() => __ProfileScreenBodyState();
}

class __ProfileScreenBodyState extends State<_ProfileScreenBody> {
  bool _isRequestSent = false;
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _formKey = GlobalKey<FormState>();
  final userCache = UserCache();
  User user;
  final userDataRepo = UserDataRepo();

  final _textControllerIDNo = TextEditingController();
  final _textControllerSirName = TextEditingController();
  final _textControllerFirstName = TextEditingController();
  final _textControllerLastName = TextEditingController();
  final _textControllerEmail = TextEditingController();
  final _textControllerMobile = TextEditingController();

  void populateUserData() async {
    user = await userCache.currentUser;
    _textControllerIDNo.text = user.idNo;
    _textControllerSirName.text = user.sName;
    _textControllerFirstName.text = user.fName;
    _textControllerLastName.text = user.lName;
    _textControllerEmail.text = user.email;
    _textControllerMobile.text = user.mobileNo;
  }

  @override
  void initState() {
    super.initState();
    populateUserData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, Routes.keyHome);
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: NestedScrollView(
            headerSliverBuilder: (context, isInnerBoxScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 230,
                  pinned: true,
                  title: Text("Account Profile"),
                  leading: IconButton(
                    icon: Icon(Constants.backIcon),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, Routes.keyHome);
                    },
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade800,
                            Colors.lightBlueAccent,
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                      child: loadNetworkImage(""),
                    ),
                  ),
                ),
              ];
            },
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: Constants.defaultPadding * 3,
                    horizontal: Constants.defaultPadding * 3),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: Constants.defaultPadding * 2),
                        child: TextFormField(
                          controller: _textControllerSirName,
                          decoration: InputDecoration(
                            labelText: 'Sir Name',
                            suffixIcon: Icon(Icons.edit),
                          ),
                          validator: (String val) => null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: Constants.defaultPadding * 2),
                        child: TextFormField(
                          controller: _textControllerFirstName,
                          decoration: InputDecoration(
                            labelText: 'First Name*',
                            suffixIcon: Icon(Icons.edit),
                          ),
                          validator: (String val) {
                            if (val.isEmpty) {
                              return 'first name is required.';
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: Constants.defaultPadding * 2),
                        child: TextFormField(
                          controller: _textControllerLastName,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            suffixIcon: Icon(Icons.edit),
                          ),
                          validator: (String val) => null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: Constants.defaultPadding * 2),
                        child: TextFormField(
                          controller: _textControllerIDNo,
                          keyboardType: TextInputType.numberWithOptions(),
                          decoration: InputDecoration(labelText: "ID Number"),
                          validator: (val) {
                            if (val.isEmpty) {
                              return 'ID Number is required';
                            } else if (val.contains(' ')) {
                              return "Invalid ID Number. Spaces not allowed";
                            } else if (val.contains('-')) {
                              return "Invalid character '-'. Only numbers required";
                            } else if (val.contains('.')) {
                              return "Invalid character '.'. Only numbers required";
                            } else if (val.contains(',')) {
                              return "Invalid character ','. Only numbers required";
                            } else if (int.tryParse(val) == null) {
                              return "Invalid ID Number. Only numbers required";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: Constants.defaultPadding * 2),
                        child: TextFormField(
                          controller: _textControllerMobile,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "Mobile Number",
                            suffixIcon: Icon(Icons.edit),
                          ),
                          validator: (val) => null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: Constants.defaultPadding * 2),
                        child: TextFormField(
                          enabled: false,
                          keyboardType: TextInputType.emailAddress,
                          controller: _textControllerEmail,
                          decoration: InputDecoration(labelText: 'Email*'),
                          validator: (String val) {
                            if (!val.contains('@')) {
                              return 'invalid email address';
                            } else if (!val.contains('.', val.indexOf('@'))) {
                              return 'invalid email address';
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                      Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.only(
                            top: Constants.defaultPadding),
                        child: RaisedButton(
                          child: Text(
                            'Update Profile'.toUpperCase(),
                            textScaleFactor: Constants.defaultScaleFactor,
                            style: Styles.btnTextStyle,
                          ),
                          onPressed: _isRequestSent
                              ? null
                              : () {
                                  setState(() {
                                    if (_formKey.currentState.validate()) {
                                      _updateProfile(context);
                                    }
                                  });
                                },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }

  Widget loadNetworkImage(String url) {
    try {
      if (url.isEmpty || url == null) throw Exception("Image URL missing");
      return FadeInImage.assetNetwork(
        placeholder: "images/avator.png",
        image: url,
      );
    } on Exception catch (_) {
      return Icon(
        Icons.person,
        color: Colors.white,
      );
    }
  }

  void _updateProfile(BuildContext context) async {}
}
