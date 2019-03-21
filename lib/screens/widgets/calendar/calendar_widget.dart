import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:date_utils/date_utils.dart';
import '../../../models/calendar.dart';
import './time_details_widget.dart';

class CalendarWidget extends StatefulWidget {
  static const String ROUTE = "CalendarScreen";
  @override
  State<StatefulWidget> createState() {
    return _CalendarWidgetState();
  }
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final _scrollController = ScrollController();
  double _dateWidth = 50.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      print(_scrollController.position.extentAfter);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<CalendarModel>(
      builder: (BuildContext context, Widget widget, CalendarModel calendar) {
        return _build(context, calendar);
      },
    );
  }

  Widget _build(BuildContext context, CalendarModel calendar) {
    return Column(
      children: <Widget>[
        Card(
          elevation: 8.0,
          margin: EdgeInsets.all(0.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: ListTile(
                      title: Text(calendar.headingDisplayStr),
                      subtitle: Text(calendar.subHeadingDisplayStr),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.today),
                    onPressed: () {
                      calendar.onTodayTap();
                      final todayIndex = calendar
                          .currentTimeSheetPeriod.periodDays.keys
                          .toList()
                          .indexOf(DateTime.now());
                      _scrollController.animateTo(todayIndex * _dateWidth,
                          duration: Duration(seconds: 2), curve: Curves.ease);
                    },
                  ),
                ],
              ),
              Container(
                height: 70,
                child: _datesWidget(calendar),
              ),
            ],
          ),
        ),
        Expanded(
          child: TimeEntryDetails(),
        )
      ],
    );
  }

  Widget _datesWidget(CalendarModel calendar) {
    final leftPadding = calendar.isPreviousPeriodLoading ? 10.0 : 50.0;
    final rightPaddingPadding = calendar.isNextPeriodLoading ? 10.0 : 50.0;
    var stackChildren = <Widget>[
      Padding(
        padding: EdgeInsets.only(left: leftPadding, right: rightPaddingPadding),
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: calendar.currentTimeSheetPeriod.periodDays.length,
          itemBuilder: (context, index) {
            final currentDate =
                calendar.currentTimeSheetPeriod.periodDays.keys.toList()[index];
            return SizedBox(
              width: _dateWidth,
              child: Column(
                children: <Widget>[
                  _getDay(calendar, currentDate),
                  Divider(),
                  _getDate(calendar, currentDate),
                ],
              ),
            );
          },
        ),
      ),
    ];

    if (!calendar.isPreviousPeriodLoading) {
      stackChildren.add(
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            alignment: Alignment.topLeft,
            icon: Icon(
              Icons.keyboard_arrow_left,
            ),
            onPressed: calendar.onTapPreviousPeriod,
          ),
        ),
      );
    }
    if (!calendar.isNextPeriodLoading) {
      stackChildren.add(
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            alignment: Alignment.topRight,
            icon: Icon(
              Icons.keyboard_arrow_right,
            ),
            onPressed: calendar.onTapNextPeriod,
          ),
        ),
      );
    }

    return Stack(
      children: stackChildren,
    );
  }

  Widget _getDay(CalendarModel calendar, DateTime date) {
    return Text(
      DateFormat.E().format(date),
      textScaleFactor: 0.8,
      style: Theme.of(context).textTheme.body1.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _getDate(CalendarModel calendar, DateTime currentDate) {
    final decoration = BoxDecoration(
      border: calendar.currentTimeSheetPeriod.isSelectedDate(currentDate)
          ? Border(
              bottom: BorderSide(
                width: 3.0,
                color: Colors.red.shade500,
              ),
            )
          : Border(),
    );

    final children = <Widget>[];

    if (Utils.isSameDay(DateTime.now(), currentDate)) {
      children.add(
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).accentColor.withOpacity(0.5),
          ),
        ),
      );
    }
    children.add(
      Container(
        alignment: Alignment.center,
        decoration: decoration,
        padding: EdgeInsets.all(10.0),
        child: InkWell(
          onTap: () => calendar.onDateTap(currentDate),
          child: Text(
            DateFormat.d().format(currentDate),
            textAlign: TextAlign.center,
            textScaleFactor: 0.8,
            style: Theme.of(context).textTheme.body2.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ),
    );

    return Stack(
      children: children,
    );
  }
}
