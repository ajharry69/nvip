import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/scenes/about/screen_about.dart';
import 'package:nvip/scenes/accounts/login/screen_sign_in.dart';
import 'package:nvip/scenes/accounts/pwd/screen_reset_pass.dart';
import 'package:nvip/scenes/accounts/register/screen_sign_up.dart';
import 'package:nvip/scenes/accounts/verify/screen_verify_account.dart';
import 'package:nvip/scenes/charts/screen_charts.dart';
import 'package:nvip/scenes/children/screen_child_register.dart';
import 'package:nvip/scenes/children/screen_children_table.dart';
import 'package:nvip/scenes/diseases/screen_disease_add.dart';
import 'package:nvip/scenes/diseases/screen_diseases_table.dart';
import 'package:nvip/scenes/feedback/screen_feedback.dart';
import 'package:nvip/scenes/help/screen_help.dart';
import 'package:nvip/scenes/home/children/screen_my_children.dart';
import 'package:nvip/scenes/home/educative/screen_educative_post_add.dart';
import 'package:nvip/scenes/home/educative/screen_educative_posts.dart';
import 'package:nvip/scenes/home/schedules/screen_schedule_add.dart';
import 'package:nvip/scenes/home/schedules/screen_schedule_table.dart';
import 'package:nvip/scenes/home/screen_home.dart';
import 'package:nvip/scenes/immunizations/screen_immunization_add.dart';
import 'package:nvip/scenes/immunizations/screen_immunizations_table.dart';
import 'package:nvip/scenes/profile/screen_profile.dart';
import 'package:nvip/scenes/splash/screen_splash.dart';
import 'package:nvip/scenes/users/screen_users.dart';
import 'package:nvip/scenes/vaccination_centers/screen_center_add.dart';
import 'package:nvip/scenes/vaccination_centers/screen_center_table.dart';
import 'package:nvip/scenes/vaccines/screen_vaccine_add.dart';
import 'package:nvip/scenes/vaccines/screen_vaccines_table.dart';

final routes = {
  Routes.keyDefault: (BuildContext context) => SplashScreen(),
  Routes.keyAbout: (BuildContext context) => AboutPage(),
  Routes.keySignIn: (BuildContext context) => SignInScreen(),
//  Routes.keyChangePass: (BuildContext context) => ChangePasswordScreen(),
  Routes.keyResetPass: (BuildContext context) => PasswordResetScreen(),
  Routes.keySignUp: (BuildContext context) => SignUpScreen(),
  Routes.keyVerifyAccount: (BuildContext context) => VerifyAccountScreen(),
  Routes.keyCharts: (BuildContext context) => ChartsScreen(),
  Routes.keyChildRegister: (BuildContext context) => RegisterChildScreen(
        callerId: RegisterCallerId.table,
      ),
  Routes.keyChildrenTable: (BuildContext context) => ChildrenTableScreen(),
  Routes.keyMyChildren: (BuildContext context) => MyChildrenScreen(),
  Routes.keyUsersTable: (BuildContext context) => UsersListScreen(),
  Routes.keyDiseaseAdd: (BuildContext context) => AddDiseaseScreen(),
  Routes.keyDiseasesTable: (BuildContext context) => DiseasesTableScreen(),
  Routes.keyFeedback: (BuildContext context) => FeedbackScreen(),
  Routes.keyHelp: (BuildContext context) => HelpScreen(),
  Routes.keyEducativePostAdd: (BuildContext context) =>
      AddEducativePostScreen(),
  Routes.keyEducativePosts: (BuildContext context) => EducativePostsScreen(),
  Routes.keyScheduleAdd: (BuildContext context) => AddScheduleScreen(),
  Routes.keyScheduleAdd: (BuildContext context) => SchedulesTableScreen(),
  Routes.keyHome: (BuildContext context) => HomeScreen(),
  Routes.keyImmunizationAdd: (BuildContext context) => AddImmunizationScreen(),
  Routes.keyImmunizationsTable: (BuildContext context) =>
      ImmunizationsTableScreen(),
  Routes.keyProfile: (BuildContext context) => ProfileScreen(),
  Routes.keySplash: (BuildContext context) => SplashScreen(),
  Routes.keyPovAdd: (BuildContext context) => AddVaccinationCenterScreen(),
  Routes.keyPovsTable: (BuildContext context) =>
      VaccinationCentersTableScreen(),
  Routes.keyVaccineAdd: (BuildContext context) => AddVaccineScreen(),
  Routes.keyVaccinesTable: (BuildContext context) => VaccinesTableScreen(),
};
