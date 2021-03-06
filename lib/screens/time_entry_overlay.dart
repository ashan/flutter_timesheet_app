import 'package:flutter/material.dart';

import '../models/calendar.dart';
import '../models/time_entry_info.dart';
import '../screens/widgets/calendar/time_entry_details_widget.dart';

class TimeEntryOverlay extends ModalRoute<void> {
  static const String ROUTE = "EnterTimeDetails";
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

  CalendarModel _calendar;
  TimeEntryInfo timeEntryInfo;
  TimeEntryOverlay(this._calendar, {this.timeEntryInfo});

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: TimeEntryDetailsWidget(_calendar, timeEntryInfo),
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
