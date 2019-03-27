import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import '../models/calendar.dart';
import './widgets/calendar/calendar_widget.dart';
import './widgets/assorted_widgets.dart';
import '../providers/tmesheet.dart';

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
        if (calendar.needsLoginIn) {
          calendar.onExitCalendarScreen();
          Navigator.pop(context);
          return Container();
        }
        final children = <Widget>[
          CalendarWidget(),
        ];

        if (calendar.isBusy) {
          children.add(AssortedWidgets.progressIndicator);
        }
        return WillPopScope(
          onWillPop: () {
            calendar.onExitCalendarScreen();
            return TimeSheetProvider().logOut();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text('Calendar App'),
              elevation: 8.0,
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: calendar.currentTimeSheetPeriod.isEditable
                ? FloatingActionButton(
                    child: const Icon(Icons.add),
                    onPressed: () => calendar.test(),
                  )
                : null,
            bottomNavigationBar: BottomAppBar(
              elevation: 8,
              shape: CircularNotchedRectangle(),
              notchMargin: 4.0,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _navigatePeriodButton(calendar),
                  _navigatePeriodButton(calendar, isNextPeriod: true),
                ],
              ),
            ),
            body: Stack(
              children: children,
            ),
          ),
        );
      },
    );
  }

  Widget _navigatePeriodButton(CalendarModel calendar,
      {bool isNextPeriod = false}) {
    if (calendar.isNextPeriodLoading || calendar.isNextPeriodLoading)
      return SizedBox(
        height: 50,
      );

    List<Widget> children = isNextPeriod
        ? [Text('Next Period'), Icon(Icons.keyboard_arrow_right)]
        : [Icon(Icons.keyboard_arrow_left), Text('Previous Period')];
    return SizedBox(
      height: 50,
      child: InkWell(
        onTap: isNextPeriod
            ? calendar.onTapNextPeriod
            : calendar.onTapPreviousPeriod,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: children,
        ),
      ),
    );
  }
}
