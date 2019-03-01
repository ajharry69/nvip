import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nvip/auth/auth_listener.dart';
import 'package:nvip/data_repo/cache_db/user_cache.dart';
import 'package:nvip/models/user.dart';

class Constants {
  static final encUTF_8 = "charset=UTF-8";

  static Future<Map<String, String>> httpHeaders() async {
    var token = await UserCache().authToken;
    return {HttpHeaders.authorizationHeader: "Bearer $token"};
  }

  // REST API json response keys
  // Constant Standardized
  static final String keyIsError = 'isError';
  static final String keyMessage = 'message';
  static final String keyDebugMsg = 'debugMsg';
  static final String keyToken = 'token';

  // Constant Dependent
  static final String keyUser = 'user';
  static final String keyUsers = 'users';
  static final String keyChildren = 'children';
  static final String keyChild = 'child';
  static final String keyImmunizations = 'immunizations';
  static final String keyCenters = 'centers';
  static final String keyDiseases = 'diseases';
  static final String keyVaccines = 'vaccines';
  static final String keySchedule = 'schedule';
  static final String keySchedules = 'schedules';
  static final String keyEducative = 'educative';
  static final String keyEducativePosts = 'educativePosts';

  // User Roles/Privileges
  static final String privilegeAdmin = 'Admin';
  static final String privilegeParent = 'Parent';
  static final String privilegeProvider = 'Provider';

  // Password reset identifier
  static final String prTypeChange = 'C';
  static final String prTypeReset = 'R';

  // App Dependent Constants
  static final String appName = "NVIP";
  static final String drawerHeaderName = "username";
  static final String drawerHeaderEmail = "email@address.com";
  static final String tabTitleEducative = "Educative".toUpperCase();
  static final String tabTitleSchedule = "Schedules".toUpperCase();
  static final String tabTitleChildren = "My Children".toUpperCase();
  static final String connectionLost =
      "Connection lost. Please enable cellular data or WIFI.";
  static final double dividerSize = 5.0;
  static final int initialTimeout = 30;
  static final double buttonRadius = 5.0;
  static const double defaultPadding = 8.0;
  static const double defaultScaleFactor = 1.3;

  static final hideKbMethod = 'TextInput.hide';

  static const String immunizationRecNoAll = "ALL";
  static const String immunizationRecNoProvider = "PROVIDER";
  static const String childrenRecNoAll = "ALL";
  static const String childrenRecNoParent = "PARENT";

  static const String defaultDateFormat = "yyyy-MM-dd";
  static const errInvalidDate =
      "invalid date or date format. Use: YYYY-MM-DD format";

  // Cache Database
  static final String dbName = '${appName.toLowerCase()}.db';
  static final int dbVersion = 3;

  static final IconData backIcon = Icons.arrow_back;

  static final List<int> monthsWith30Days = [4, 6, 9, 11];

  static final List<int> monthsWith31Days = [1, 3, 5, 7, 8, 10, 12];

  /// @param isTrue: a condition that MUST return true in order for the
  /// @param customMessage to be thrown as an error message
  static String isDateAndFormatCorrect({
    @required String date,
    @required String emptyDateMessage,
    String customMessage,
    bool isTrue = true,
  }) {
    try {
      if (date.isEmpty) throw Exception(emptyDateMessage);

      var dateComponents = date.split('-');
      var dcSize = dateComponents.length;

      var year = int.tryParse(dateComponents[0]);
      var month = int.tryParse(dateComponents[1]);

      if (month > 12) throw Exception(errInvalidDate);

      if (dcSize > 2) {
        var day = int.tryParse(dateComponents[2]);

        if (Constants.isLeapYear(year) && month == 2 && day > 29)
          throw Exception(errInvalidDate);

        if (!Constants.isLeapYear(year) && month == 2 && day > 28)
          throw Exception(errInvalidDate);

        if (Constants.monthsWith31Days.contains(month) && day > 31)
          throw Exception(errInvalidDate);

        if (Constants.monthsWith30Days.contains(month) && day > 30)
          throw Exception(errInvalidDate);

        if (isTrue) throw Exception(customMessage);
      }

      if (isTrue) throw Exception(customMessage);
    } on NoSuchMethodError {
      return errInvalidDate;
    } on Exception catch (err) {
      throw Exception(refinedExceptionMessage(err));
    }

    return null;
  }

