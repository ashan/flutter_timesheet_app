import 'package:intl/intl.dart';
import './date_info.dart';
import 'package:date_utils/date_utils.dart';

class TimeSheetPeriodException implements Exception {
  String cause;
  TimeSheetPeriodException(this.cause);
}

class TimeSheetPeriod {
  DateTime periodStart;
  DateTime periodEnd;
  Map<DateTime, DateInfo> _periodDays = {};
  Map<DateTime, DateInfo> _selectedDays = {};

  ///
  ///getters
  ///
  Map<DateTime, DateInfo> get periodDays => _periodDays;
  Map<DateTime, DateInfo> get selectedDates => _selectedDays;

  /// ------------- puboic
  DateInfo ammendDateInfo(DateTime date) {
    if (isDateWithinPeriod(date))
      return _periodDays.putIfAbsent(date, () => DateInfo(date));
    throw TimeSheetPeriodException('$date is not within period');
  }

  DateInfo selectDay(DateTime date, {bool clearSelectedDaysFirst: true}) {
    if (clearSelectedDaysFirst) clearSelectedDays();
    final dateInfo = _periodDays[date];
    if (dateInfo != null) {
      return _selectedDays.putIfAbsent(date, () => dateInfo);
    }
    throw TimeSheetPeriodException('$date is not in _periodDays');
  }

  Map<DateTime, DateInfo> selectAllDays({bool clearSelectedDaysFirst: true}) {
    if (clearSelectedDaysFirst) clearSelectedDays();
    _periodDays.keys
        .forEach((DateTime d) => selectDay(d, clearSelectedDaysFirst: false));
    return _selectedDays;
  }

  void clearSelectedDays() => _selectedDays = {};

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
}
