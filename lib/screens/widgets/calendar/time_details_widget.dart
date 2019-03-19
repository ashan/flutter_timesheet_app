import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/calendar.dart';
import '../../../models/date_info.dart';

class TimeDetailsWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TimeDetailsWidgetState();
  }
}

class _TimeDetailsWidgetState extends State<TimeDetailsWidget> {
  static double _timeEntryCardHeight = 250;
  var _openTimeEntryDetails = true;
  double _headerOpenHeight = 50;
  double _headerCloseHeight = 20;
  double _bodyHeight = _timeEntryCardHeight;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[_cardHeader, _cardBody],
        ),
      ),
    );
  }

  Widget get _cardHeader {
    final heading = Text(
      'Time Entry Details',
      style: Theme.of(context)
          .textTheme
          .title
          .copyWith(fontWeight: FontWeight.w500),
    );

    final closeArrow = IconButton(
      padding: EdgeInsets.all(0),
      icon: Icon(_openTimeEntryDetails
          ? Icons.keyboard_arrow_up
          : Icons.keyboard_arrow_down),
      onPressed: () {
        setState(
          () {
            _bodyHeight = _openTimeEntryDetails ? 0 : _timeEntryCardHeight;
            _openTimeEntryDetails = !_openTimeEntryDetails;
          },
        );
      },
    );

    return AnimatedContainer(
      curve: Curves.easeOut,
      duration: Duration(milliseconds: 50),
      height: _openTimeEntryDetails ? _headerOpenHeight : _headerCloseHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[heading, closeArrow],
      ),
    );
  }

  Widget get _cardBody {
    return ScopedModelDescendant<CalendarModel>(
      builder: (BuildContext context, Widget widget, CalendarModel calendar) {
        return Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: calendar.currentTimeSheetPeriod.selectedDates.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildSelectedDateCard(calendar
                  .currentTimeSheetPeriod.selectedDates.values
                  .toList()[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildSelectedDateCard(DateInfo selectedDate) {
    var header = Row(
      children: <Widget>[
        Text(
          selectedDate.toString(),
        ),
      ],
    );

    var client = DropdownButton(
      value: selectedDate.timeEntryDetails[0].id,
      items: selectedDate.timeEntryDetails[0].clientCodes
          .map((cc) => DropdownMenuItem(
                value: cc.id,
                child: Text(cc.code),
              )),
    );

    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            header,
            client,
          ],
        ),
      ),
    );
  }
}
