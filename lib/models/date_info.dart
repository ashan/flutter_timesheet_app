import 'package:intl/intl.dart';
import './time_entry_info.dart';

class DateInfo {
  DateTime date;
  Map<String, TimeEntryInfo> timeEntryDetails = {};
  DateInfo(this.date);

  TimeEntryInfo ammendTimeEntryInfo(TimeEntryInfo timeEntry) {
    return timeEntryDetails[timeEntry.id] = timeEntry;
  }

  @override
  String toString() => DateFormat.MMMd().format(date);
}
