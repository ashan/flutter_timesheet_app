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
    var clientCode = timeInfo.selectedClient.toString();
    print(clientCode);
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
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue[400],
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
            style: TextStyle(color: Colors.white),
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
      onPressed: () {
        Navigator.of(context).push(TutorialOverlay(timeInfo));
      },
    );

    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 2, vertical: 3),
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

class TutorialOverlay extends ModalRoute<void> {
  TimeEntryInfo timeEntryInfo;
  @override
  Duration get transitionDuration => Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  TutorialOverlay(this.timeEntryInfo);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.person),
                SizedBox(width: 10.0),
                DropdownButton(
                  hint: Text('Client Code'),
                  items: timeEntryInfo.clientCodes
                      .map(
                        (cc) => DropdownMenuItem(
                              child: Text(cc.code),
                              value: cc.id,
                            ),
                      )
                      .toList(),
                  onChanged: (String id) =>
                      timeEntryInfo.selectedClientWithID = id,
                ),
              ],
            ),
            RaisedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Dismiss'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}
