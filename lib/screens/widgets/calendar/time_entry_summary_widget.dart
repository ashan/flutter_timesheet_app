import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/calendar.dart';
import '../../../models/time_entry_info.dart';
import '../../../screens/time_entry_overlay.dart';

class TimeEntryDetailsSummaryWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TimeEntryDetailsSummaryWidgetState();
  }
}

class _TimeEntryDetailsSummaryWidgetState
    extends State<TimeEntryDetailsSummaryWidget> {
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
              return timeEntryDetailFor(calendar, entryInfo);
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

  Widget timeEntryDetailFor(CalendarModel calendar, TimeEntryInfo timeInfo) {
    var clientCode = timeInfo.selectedClient.toString();
    if (clientCode.length > 10) {
      final clientCodeArray = clientCode.split(' ');
      clientCode = '';
      for (int i = 0;
          i < (clientCodeArray.length < 5 ? clientCodeArray.length : 5);
          i++) {
        if (clientCodeArray[i].isNotEmpty)
          clientCode += clientCodeArray[i].substring(0, 1);
      }
    }
    var client = Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).accentColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey[500],
              offset: Offset(0.0, 5.5),
              blurRadius: 5.5,
            ),
          ],
        ),
        child: Center(
          child: Text(
            clientCode,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ));

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
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 2, vertical: 3),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
              TimeEntryOverlay(calendar, timeInfo),
            ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          title: project,
          leading: client,
          subtitle: taskPlusTime,
          trailing: moreInfo,
          enabled: timeInfo.isEditable,
        ),
      ),
    );
  }
}