  ///  @Source-Link {https://en.wikipedia.org/wiki/Leap_year}
  ///  The following pseudocode determines whether a year is a leap year or a
  ///  common year in the Gregorian calendar (and in the proleptic Gregorian
  ///  calendar before 1582). The year variable being tested is the integer
  ///  representing the number of the year in the Gregorian calendar.
  ///
  ///  if ([year] is not divisible by 4) then (it is a common year)
  ///  else if ([year] is not divisible by 100) then (it is a leap year)
  ///  else if ([year] is not divisible by 400) then (it is a common year)
  ///  else (it is a leap year)
  ///
  ///  The algorithm applies to proleptic Gregorian calendar years before 1,
  ///  but only if the year is expressed with astronomical year numbering.
  ///  It is not valid for the BC or BCE notation. The algorithm is not
  ///  necessarily valid for years in the Julian calendar, such as years before
  ///  1752 in the British Empire. The year 1700 was a leap year in the Julian
  ///  calendar, but not in the Gregorian calendar.
  static bool isLeapYear(int year) {
    if (year % 4 == 0) {
      return true;
    } else if (year % 100 == 0) {
      return false;
    } else if (year % 400 == 0) {
      return true;
    } else {
      return true;
    }
  }

  static User getUserFromToken(String token) {
    try {
      var userResponse = parseJwt(token);
      return User.fromMap(userResponse[Constants.keyUser]);
    } on Exception catch (err) {
      print(refinedExceptionMessage(err));
      return null;
    }
  }

  static Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }

  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  static Widget showHasNoDataWidget(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.defaultPadding * 4),
        child: Text(
          message,
          style: Theme.of(context).textTheme.body1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  static void showSnackBar(GlobalKey<ScaffoldState> scaffoldKey, String message,
      {bool isNetworkConnected = true,
      bool showActionButton = false,
      String actionLabel,
      Function action}) {
    assert(showActionButton ? actionLabel != null : true);
    scaffoldKey.currentState.hideCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(isNetworkConnected ? message : Constants.connectionLost),
        duration:
            isNetworkConnected ? Duration(seconds: 4) : Duration(seconds: 4),
        action: showActionButton
            ? SnackBarAction(
                label: actionLabel.toUpperCase(),
                onPressed: action,
              )
            : null,
      ),
    );
  }

  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static BeveledRectangleBorder defaultButtonShape(BuildContext context) {
    return BeveledRectangleBorder(
      side: BorderSide(color: Theme.of(context).accentColor),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Constants.buttonRadius),
        topRight: Radius.circular(Constants.buttonRadius),
        bottomLeft: Radius.circular(Constants.buttonRadius),
        bottomRight: Radius.circular(Constants.buttonRadius),
      ),
    );
  }

  static String refinedExceptionMessage(err) {
    var error =
        err.toString().replaceAll('Exception:', '').trimLeft().trimRight();

    while (error.contains('  ')) {
      error = error.replaceAll('  ', ' ');
    }

    return error;
  }

  static void onAuthStateChanged(BuildContext context, AuthState state,
      {AuthStateProvider authStateProvider,
      AuthStateListener authStateListener,
      bool isSignInScreen = false,
      bool isSplashScreen = false}) async {
    if (state == AuthState.SIGNED_IN_AND_VERIFIED) {
      try {
        await Navigator.pushReplacementNamed(context, Routes.keyHome);
        authStateProvider?.unsubscribe(authStateListener);
      } on Exception catch (e) {
        print(refinedExceptionMessage(e));
      }
    } else {
      if (state == AuthState.SIGNED_IN) {
        try {
          await Navigator.pushReplacementNamed(
              context, Routes.keyVerifyAccount);
          authStateProvider?.unsubscribe(authStateListener);
        } on Exception catch (e) {
          print(refinedExceptionMessage(e));
        }
      } else {
        if (!isSignInScreen)
          try {
            await Navigator.pushReplacementNamed(context, Routes.keySignIn);
            authStateProvider?.unsubscribe(authStateListener);
          } on Exception catch (e) {
            print(refinedExceptionMessage(e));
          }
      }
    }
  }

  static void moveToSignInScreen(BuildContext context,
      {AuthStateProvider authStateProvider,
      AuthStateListener authStateListener}) async {
    try {
      await Navigator.pushReplacementNamed(context, Routes.keySignIn);
      authStateProvider?.unsubscribe(authStateListener);
    } on Exception catch (e) {
      print(refinedExceptionMessage(e));
    }
  }
}

class Styles {
  static final TextStyle btnTextStyle = TextStyle(color: Colors.white);
}

class SQLQueries {
  // Create tables...
  static final String createUsersTable =
      "CREATE TABLE IF NOT EXISTS ${UserTable.tableName}(${UserTable.colId} "
      "VARCHAR(100) PRIMARY KEY, ${UserTable.colIdNo} VARCHAR(20) NOT NULL, "
      "${UserTable.colSName} VARCHAR(50), ${UserTable.colFName} "
      "VARCHAR(50) NOT NULL, ${UserTable.colLName} VARCHAR(50), "
      "${UserTable.colEmail} VARCHAR(150) NOT NULL, ${UserTable.colRole} "
      "VARCHAR(20) NOT NULL, ${UserTable.colMobileNo} VARCHAR(20), "
      "${UserTable.colVerified} SMALLINT(1) DEFAULT 0);";

