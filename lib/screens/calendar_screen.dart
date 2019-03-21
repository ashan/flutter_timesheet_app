import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import '../models/calendar.dart';
import './widgets/calendar/calendar_widget.dart';
import './widgets/assorted_widgets.dart';

class CalendarScreen extends StatefulWidget {
  static const String ROUTE = "CalendarScreen";
  @override
  State<StatefulWidget> createState() {
    return _CalendarScreenState();
  }
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<CalendarModel>(
      builder: (BuildContext context, Widget widget, CalendarModel calendar) {
        final children = <Widget>[
          CalendarWidget(),
        ];

        if (calendar.isBusy) {
          children.add(AssortedWidgets.progressIndicator);
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Calendar App'),
            elevation: 8.0,
          ),
          body: Stack(
            children: children,
          ),
        );
      },
    );
  }
}
