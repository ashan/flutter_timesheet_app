import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import './time_entry_info.dart';
import './timesheet_period_info.dart';

class DateInfo {
  TimeSheetPeriodInfo timeSheetPeriod;
  DateTime date;
  Map<String, TimeEntryInfo> timeEntryDetails = {};
  DateInfo(this.date, this.timeSheetPeriod);

  TimeEntryInfo createOrGetTimeEntryInfo(String timeEntryInfoId) {
    return timeEntryDetails.putIfAbsent(timeEntryInfoId,
        () => TimeEntryInfo(id: timeEntryInfoId)..dateInfo = this);
  }

  TimeEntryInfo createOrGetTimeEntryInfoFrom(
      {@required String newId, @required TimeEntryInfo copyFrom}) {
    if (timeEntryDetails.containsKey(copyFrom.id)) {
      timeEntryDetails[copyFrom.id] = copyFrom;
    } else {
      timeEntryDetails.putIfAbsent(
          newId, () => TimeEntryInfo.from(newId, copyFrom)..dateInfo = this);
    }
  }

  bool get isEditable => timeSheetPeriod.isEditable;

  void removeTimeEntryWithId(String timeEntryId) {
    this.timeEntryDetails.remove(timeEntryId);
    this
        .timeSheetPeriod
        .allTimeEntryInfo
        .removeWhere((te) => te.id == timeEntryId);
  }

  @override
  String toString() => DateFormat('d EEEE MMMM yyyy').format(date);
}
