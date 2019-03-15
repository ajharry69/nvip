import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';

class TokenErrorWidget extends StatefulWidget {
  @override
  _TokenErrorWidgetState createState() => _TokenErrorWidgetState();
}

class _TokenErrorWidgetState extends State<TokenErrorWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.defaultPadding * 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            Constants.tokenExpired,
            style: Theme.of(context).textTheme.body1,
            textAlign: TextAlign.center,
          ),
          RaisedButton(
            child: Text(
              "Sign In".toUpperCase(),
              style: Styles.btnTextStyle,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, Routes.keySignIn);
            },
          )
        ],
      ),
    );
  }
}
