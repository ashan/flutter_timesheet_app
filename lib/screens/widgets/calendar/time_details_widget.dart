import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/calendar.dart';
import '../../../models/time_entry_info.dart';

class TimeEntryDetails extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TimeEntryDetailsState();
  }
}

class _TimeEntryDetailsState extends State<TimeEntryDetails> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<CalendarModel>(
      builder: (BuildContext context, Widget widget, CalendarModel calendar) {
        return NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return _sliverAppBar(calendar);
          },
          body: ListView.builder(
            shrinkWrap: true,
            itemCount: calendar.currentTimeSheetPeriod.allTimeEntryInfo.length,
            itemBuilder: (BuildContext context, int i) {
              final entryInfo =
                  calendar.currentTimeSheetPeriod.allTimeEntryInfo[i];
              return timeEntryDetailFor(entryInfo);
            },
          ),
        );
      },
    );
  }

  List<Widget> _sliverAppBar(CalendarModel calendar) {
    if (calendar.currentTimeSheetPeriod.allTimeEntryInfo.isEmpty) return [];
    return <Widget>[
      SliverAppBar(
        pinned: true,
        automaticallyImplyLeading: false,
        textTheme: Theme.of(context).textTheme,
        backgroundColor: Theme.of(context).cardColor,
        forceElevated: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Text(
              'Total Time: ${calendar.currentTimeSheetPeriod.totalHours}',
              style: Theme.of(context).textTheme.subtitle,
            ),
          ],
        ),
      ),
    ];
  }

  Widget timeEntryDetailFor(TimeEntryInfo timeInfo) {
    var client = CircleAvatar(
      child: Text(timeInfo.selectedClient.toString()),
      radius: 30,
    );

    var project = Text(
      timeInfo.selectedProject.toString(),
      style: TextStyle(fontWeight: FontWeight.bold),
    );

    var taskPlusTime = Row(
      children: <Widget>[
        Expanded(child: Text(timeInfo.selectedTaskCode.toString())),
        Container(
          padding: EdgeInsets.only(left: 5),
          child: Text(timeInfo.hours.toString()),
          decoration: BoxDecoration(
              border:
                  Border(left: BorderSide(width: 2.0, color: Colors.black))),
        ),
      ],
    );
    var moreInfo = IconButton(
      icon: Icon(Icons.keyboard_arrow_right),
      onPressed: () {},
    );

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: ListTile(
        contentPadding:
            EdgeInsets.only(left: 0.0, top: 10.0, bottom: 10.0, right: 10.0),
        title: project,
        leading: client,
        subtitle: taskPlusTime,
        trailing: moreInfo,
      ),
    );
  }
}
