import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

import '../providers/tmesheet.dart';
import './timesheet_period_info.dart';

class CalendarModel extends Model {
  bool _isBusy = false;
  bool _isPreviousPeriodLoading = false;
  bool _isNextPeriodLoading = false;
  bool _needsLoginIn = false;

  Map<DateTime, TimeSheetPeriodInfo> _timeSheetPeriodCache = {};
  TimeSheetPeriodInfo _currentTimeSheetPeriod;

  ///
  /// getters
  ///
  bool get isBusy => _isBusy;
  bool get isPreviousPeriodLoading =>
      _isPreviousPeriodLoading &&
      !_timeSheetPeriodCache.containsKey(_previousPeriodStartDate);
  bool get isNextPeriodLoading =>
      _isNextPeriodLoading &&
      !_timeSheetPeriodCache.containsKey(_nextPeriodStartDate);
  bool get needsLoginIn => _needsLoginIn;

  TimeSheetPeriodInfo get currentTimeSheetPeriod => _currentTimeSheetPeriod;

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
          DateFormat.MMMd().format(_currentTimeSheetPeriod.periodEnd);

  CalendarModel({DateTime initDate}) {
    initDate = initDate ?? DateTime.now();
    // fake period until loading completed from server
    final periodStartDate = TimeSheetPeriodInfo.periodStartDateFor(initDate);
    _currentTimeSheetPeriod =
        TimeSheetProvider().createFakePeriod(periodStartDate);
  }

  init({DateTime initDate}) async {
    initDate = initDate ?? DateTime.now();
    final periodStartDate = TimeSheetPeriodInfo.periodStartDateFor(initDate);

    await _jumpToPeriodStartingWith(periodStartDate);
  }

  /// ------------- public methods --------------------------------//
  test() {
    var test = "";
  }

  ///----------------- event listeners -----------------------------//
  void onExitCalendarScreen() {
    // clear cache for now
    _timeSheetPeriodCache = {};
  }

  void onDateTap(DateTime selectedDate) {
    if (_currentTimeSheetPeriod.isSelectedDate(selectedDate)) {
      _currentTimeSheetPeriod.unSelectDay(selectedDate);
    } else {
      _currentTimeSheetPeriod.selectDay(selectedDate);
    }
    notifyListeners();
  }

  // void onSelectAllTap(bool allSelected) {
  //   if (allSelected)
  //     _currentTimeSheetPeriod.selectAllDays();
  //   else
  //     _currentTimeSheetPeriod.clearSelectedDays();
  //   notifyListeners();
  // }

  void onTapNextPeriod() => _jumpToPeriodStartingWith(_nextPeriodStartDate);

  void onTapPreviousPeriod() =>
      _jumpToPeriodStartingWith(_previousPeriodStartDate);

  void onTodayTap() => _jumpToPeriodStartingWith(
      TimeSheetPeriodInfo.periodStartDateFor(DateTime.now()));

  /// ------------- private methods --------------------------------//
  ///
  DateTime get _nextPeriodStartDate {
    final nextPeriodStartDate =
        _currentTimeSheetPeriod.periodEnd.add(Duration(days: 1));
    return TimeSheetPeriodInfo.periodStartDateFor(nextPeriodStartDate);
  }

  DateTime get _previousPeriodStartDate {
    final previousPeriodEndDate =
        _currentTimeSheetPeriod.periodStart.subtract(Duration(days: 1));
    return TimeSheetPeriodInfo.periodStartDateFor(previousPeriodEndDate);
  }

  Future<bool> _jumpToPeriodStartingWith(DateTime periodStartDate) async {
    // clear out any selected dates from the current time period
    _currentTimeSheetPeriod.clearSelectedDays();
    try {
      _isBusy = true;
      final previousPeriodStart = TimeSheetPeriodInfo.periodStartDateFor(
          periodStartDate.subtract(Duration(days: 1)));

      _isPreviousPeriodLoading =
          !_timeSheetPeriodCache.containsKey(previousPeriodStart);

      final nextPeriodStart = TimeSheetPeriodInfo.periodStartDateFor(
          TimeSheetPeriodInfo.periodEndDateFor(periodStartDate)
              .add(Duration(days: 1)));

      _isNextPeriodLoading =
          !_timeSheetPeriodCache.containsKey(nextPeriodStart);
      notifyListeners();

      if (_isPreviousPeriodLoading) {
        TimeSheetProvider().loadTimeSheetFor(previousPeriodStart).then(
          (TimeSheetPeriodInfo tp) {
            _timeSheetPeriodCache.putIfAbsent(previousPeriodStart, () => tp);
            _isPreviousPeriodLoading = false;
            notifyListeners();
          },
        );
      }
      if (_isNextPeriodLoading) {
        TimeSheetProvider()
            .loadTimeSheetFor(nextPeriodStart)
            .then((TimeSheetPeriodInfo tp) {
          _timeSheetPeriodCache.putIfAbsent(nextPeriodStart, () => tp);
          _isNextPeriodLoading = false;
          notifyListeners();
        });
      }

      if (_timeSheetPeriodCache.containsKey(periodStartDate)) {
        _currentTimeSheetPeriod = _timeSheetPeriodCache[periodStartDate];
      } else {
        _currentTimeSheetPeriod =
            await TimeSheetProvider().loadTimeSheetFor(periodStartDate);
        _timeSheetPeriodCache.putIfAbsent(
            periodStartDate, () => _currentTimeSheetPeriod);
      }
      _isBusy = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isBusy = false;
      _isNextPeriodLoading = false;
      _isPreviousPeriodLoading = false;
      _needsLoginIn = true;
      notifyListeners();
    }
  }
}
