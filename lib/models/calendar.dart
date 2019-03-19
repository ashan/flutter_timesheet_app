import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

import '../providers/tmesheet.dart';
import './timesheet_period_info.dart';
import './date_info.dart';

class CalendarModel extends Model {
  bool _isCalendarBusy = false;
  Map<DateTime, TimeSheetPeriod> _timeSheetPeriodCache = {};
  TimeSheetPeriod _currentTimeSheetPeriod;

  ///
  /// getters
  ///
  bool get isCalendarBusy => _isCalendarBusy;
  TimeSheetPeriod get currentTimeSheetPeriod => _currentTimeSheetPeriod;

  String get selectedDateStr {
    var orderedSelectedDates = _currentTimeSheetPeriod.selectedDates.keys
        .toList()
          ..sort((DateTime d1, DateTime d2) => d1.compareTo(d2));
    final firstDate = orderedSelectedDates.first;
    final lastDate = orderedSelectedDates.last;
    String retVal = '';
    if (firstDate != null) retVal = DateFormat('EE').format(firstDate);

    if (lastDate != null) retVal += ' - ' + DateFormat('EE').format(lastDate);

    return retVal;
  }

  String get headingDisplayStr => _currentTimeSheetPeriod == null
      ? ''
      : DateFormat.yMMMM().format(_currentTimeSheetPeriod.periodStart);

  String get subHeadingDisplayStr => _currentTimeSheetPeriod == null
      ? ''
      : DateFormat.MMMd().format(_currentTimeSheetPeriod.periodStart) +
          ' - ' +
          DateFormat.MMMd().format(_currentTimeSheetPeriod.periodEnd) ;

  ///
  /// constructor
  ///
  CalendarModel.init({DateTime initDate}) {
    if (initDate == null) initDate = DateTime.now();
    jumpToDate(initDate);
  }

  /// ------------- public methods --------------------------------//
  void jumpToDate(DateTime date) {
    final periodStartDate = TimeSheetPeriod.periodStartDateFor(date);
    selectPeriodStartingWith(periodStartDate);
  }

  ///----------------- event listeners -----------------------------//
  void onDateTap(DateTime selectedDate) {
    _currentTimeSheetPeriod.selectDay(selectedDate);
    notifyListeners();
  }

  void onSelectAllTap(bool allSelected) {
    if (allSelected)
      _currentTimeSheetPeriod.selectAllDays();
    else
      _currentTimeSheetPeriod.clearSelectedDays();
    notifyListeners();
  }

  void onTapNextPeriod() {
    final nextPeriodStartDate =
        _currentTimeSheetPeriod.periodEnd.add(Duration(days: 1));
    selectPeriodStartingWith(nextPeriodStartDate);
  }

  void onTapPreviousPeriod() {
    final previouPeriodEndDay =
        _currentTimeSheetPeriod.periodStart.subtract(Duration(days: 1));
    jumpToDate(previouPeriodEndDay);
  }

  /// ------------- private methods --------------------------------//

  void selectPeriodStartingWith(DateTime periodStartDate) {
    _isCalendarBusy = true;
    final foundTimeSheetPeriod = _timeSheetPeriodCache[periodStartDate];
    // timesheet not found in cache need to load from server
    if (foundTimeSheetPeriod == null) {
      _setPeriodFromDate(periodStartDate).then(
        (TimeSheetPeriod tp) {
          _currentTimeSheetPeriod = tp;
          _isCalendarBusy = false;
          notifyListeners();
        },
      );
    } else {
      _currentTimeSheetPeriod = foundTimeSheetPeriod;
      _isCalendarBusy = false;
    }
    notifyListeners();
  }

  Future<TimeSheetPeriod> _setPeriodFromDate(DateTime date) async {
    final periodStartDate = TimeSheetPeriod.periodStartDateFor(date);
    var retval = await TimeSheetProvider().loadTimeSheetFor(periodStartDate);
    return retval;
  }
}
