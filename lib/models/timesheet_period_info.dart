import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import './date_info.dart';
import 'package:date_utils/date_utils.dart';
import './time_entry_info.dart';

class TimeSheetPeriodException implements Exception {
  String cause;
  TimeSheetPeriodException(this.cause);
}

class TimeSheetPeriodInfo {
  static const OPEN = "Not Submitted";
  static const SUBMITTED = "received";
  String status = TimeSheetPeriodInfo.OPEN;

  DateTime periodStart;
  DateTime periodEnd;
  Map<DateTime, DateInfo> _periodDays = {};
  Map<DateTime, DateInfo> _selectedDays = {};
  List<TimeEntryInfo> _allTimeEntryInfo = [];

  List<Client> possibleClientProjectTaskCombinations = [];

  ///
  ///getters
  ///
  Map<DateTime, DateInfo> get allDaysInPeriod => _periodDays;
  Map<DateTime, DateInfo> get selectedDates => _selectedDays;
  List<TimeEntryInfo> get allTimeEntryInfo => _allTimeEntryInfo;
  bool get isEditable => status == TimeSheetPeriodInfo.OPEN;

  ///
  /// Constructors
  ///
  TimeSheetPeriodInfo({@required this.periodStart, this.periodEnd}) {
    _initPeriodDays();
  }

  ///
  /// ------------- public
  ///
  double get totalHours {
    double total = 0.0;
    _allTimeEntryInfo.forEach((te) => total += te.hours);
    return total;
  }

  ///
  /// returns the existing date info object from period days if a date info object exists
  /// else creates a new date info object, inserts it in to the period days and returns it
  ///
  DateInfo createOrGetDateInfo(DateTime date) {
    if (isDateWithinPeriod(date))
      return _periodDays.putIfAbsent(date, () => DateInfo(date, this));
    throw TimeSheetPeriodException('$date is not within period');
  }

  void unSelectDay(DateTime date) {
    _allTimeEntryInfo
        .removeWhere((te) => te.dateInfo.date.compareTo(date) == 0);
    _selectedDays.remove(date);
  }

  DateInfo selectDay(DateTime date) {
    final dateInfo = _periodDays[date];
    if (dateInfo != null) {
      _allTimeEntryInfo.addAll(dateInfo.timeEntryDetails.values);
      return _selectedDays.putIfAbsent(date, () => dateInfo);
    }
    throw TimeSheetPeriodException('$date is not in _periodDays');
  }

  void clearSelectedDays() {
    _selectedDays = {};
    _allTimeEntryInfo = [];
  }

  void selectAllWorkingDays() {
    for (DateTime day in _periodDays.keys.toList()) {
      // TODO add holiday logic
      if (![DateTime.saturday, DateTime.sunday].contains(day.weekday)) {
        selectDay(day);
      }
    }
  }

  bool isSelectedDate(DateTime date) => _selectedDays.containsKey(date);

  bool isDateWithinPeriod(DateTime date) {
    var list = Utils.daysInRange(periodStart, periodEnd.add(Duration(days: 1)))
        .toList();
    var retVal = list.firstWhere((DateTime d) => Utils.isSameDay(d, date),
            orElse: () => null) !=
        null;
    return retVal;
  }

  @override
  String toString() {
    final start = DateFormat('MMMM yyyy').format(periodStart);
    return '$start, ${periodStart.day} - ${periodEnd.day}';
  }

  ///
  /// Returns all days in the time sheet period for a given date
  ///
  static List<DateTime> allDatesOfPeriodFor(DateTime date) {
    return Utils.daysInRange(periodStartDateFor(date),
            periodEndDateFor(date).add(Duration(days: 1)))
        .toList();
  }

  ///
  /// Returns the timesheet period start date for a given date
  ///
  static DateTime periodStartDateFor(DateTime date) {
    return date.day <= 15
        ? Utils.firstDayOfMonth(date)
        : DateTime(date.year, date.month, 16);
  }

  ///
  /// Returns the timesheet period end date for a given date
  ///
  static DateTime periodEndDateFor(DateTime date) {
    return date.day <= 15
        ? DateTime(date.year, date.month, 15)
        : Utils.lastDayOfMonth(date);
  }

  _initPeriodDays() {
    DateTime d = periodStart;
    while (d.compareTo(periodEnd) <= 0) {
      createOrGetDateInfo(d);
      d = d.add(Duration(days: 1));
    }
  }
}

class Client extends Info {
  Client({@required String id, @required String code})
      : super(id: id, code: code);

  List<Project> projects = [];
}

class Project extends Info {
  List<Info> tasks = [];
  Project({@required String id, @required String code})
      : super(id: id, code: code);
}
