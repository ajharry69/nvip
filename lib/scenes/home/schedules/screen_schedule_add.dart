import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';

class AddScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _ScheduleScreenBody();
}

class _ScheduleScreenBody extends StatefulWidget {
  @override
  __ScheduleScreenBodyState createState() => __ScheduleScreenBodyState();
}

class __ScheduleScreenBodyState extends State<_ScheduleScreenBody> {
  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();

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
          title: Text("Add Immunization Schedule"),
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
                  child: TextFormField(
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
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: Constants.defaultPadding * 2),
                  child: TextFormField(
                    maxLines: 4,
                    validator: (String title) {
                      if (title.isEmpty) {
                        return 'Description is required';
                      } else if (title.length > 150) {
                        return 'Characters count should be less than 151';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Description',
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
                    onPressed: () {
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

  void submitPost() {}
}