  static final String createUserTokenTable =
      "CREATE TABLE IF NOT EXISTS ${UserTokenTable.tableName}(${UserTokenTable.colToken} "
      "TEXT);";

  static final String createUserRolesTable =
      "CREATE TABLE IF NOT EXISTS ${UserRolesTable.tableName}"
      "(${UserRolesTable.colId} INTEGER AUTO_INCREMENT PRIMARY KEY, "
      "${UserRolesTable.colName} VARCHAR(50) NOT NULL);";

  static final String createDiseasesTable =
      "CREATE TABLE IF NOT EXISTS ${DiseasesTable.tableName} "
      "(${DiseasesTable.colId} INTEGER AUTO_INCREMENT PRIMARY KEY, "
      "${DiseasesTable.colName} VARCHAR(200) NOT NULL, "
      "${DiseasesTable.colDesc} TEXT);";

  static final String createCentersTable =
      "CREATE TABLE IF NOT EXISTS ${CentersTable.tableName}"
      "(${CentersTable.colId} INTEGER AUTO_INCREMENT PRIMARY KEY, "
      "${CentersTable.colName} VARCHAR(100) NOT NULL);";

  // Delete tables...
  static final String dropUsersTable =
      "DROP TABLE IF EXISTS ${UserTable.tableName};";

  static final String dropUserRolesTable =
      "DROP TABLE IF EXISTS ${UserRolesTable.tableName};";

  static final String dropDiseasesTable =
      "DROP TABLE IF EXISTS ${DiseasesTable.tableName};";

  static final String dropCentersTable =
      "DROP TABLE IF EXISTS ${CentersTable.tableName};";
}

class UserRolesTable {
  static final String tableName = 'user_roles';
  static final String colId = 'id';
  static final String colName = 'name';
}

class DiseasesTable {
  static final String tableName = 'diseases';
  static final String colId = 'duid';
  static final String colName = 'name';
  static final String colDesc = 'description';
}

class CentersTable {
  static final String tableName = 'centers';
  static final String colId = 'id';
  static final String colName = 'name';
}

class UserTable {
  static final String tableName = "users";
  static final String colToken = 'token';
  static final String colId = 'uuid';
  static final String colIdNo = 'idNo';
  static final String colSName = 'sName';
  static final String colFName = 'fName';
  static final String colLName = 'lName';
  static final String colEmail = 'email';
  static final String colRole = 'role';
  static final String colMobileNo = 'mobileNo';
  static final String colVerified = 'verified';
}

class UserTokenTable {
  static final String tableName = "user_token";
  static final String colToken = 'token';
}

class RestKeys {
  static final String keyUserId = 'uuid';
  static final String keyRecordNo = 'no';
  static final String keyId = 'id';
  static final String keyEmail = 'email';
  static final String keyDeviceId = 'deviceId';
}

class PreferenceKeys {
  static final String keySkipSignIn = 'keySkipSignIn';
}

class Routes {
  static final String keyDefault = '/';
  static final String keyHome = '/home';
  static final String keyAbout = '/about';
  static final String keySignIn = '/signIn';
  static final String keySignUp = '/signUp';
  static final String keyChangePass = '/changePass';
  static final String keyResetPass = '/resetPass';
  static final String keyVerifyAccount = '/verifyAccount';
  static final String keyCharts = '/charts';
  static final String keyChildRegister = '/childRegister';
  static final String keyChildrenTable = '/childrenTable';
  static final String keyMyChildren = '/myChildren';
  static final String keyUsersTable = '/users';
  static final String keyDiseaseAdd = '/diseaseAdd';
  static final String keyDiseasesTable = '/diseasesTable';
  static final String keyFeedback = '/feedback';
  static final String keyHelp = '/help';
  static final String keyEducativePostAdd = '/educativePostAdd';
  static final String keyEducativePosts = '/educativePostAdd';
  static final String keyScheduleAdd = '/scheduleAdd';
  static final String keyScheduleTable = '/scheduleAdd';
  static final String keyImmunizationAdd = '/immunizationAdd';
  static final String keyImmunizationsTable = '/immunizationsTable';
  static final String keyProfile = '/profile';
  static final String keySplash = '/splash';
  static final String keyPovAdd = '/povAdd';
  static final String keyPovsTable = '/povsTable';
  static final String keyVaccineAdd = '/vaccineAdd';
  static final String keyVaccinesTable = '/vaccinesTable';
}

