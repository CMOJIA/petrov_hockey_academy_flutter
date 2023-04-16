import 'package:flutter/widgets.dart';
import 'package:petrov_hockey_academy_flutter/app/app.dart';
import 'package:petrov_hockey_academy_flutter/login/login.dart';
import 'package:petrov_hockey_academy_flutter/timetables/timetables.dart';

List<Page<dynamic>> onGenerateAppViewPages(
  AppStatus state,
  List<Page<dynamic>> pages,
) {
  switch (state) {
    case AppStatus.authenticated:
      return [TabsScreen.page()];
    case AppStatus.unauthenticated:
      return [LoginPage.page()];
  }
}
