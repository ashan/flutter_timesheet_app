import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import '../models/calendar.dart';
import './time_entry_overlay.dart';
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
  var dummy = false;
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<CalendarModel>(
      builder: (BuildContext context, Widget widget, CalendarModel calendar) {
        if (calendar.needsLoginIn) {
          calendar.onTapLogout();
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
          onWillPop: calendar.onTapLogout,
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
                    onPressed: () => Navigator.of(context)
                        .push(
                          TimeEntryOverlay(calendar),
                        )
                        // .then(
                        //   (value) => setState(() => calendar.notifyListeners()),
                        // ),
                  )
                : null,
            bottomNavigationBar: BottomAppBar(
              elevation: 8,
              shape: CircularNotchedRectangle(),
              notchMargin: 4.0,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // _navigatePeriodButton(calendar),
                  // _navigatePeriodButton(calendar, isNextPeriod: true),
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

class RedrawHelper extends InheritedWidget {
  RedrawHelper({
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  bool _toggle = false;
  static RedrawHelper of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(RedrawHelper);
  }

  void toggle() {
    _toggle = !_toggle;
  }

  @override
  bool updateShouldNotify(RedrawHelper oldWidget) =>
      _toggle != oldWidget._toggle;
}
