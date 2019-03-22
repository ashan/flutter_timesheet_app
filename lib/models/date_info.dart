import 'package:intl/intl.dart';
import './time_entry_info.dart';
import './timesheet_period_info.dart';

class DateInfo {
  TimeSheetPeriodInfo timeSheetPeriod;
  DateTime date;
  Map<String, TimeEntryInfo> timeEntryDetails = {};
  DateInfo(this.date, this.timeSheetPeriod);

  TimeEntryInfo ammendTimeEntryInfo(TimeEntryInfo timeEntry) {
    return timeEntryDetails[timeEntry.id] = timeEntry;
  }

  bool get isEditable => timeSheetPeriod.isEditable;
  @override
  String toString() => DateFormat.MMMd().format(date);
}
