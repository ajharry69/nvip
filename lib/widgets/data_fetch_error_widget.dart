import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';

class DataFetchErrorWidget extends StatefulWidget {
  final String message;

  const DataFetchErrorWidget({Key key, this.message}) : super(key: key);

  @override
  _DataFetchErrorWidgetState createState() =>
      _DataFetchErrorWidgetState(message);
}

class _DataFetchErrorWidgetState extends State<DataFetchErrorWidget> {
  final String message;

  _DataFetchErrorWidgetState(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.defaultPadding * 4),
        child: Text(
          message,
          style: Theme.of(context).textTheme.body1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
