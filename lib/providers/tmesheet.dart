import '../models/timesheet_period_info.dart';

import '../models/time_entry_info.dart';

class TimeSheetProvider {
  Map<DateTime, TimeSheetPeriod> _periodCache = {};

  static final _timeSheetProvider = TimeSheetProvider._internal();
  TimeSheetProvider._internal();
  factory TimeSheetProvider() => _timeSheetProvider;

  Future<TimeSheetPeriod> loadTimeSheetFor(DateTime periodStartDate) async {
    // is loggeed in?
    if (await isLoggedIn()) {
      // is info already in cache
      if (_periodCache.containsKey(periodStartDate)) {
        return _periodCache[periodStartDate];
      }
      // TODO load from server
      final retVal = createFakePeriod(periodStartDate);
      return Future.delayed(Duration(seconds: 5), () => retVal);
    }

    return createFakePeriod(periodStartDate);
  }

  Future<bool> isLoggedIn() async {
    return Future.delayed(Duration(microseconds: 500), () => false);
  }

  Future<bool> logIn(String email, String password) {
    return Future.delayed(Duration(seconds: 5), () => true);
  }

  TimeSheetPeriod createFakePeriod(DateTime periodStartDate) {
    final allDays = TimeSheetPeriod.allDatesOfPeriodFor(periodStartDate);
    final retVal = TimeSheetPeriod()
      ..periodStart = periodStartDate
      ..periodEnd = allDays.last;

    for (DateTime d in allDays) {
      final dateInfo = retVal.ammendDateInfo(d);
      dateInfo.ammendTimeEntryInfo(TimeEntryInfo()..id = 'abc');
    }
    return retVal;
  }
}
