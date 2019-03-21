import '../models/timesheet_period_info.dart';

import '../models/time_entry_info.dart';

class TimeSheetProvider {
  static final _timeSheetProvider = TimeSheetProvider._internal();
  TimeSheetProvider._internal();
  factory TimeSheetProvider() => _timeSheetProvider;

  Future<TimeSheetPeriod> loadTimeSheetFor(DateTime periodStartDate) async {
    // is loggeed in?
    if (await isLoggedIn()) {
      // TODO load from server
      final retVal = createFakePeriod(periodStartDate);
      return Future.delayed(Duration(seconds: 5), () => retVal);
    }

    return createFakePeriod(periodStartDate);
  }

  Future<bool> isLoggedIn() async {
    return Future.delayed(Duration(microseconds: 500), () => true);
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
      dateInfo.ammendTimeEntryInfo(
        TimeEntryInfo()
          ..id = 'abc'
          ..clientCodes = <Info>[
            Info('0', 'ACC'),
            Info('1', 'iCare'),
            Info('3', 'MOJ'),
            Info('4', 'Internal')
          ]
          ..selectedClientCodeId = '4'
          ..projectCodes = <Info>[
            Info('0', 'Administration'),
            Info('1', 'Business Development'),
            Info('3', 'Leave'),
          ]
          ..selectedProjectCodeId = '3'
          ..taskCodes = <Info>[
            Info('0', 'Adminstration|Non-Billable Time'),
            Info('1', 'Adminstration|Staff Update Sessions')
          ]
          ..selectedTaskCodeId = '0',
      );
      dateInfo.ammendTimeEntryInfo(
        TimeEntryInfo()
          ..id = 'def'
          ..clientCodes = <Info>[
            Info('0', 'ACC'),
            Info('1', 'iCare'),
            Info('3', 'MOJ'),
            Info('4', 'Internal')
          ]
          ..selectedClientCodeId = '0'
          ..projectCodes = <Info>[
            Info('0', 'Administration'),
            Info('1', 'Business Development'),
            Info('3', 'Leave'),
          ]
          ..selectedProjectCodeId = '1'
          ..taskCodes = <Info>[
            Info('0', 'Adminstration|Non-Billable Time'),
            Info('1', 'Adminstration|Staff Update Sessions')
          ]
          ..selectedTaskCodeId = '1',
      );
      dateInfo.ammendTimeEntryInfo(
        TimeEntryInfo()
          ..id = 'ghi'
          ..clientCodes = <Info>[
            Info('0', 'ACC'),
            Info('1', 'iCare'),
            Info('3', 'MOJ'),
            Info('4', 'Internal')
          ]
          ..selectedClientCodeId = '1'
          ..projectCodes = <Info>[
            Info('0', 'Administration'),
            Info('1', 'Business Development'),
            Info('3', 'Leave'),
          ]
          ..selectedProjectCodeId = '1'
          ..taskCodes = <Info>[
            Info('0', 'Adminstration|Non-Billable Time'),
            Info('1', 'Adminstration|Staff Update Sessions')
          ]
          ..selectedTaskCodeId = '1',
      );
      dateInfo.ammendTimeEntryInfo(
        TimeEntryInfo()
          ..id = 'jkl'
          ..clientCodes = <Info>[
            Info('0', 'ACC'),
            Info('1', 'iCare'),
            Info('3', 'MOJ'),
            Info('4', 'Internal')
          ]
          ..selectedClientCodeId = '3'
          ..projectCodes = <Info>[
            Info('0', 'Administration'),
            Info('1', 'Business Development'),
            Info('3', 'Leave'),
          ]
          ..selectedProjectCodeId = '1'
          ..taskCodes = <Info>[
            Info('0', 'Adminstration|Non-Billable Time'),
            Info('1', 'Adminstration|Staff Update Sessions')
          ]
          ..selectedTaskCodeId = '1',
      );

      dateInfo.ammendTimeEntryInfo(
        TimeEntryInfo()
          ..id = 'mno'
          ..clientCodes = <Info>[
            Info('0', 'ACC'),
            Info('1', 'iCare'),
            Info('3', 'MOJ'),
            Info('4', 'Fairway Resolution Limited')
          ]
          ..selectedClientCodeId = '4'
          ..projectCodes = <Info>[
            Info('0', 'Administration'),
            Info('1', 'Business Development'),
            Info('3', 'Leave'),
          ]
          ..selectedProjectCodeId = '1'
          ..taskCodes = <Info>[
            Info('0', 'Adminstration|Non-Billable Time'),
            Info('1', 'Adminstration|Staff Update Sessions')
          ]
          ..selectedTaskCodeId = '1',
      );
      dateInfo.ammendTimeEntryInfo(
        TimeEntryInfo()
          ..id = 'pqr'
          ..clientCodes = <Info>[
            Info('0', 'ACC'),
            Info('1', 'iCare'),
            Info('3', 'MOJ'),
            Info('4', 'Internal')
          ]
          ..selectedClientCodeId = '0'
          ..projectCodes = <Info>[
            Info('0', 'Administration'),
            Info('1', 'Business Development'),
            Info('3', 'Leave'),
          ]
          ..selectedProjectCodeId = '1'
          ..taskCodes = <Info>[
            Info('0', 'Adminstration|Non-Billable Time'),
            Info('1', 'Adminstration|Staff Update Sessions')
          ]
          ..selectedTaskCodeId = '1',
      );
            dateInfo.ammendTimeEntryInfo(
        TimeEntryInfo()
          ..id = 'stu'
          ..clientCodes = <Info>[
            Info('0', 'ACC'),
            Info('1', 'iCare'),
            Info('3', 'MOJ'),
            Info('4', 'Internal')
          ]
          ..selectedClientCodeId = '1'
          ..projectCodes = <Info>[
            Info('0', 'Administration'),
            Info('1', 'Business Development'),
            Info('3', 'Leave'),
          ]
          ..selectedProjectCodeId = '1'
          ..taskCodes = <Info>[
            Info('0', 'Adminstration|Non-Billable Time'),
            Info('1', 'Adminstration|Staff Update Sessions')
          ]
          ..selectedTaskCodeId = '1',
      );
    }
    return retVal;
  }
}
