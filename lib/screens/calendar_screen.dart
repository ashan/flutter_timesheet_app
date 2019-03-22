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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: calendar.currentTimeSheetPeriod.isEditable ? FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {},
          ): null,
          bottomNavigationBar: BottomAppBar(
            elevation: 8,
            shape: CircularNotchedRectangle(),
            notchMargin: 4.0,
            child: new Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          body: Stack(
            children: children,
          ),
        );
      },
    );
  }


}
