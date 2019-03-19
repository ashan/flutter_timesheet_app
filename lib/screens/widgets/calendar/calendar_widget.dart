import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:date_utils/date_utils.dart';
import '../../../models/calendar.dart';

class CalendarWidget extends StatefulWidget {
  static const String ROUTE = "CalendarScreen";
  @override
  State<StatefulWidget> createState() {
    return _CalendarWidgetState();
  }
}

class _CalendarWidgetState extends State<CalendarWidget> {
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
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text(calendar.headingDisplayStr),
                subtitle: Text(calendar.subHeadingDisplayStr),
              ),
              Container(
                height: 60,
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        calendar.currentTimeSheetPeriod.periodDays.length,
                    itemBuilder: (context, index) {
                      final currentDate = calendar
                          .currentTimeSheetPeriod.periodDays.keys
                          .toList()[index];
                      return SizedBox(
                        width: 50,
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
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
              child: ListView.builder(
            itemCount: calendar.currentTimeSheetPeriod.selectedDates.length,
            itemBuilder: (context, selectedDateIndex) {
              final selectedDate = calendar
                  .currentTimeSheetPeriod.selectedDates.values
                  .toList()[selectedDateIndex];

              return ListView.builder(
                shrinkWrap: true,
                itemCount: selectedDate.timeEntryDetails.length,
                itemBuilder: (context, timeEntryIndex) {
                  final entryInfo = selectedDate.timeEntryDetails.values
                      .toList()[timeEntryIndex];
                  return Card(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            entryInfo.selectedClientCodeInfo.toString(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          )),
        )
      ],
    );
  }

  Widget _getDay(CalendarModel calendar, DateTime currentDatet) {
    return Text(
      DateFormat.E().format(currentDatet),
      textScaleFactor: 0.8,
      style: Theme.of(context).textTheme.body1.copyWith(
            fontWeight: FontWeight.w400,
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

    final children = <Widget>[
      Container(
        alignment: Alignment.center,
        decoration: decoration,
        padding: EdgeInsets.all(5.0),
        child: InkWell(
          onTap: () => calendar.onDateTap(currentDate),
          child: Text(
            DateFormat.d().format(currentDate),
            textAlign: TextAlign.center,
            textScaleFactor: 0.8,
            style: Theme.of(context).textTheme.body2.copyWith(
                  fontWeight: FontWeight.w300,
                ),
          ),
        ),
      ),
    ];

    if (Utils.isSameDay(DateTime.now(), currentDate)) {
      children.add(
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).accentColor.withOpacity(0.5),
          ),
        ),
      );
    }

    return Stack(
      children: children,
    );
  }
}
