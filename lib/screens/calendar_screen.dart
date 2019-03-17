import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:date_utils/date_utils.dart';
import '../models/calendar.dart';

class CalendarScreen extends StatefulWidget {
  static const String ROUTE = "CalendarScreen";
  @override
  State<StatefulWidget> createState() {
    return _CalendarScreenState();
  }
}

class _CalendarScreenState extends State<CalendarScreen> {
  static double _calendarElevation = 8.0;
  static double _calendarHeight = 250;
  double _bodyHeight = _calendarHeight;
  bool _openCalenderWidget = true;
  bool _selectAllDatesPressed = false;

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<CalendarModel>(
      builder: (BuildContext context, Widget widget, CalendarModel calendar) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Calendar App'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildCalendarCard(context, calendar),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarCard(BuildContext context, CalendarModel calendar) {
    final heading = Text(
      _openCalenderWidget
          ? calendar.headingDisplayStr
          : calendar.subHeadingDisplayStr,
      style: Theme.of(context)
          .textTheme
          .title
          .copyWith(fontWeight: FontWeight.w500),
    );
    final closeArrow = IconButton(
      icon: Icon(_openCalenderWidget
          ? Icons.keyboard_arrow_up
          : Icons.keyboard_arrow_down),
      onPressed: () {
        setState(
          () {
            _bodyHeight = _openCalenderWidget ? 0 : _calendarHeight;
            _openCalenderWidget = !_openCalenderWidget;
          },
        );
      },
    );

    final headerRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[heading, closeArrow],
    );

    final subHeading = Text(
      calendar.subHeadingDisplayStr,
      style: Theme.of(context).textTheme.title.copyWith(
            fontWeight: FontWeight.w300,
          ),
    );
    final subHeaderRow = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        subHeading,
      ],
    );

    final calendarHeaderGrid = Column(
      children: <Widget>[
        GridView.count(
          childAspectRatio: 2,
          crossAxisCount: 7,
          shrinkWrap: true,
          children: <Widget>[
            _calendarDayName(context, 'Mon'),
            _calendarDayName(context, 'The'),
            _calendarDayName(context, 'Wed'),
            _calendarDayName(context, 'Thu'),
            _calendarDayName(context, 'Fri'),
            _calendarDayName(context, 'Sat'),
            _calendarDayName(context, 'Sun'),
          ],
        ),
        Divider(),
      ],
    );

    final calendarBodyGrid = calendar.isCalendarBusy
        ? Center(child: CircularProgressIndicator())
        : GridView.count(
            crossAxisCount: 7,
            childAspectRatio: 1.5,
            shrinkWrap: true,
            children: _buildCalendarGrid(context, calendar),
          );

    final nextPeriodPreviousPeriodRow = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FlatButton.icon(
          icon: Icon(
            Icons.today,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
          onPressed: () {
            calendar.jumpToDate(DateTime.now());
          },
          label: Text(
            'Today',
            textScaleFactor: 0.8,
            style: Theme.of(context).textTheme.subtitle.copyWith(
                  fontWeight: FontWeight.w400,
                ),
          ),
        ),
        FlatButton.icon(
          icon: Icon(
            Icons.date_range,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
          onPressed: () {
            calendar.onSelectAllTap(!_selectAllDatesPressed);
            setState(() => _selectAllDatesPressed = !_selectAllDatesPressed);
          },
          label: Text(
            !_selectAllDatesPressed ? 'Select all' : 'Unselect all',
            textScaleFactor: 0.8,
            style: Theme.of(context).textTheme.subtitle.copyWith(
                  fontWeight: FontWeight.w400,
                ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(),
        ),
        IconButton(
          icon: Icon(Icons.keyboard_arrow_left),
          onPressed: calendar.onTapPreviousPeriod,
        ),
        // SizedBox(width: 10.0),
        IconButton(
            icon: Icon(Icons.keyboard_arrow_right),
            onPressed: () {
              calendar.onTapNextPeriod();
            }),
      ],
    );

    final cardBody = AnimatedContainer(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            subHeaderRow,
            SizedBox(height: 15.0),
            calendarHeaderGrid,
            calendarBodyGrid,
            SizedBox(height: 15.0),
            Divider(),
            nextPeriodPreviousPeriodRow,
          ],
        ),
      ),
      curve: Curves.easeOut,
      duration: Duration(milliseconds: 50),
      height: _bodyHeight,
    );

    final calendarCard = Card(
      elevation: _calendarElevation,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            headerRow,
            cardBody,
          ],
        ),
      ),
    );

    return calendarCard;
  }

  List<Widget> _buildCalendarGrid(
      BuildContext context, CalendarModel calendar) {
    // if calendar is still loading display spinner
    // if (calendar.isCalendarBusy) {
    //   return [Center(child: CircularProgressIndicator())];
    // }

    final grid = <Widget>[];
    // grid is 7 columns, build the day names first
    final allDays = calendar.currentTimeSheetPeriod.periodDays.keys.toList();

    // fill with blank days till the first day
    for (int i = 0; i < allDays.first.weekday - 1; i++) {
      grid.add(Container(
        alignment: Alignment.center,
      ));
    }
    // add first day
    for (int i = 0; i < allDays.length; i++) {
      final d = allDays[i];
      var foreGroundDecoration = BoxDecoration();
      var decoration = BoxDecoration();
      if (Utils.isSameDay(DateTime.now(), d)) {
        if (calendar.currentTimeSheetPeriod.isSelectedDate(d)) {
          foreGroundDecoration = BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).accentColor,
              backgroundBlendMode: BlendMode.color);
        }
        decoration = BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).accentColor.withOpacity(0.5),
        );
      }
      if (calendar.currentTimeSheetPeriod.isSelectedDate(d)) {
        decoration = BoxDecoration(
          color: Colors.orangeAccent,
        );
      }

      grid.add(
        InkWell(
          onTap: () => calendar.onDateTap(d),
          child: Container(
            alignment: Alignment.center,
            decoration: decoration,
            foregroundDecoration: foreGroundDecoration,
            child: Text(
              d.day.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
        ),
      );
    }

    return grid;
  }

  Widget _calendarDayName(BuildContext context, String dayName) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        dayName,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).disabledColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
