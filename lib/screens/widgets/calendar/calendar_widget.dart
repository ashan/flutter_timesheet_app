import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:date_utils/date_utils.dart';
import '../../../models/calendar.dart';
import './time_entry_summary_widget.dart';

class CalendarWidget extends StatefulWidget {
  static const String ROUTE = "CalendarScreen";
  @override
  State<StatefulWidget> createState() {
    return _CalendarWidgetState();
  }
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final _scrollController = ScrollController();
  double _individualDateWidth = 40.0;
  double _datesWidgetHeight = 70.0;

  @override
  void initState() {
    super.initState();
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
          elevation: 0.0,
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
                ],
              ),
              _datesWidget(calendar),
              _calendarNaivigationWidgets(calendar),
            ],
          ),
        ),
        Expanded(
          child: TimeEntryDetailsSummaryWidget(),
        )
      ],
    );
  }

  Widget _datesWidget(CalendarModel calendar) {
    var stackChildren = <Widget>[
      Padding(
        padding: EdgeInsets.only(left: 0, right: 0),
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: calendar.currentTimeSheetPeriod.periodDays.length,
          itemBuilder: (context, index) {
            final currentDate =
                calendar.currentTimeSheetPeriod.periodDays.keys.toList()[index];
            return SizedBox(
              width: _individualDateWidth,
              height: _datesWidgetHeight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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

    return Card(
      elevation: 8,
      child: Padding(
        padding: EdgeInsets.only(top: 10),
        child: Container(
          height: _datesWidgetHeight,
          child: Stack(
            children: stackChildren,
          ),
        ),
      ),
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
    final isSelectedDate =
        calendar.currentTimeSheetPeriod.isSelectedDate(currentDate);
    final decoration = BoxDecoration(
      border: isSelectedDate
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
            color: Theme.of(context).accentColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey[500],
                offset: Offset(0.0, 2.5),
                blurRadius: 5.5,
              ),
            ],
          ),
        ),
      );
    }
    children.add(
      InkWell(
        onTap: () => calendar.onDateTap(currentDate),
        child: Container(
          decoration: decoration,
          padding: EdgeInsets.all(10),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
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
      ),
    );

    return Material(
      elevation: isSelectedDate ? 2 : 8,
      color: isSelectedDate ? Colors.transparent : null,
      child: Stack(
        children: children,
      ),
    );
  }

  Widget _calendarNaivigationWidgets(CalendarModel calendar) {
    return Padding(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Card(
        elevation: 8,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _jumpToTodayButton(calendar),
                    _selectAllWorkingDays(calendar),
                  ],
                ),
                Row(
                  children: <Widget>[
                    _navigatePeriodButton(calendar),
                    SizedBox(width: 10),
                    _navigatePeriodButton(calendar, isNextPeriod: true),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _navigatePeriodButton(CalendarModel calendar,
      {bool isNextPeriod = false}) {
    if (calendar.isNextPeriodLoading || calendar.isNextPeriodLoading) {
      return SizedBox(
        height: 0,
      );
    }
    Icon icon = Icon(
      isNextPeriod ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_left,
      size: 30,
    );
    Function onTap =
        isNextPeriod ? calendar.onTapNextPeriod : calendar.onTapPreviousPeriod;
    Text text = Text(isNextPeriod ? 'next' : 'prev');

    final children = isNextPeriod ? [text, icon] : [icon, text];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      alignment: Alignment.center,
      child: InkWell(
        onTap: onTap,
        splashColor: Theme.of(context).primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  Widget _jumpToTodayButton(CalendarModel calendar) {
    final children = <Widget>[
      Icon(Icons.today),
      SizedBox(
        width: 2,
      ),
      Text('today')
    ];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          calendar.onTodayTap();
          final todayKey = calendar.currentTimeSheetPeriod.periodDays.keys
              .firstWhere((d) => Utils.isSameDay(d, DateTime.now()));

          final todayIndex = calendar.currentTimeSheetPeriod.periodDays.keys
              .toList()
              .indexOf(todayKey);
          _scrollController.animateTo(((todayIndex + 4) * _individualDateWidth),
              duration: Duration(seconds: 2), curve: Curves.ease);
        },
        splashColor: Theme.of(context).primaryColorDark,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  Widget _selectAllWorkingDays(CalendarModel calendar) {
    final children = <Widget>[
      Icon(Icons.select_all,
          color: calendar.isAllWorkingDaysSelected ? Colors.green : null),
      SizedBox(
        width: 2,
      ),
      Text('all working days')
    ];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      alignment: Alignment.center,
      child: InkWell(
        onTap: calendar.onAllWorkinngDaysTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
