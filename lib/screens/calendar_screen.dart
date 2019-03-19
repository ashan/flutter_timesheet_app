import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import '../models/calendar.dart';
import './widgets/calendar/calendar_widget.dart';
import './widgets/assorted_widgets.dart';
import './widgets/calendar/time_details_widget.dart';

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
    return Scaffold(
        appBar: AppBar(
          title: Text('Calendar App'),
        ),
        body: CalendarWidget());
  }

  // @override
  Widget _build(BuildContext context) {
    return ScopedModelDescendant<CalendarModel>(
      builder: (BuildContext context, Widget widget, CalendarModel calendar) {
        final children = <Widget>[
          Column(
            children: <Widget>[
              CalendarWidget(),
              calendar.currentTimeSheetPeriod.selectedDates.length > 0
                  ? Expanded(
                      child: TimeDetailsWidget(),
                    )
                  : Container(),
            ],
          ),
        ];

        if (calendar.isCalendarBusy) {
          children.add(AssortedWidgets.progressIndicator);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Calendar App'),
          ),
          body: Stack(
            children: children,
          ),
        );
      },
    );
  }
}