class Urls {
//  static final String _baseUrl = "http://nvip.krizlaapp.com/NVIP";
//  static final String _baseUrl = "http://10.0.2.2:8888/NVIP";
  static final String _baseUrl = "http://10.0.2.2:8888/NVIP";
  static final String _baseAPIUrl = "$_baseUrl/RestAPI";
  static final String _immunizationRoot = "$_baseAPIUrl/immunization";
  static final String _userRoot = "$_baseAPIUrl/user";
  static final String _adminRoot = "$_userRoot/admin";
  static final String _imagesRoot = "$_baseUrl/images";
  static final String _childRoot = "$_baseAPIUrl/child";
  static final String _diseasesRoot = "$_baseAPIUrl/diseases";
  static final String _vaccinesRoot = "$_baseAPIUrl/vaccines";
  static final String _centersRoot = "$_baseAPIUrl/centers";
  static final String _postsRoot = "$_baseAPIUrl/posts";
  static final String _educativePostsRoot = "$_postsRoot/educative";
  static final String _schedulePostsRoot = "$_postsRoot/schedules";
  static final String mailSendTempPass = "$_baseAPIUrl/mail/sendTempPass.php";

  static String getImmunizations(
          {String userId, String no = Constants.immunizationRecNoAll}) =>
      "$_immunizationRoot/get.php?${RestKeys.keyUserId}=$userId&${RestKeys.keyRecordNo}=$no";
  static final String immunizationAdd = "$_immunizationRoot/add.php";
  static final String immunizationDelete = "$_immunizationRoot/delete.php";
  static final String immunizationUpdate = "$_immunizationRoot/update.php";

  static String getVaccineCenters() => "$_centersRoot/get.php";
  static final String centerAdd = "$_centersRoot/add.php";
  static final String centerDelete = "$_centersRoot/delete.php";
  static final String centerUpdate = "$_centersRoot/update.php";

  static String getChildren(
          {String userId, String no = Constants.childrenRecNoAll}) =>
      "$_childRoot/get.php?${RestKeys.keyUserId}=$userId&${RestKeys.keyRecordNo}=$no";
  static final String childRegister = "$_childRoot/register.php";
  static final String childDelete = "$_childRoot/delete.php";
  static final String childUpdate = "$_childRoot/update.php";

  static String getDiseases() => "$_diseasesRoot/get.php";
  static final String diseaseAdd = "$_diseasesRoot/add.php";
  static final String diseaseDelete = "$_diseasesRoot/delete.php";
  static final String diseaseUpdate = "$_diseasesRoot/update.php";

  static String getVaccines() => "$_vaccinesRoot/get.php";
  static final String vaccineAdd = "$_vaccinesRoot/add.php";
  static final String vaccineDelete = "$_vaccinesRoot/delete.php";
  static final String vaccineUpdate = "$_vaccinesRoot/update.php";

  static String getEducativePosts([String postId]) =>
      "$_educativePostsRoot/get.php?${RestKeys.keyId}=$postId";

  static String getAllEducativePosts() => "$_educativePostsRoot/getAll.php";
  static final String educativeAdd = "$_educativePostsRoot/add.php";
  static final String educativeDelete = "$_educativePostsRoot/delete.php";
  static final String educativeUpdate = "$_educativePostsRoot/update.php";

  static String getSchedule([String postId]) =>
      "$_schedulePostsRoot/get.php?${RestKeys.keyId}=$postId";

  static String getAllSchedules() => "$_schedulePostsRoot/getAll.php";
  static final String scheduleAdd = "$_schedulePostsRoot/add.php";
  static final String scheduleDelete = "$_schedulePostsRoot/delete.php";
  static final String scheduleUpdate = "$_schedulePostsRoot/update.php";

  static String getUsers(String uuid) =>
      "$_adminRoot/getUsers.php?${RestKeys.keyUserId}=$uuid";
  static final String userSignUp = "$_userRoot/signUp.php";
  static final String userSignIn = "$_userRoot/signIn.php";
  static final String userSignOut = "$_userRoot/signOut.php";
  static final String userVerifyAccount = "$_userRoot/verifyAccount.php";
  static final String userUpdateDeviceId = "$_userRoot/updateDeviceId.php";
  static final String userUpdateProfile = "$_userRoot/updateProfile.php";
  static final String userResetPass = "$_userRoot/resetPassword.php";
  static final String userRemove = "$_userRoot/remove.php";
  static final String adminDeactivateAccount =
      "$_adminRoot/deactivateAccount.php";
  static final String adminRevokePrivileges =
      "$_adminRoot/revokePrivileges.php";

  static String getPostImage(String postId) =>
      "$_imagesRoot/educative/downloadImage.php?id=$postId";

  static String getChildImage(String childId) =>
      "$_imagesRoot/children/downloadImage.php?id=$childId";

  static String getUserImage(String userId) =>
      "$_imagesRoot/users/downloadImage.php?id=$userId";
}
