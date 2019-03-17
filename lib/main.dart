import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:scoped_model/scoped_model.dart';

import './models/calendar.dart';
import './screens/login_screen.dart';
import './screens/calendar_screen.dart';

void main() {
  // debugPaintSizeEnabled = true;
  runApp(CalendarApp());
}

class CalendarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var calendar = CalendarModel.init();
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Roboto'),
      title: 'Time Sheet',
      initialRoute: LoginScreen.ROUTE,
      routes: <String, WidgetBuilder>{
        LoginScreen.ROUTE: (BuildContext context) {
          return ScopedModel<CalendarModel>(
            model: calendar,
            child: LoginScreen(),
          );
        },
        CalendarScreen.ROUTE: (BuildContext context) {
          return ScopedModel<CalendarModel>(
            model: calendar,
            child: CalendarScreen(),
          );
        }
      },
    );
  }
}
