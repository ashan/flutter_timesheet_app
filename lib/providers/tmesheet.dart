import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:html/dom.dart';
import '../services/time_sheet_service.dart';
import '../models/timesheet_period_info.dart';
import '../models/time_entry_info.dart';

class TimeSheetProvider {
  final _service = TimeSheetService();

  ///
  /// factory constructor
  ///
  static final _timeSheetProvider = TimeSheetProvider._internal();
  TimeSheetProvider._internal();
  factory TimeSheetProvider() => _timeSheetProvider;

  ///
  /// ---- public methods
  ///

  ///
  /// Returns timesheet details for the period starting witht the given date
  ///
  Future<TimeSheetPeriodInfo> loadTimeSheetFor(DateTime periodStartDate) async {
    if (await _service.isLoggedIn) {
      return await _getTimeSheetPeriodFor(periodStartDate);
    }

    return createFakePeriod(periodStartDate);
  }

  ///
  /// Log in to the Timesheet service
  ///
  Future<bool> logIn(String email, String password) async {
    return await _service.login(email, password);
  }

  ///
  /// Log out of the Timesheet service
  ///
  Future<bool> logOut() async {
    return await _service.logout();
  }

  ///
  /// --------------------------- private methods ------------------------
  ///
  Future<TimeSheetPeriodInfo> _getTimeSheetPeriodFor(
      DateTime periodStartDate) async {
    final doc = await _service.getAccountEmployeeTimeEntryPeriodView(
        periodStartDate: periodStartDate);

    // date range of current period
    final periodStartEnd = _periodStartEnd(doc);
    if (periodStartEnd[0].compareTo(periodStartDate) != 0) {
      // we have an issue here. throw exception maybe?
      final test = "";
    }

    var timeSheetPeriodInfo = TimeSheetPeriodInfo(
        periodStart: periodStartEnd[0], periodEnd: periodStartEnd[1])
      ..status = _periodStatus(doc);

    timeSheetPeriodInfo = await _timeEntryInfo(doc, timeSheetPeriodInfo);

    // load all possible projects
    for (Client client
        in timeSheetPeriodInfo.possibleClientProjectTaskCombinations) {
      final clientProjects = await _getAccountProjectsByClient(client.id, null);
      if (clientProjects.length == 0) continue;

      client.projects.addAll(clientProjects
          .map((cp) => Project(id: cp.id, code: cp.code))
          .toList());

      for (Project project in client.projects) {
        final projectTasks = await _getAccountProjectTasksInTimeSheet(
            client.id, project.id, null);
        project.tasks.addAll(
            projectTasks.map((t) => Info(id: t.id, code: t.code)).toList());
      }
    }

    return timeSheetPeriodInfo;
  }

  List<DateTime> _periodStartEnd(Document doc) {
    final dates = doc
        .querySelector('span#ctl00_ctl00_ctl00_C_C_H1_C_W_lblCurrenctdate')
        .text
        .split('-');
    return [
      DateFormat("dd/MM/yyyy").parse(dates[0].trim()),
      DateFormat("dd/MM/yyyy").parse(dates[1].trim())
    ];
  }

  String _periodStatus(Document doc) {
    final statusStr = doc
        .querySelector('span#ctl00_ctl00_ctl00_C_C_H1_C_W_lblTimesheetStatus')
        .text
        .toLowerCase();
    if (statusStr == TimeSheetPeriodInfo.SUBMITTED)
      return TimeSheetPeriodInfo.SUBMITTED;
    return TimeSheetPeriodInfo.OPEN;
  }

  Future<TimeSheetPeriodInfo> _timeEntryInfo(
      Document doc, TimeSheetPeriodInfo timeSheetPeriod) async {
    for (String rowId in [
      'ctl00_ctl00_ctl00_C_C_H1_C_W_G_ctl02',
      'ctl00_ctl00_ctl00_C_C_H1_C_W_G_ctl03',
      'ctl00_ctl00_ctl00_C_C_H1_C_W_G_ctl04',
      'ctl00_ctl00_ctl00_C_C_H1_C_W_G_ctl05',
      'ctl00_ctl00_ctl00_C_C_H1_C_W_G_ctl06',
      'ctl00_ctl00_ctl00_C_C_H1_C_W_G_ctl07',
      'ctl00_ctl00_ctl00_C_C_H1_C_W_G_ctl08'
    ]) {
      final allClients = _processHtmlSelect(doc, '${rowId}_C');
      if (timeSheetPeriod.possibleClientProjectTaskCombinations.length == 0) {
        timeSheetPeriod.possibleClientProjectTaskCombinations.addAll(
            allClients.map((c) => Client(id: c.id, code: c.code)).toList());
      }
      final selectedClient =
          allClients.firstWhere((c) => c.isSelected, orElse: () => null);

      if (selectedClient != null) {
        final selectedClientID = selectedClient.id;

        // projects
        final selectedProjectID =
            _getHiddenInputValue(doc, '${rowId}_CP_ClientState');

        if (selectedProjectID.isNotEmpty) {
          final projects = await _getAccountProjectsByClient(
              selectedClientID, selectedProjectID);

          // tasks
          String selectedTaskID =
              _getHiddenInputValue(doc, '${rowId}_CT_ClientState');
          if (selectedTaskID.isNotEmpty) {
            final tasks = await _getAccountProjectTasksInTimeSheet(
                selectedClientID, selectedProjectID, selectedTaskID);

            // time details
            var currentDate = timeSheetPeriod.periodStart;
            int i = 0;
            while (currentDate.compareTo(timeSheetPeriod.periodEnd) <= 0) {
              // create the date entry
              final currentDateInfo =
                  timeSheetPeriod.createOrGetDateInfo(currentDate);

              final timeInputId = 'input#${rowId}_TT$i';
              final timeElement = doc.querySelector(timeInputId);
              var strTimeVal =
                  timeElement != null ? timeElement.attributes['value'] : null;
              if (strTimeVal != null) {
                if (strTimeVal.trim().isNotEmpty) {
                  strTimeVal = strTimeVal.replaceAll(':', '.');
                  double dblTimeVal = double.parse(strTimeVal);
                  // ready to populate a timeEntry models

                  var timeEntry = TimeEntryInfo(id: timeInputId)
                    ..clientCodes = allClients
                        .map((c) => Info(id: c.id, code: c.code))
                        .toList()
                    ..selectedClientCodeId = selectedClientID
                    ..projectCodes = projects
                        .map((p) => Info(id: p.id, code: p.code))
                        .toList()
                    ..selectedProjectCodeId = selectedProjectID
                    ..taskCodes =
                        tasks.map((t) => Info(id: t.id, code: t.code)).toList()
                    ..selectedTaskCodeId = selectedTaskID
                    ..hours = dblTimeVal;

                  currentDateInfo.ammendTimeEntryInfo(timeEntry);
                }
              }
              // increase the date
              currentDate = currentDate.add(Duration(days: 1));
              i++;
            }
          }
        }
      }
    }
    return timeSheetPeriod;
  }

  List<_SelectEntryInfo> _processHtmlSelect(Document doc, String htmlSelectId) {
    final returnList = <_SelectEntryInfo>[];
    final select = doc.querySelector('select#$htmlSelectId');
    if (select == null) return returnList;
    for (Node optionNode in select.nodes) {
      final code = optionNode.text.trim();
      if (code.isEmpty) continue;
      final id = optionNode.attributes['value'];
      if (id == null || id.isEmpty) continue;
      final isSelected = optionNode.attributes['selected'] != null;
      returnList.add(_SelectEntryInfo(id, code, isSelected));
    }
    return returnList;
  }

  String _getHiddenInputValue(Document doc, String hiddenInputID) {
    var hiddenInputElement = doc.querySelector('input#$hiddenInputID');
    if (hiddenInputElement == null) return '';
    final hiddenInputValue = hiddenInputElement.attributes['value'];
    return hiddenInputValue?.trim() ?? '';
  }

  Future<List<_SelectEntryInfo>> _getAccountProjectsByClient(
      String clientId, String projectId) async {
    final projects = <_SelectEntryInfo>[];
    String projectsJsonString =
        await _service.getAccountProjectsByClient(clientId);
    List<dynamic> projectsJson = json.decode(projectsJsonString);
    for (Map<String, dynamic> entry in projectsJson) {
      var id = entry['name'];
      var code = entry['value'];
      var isSelected = id == projectId;
      projects.add(_SelectEntryInfo(code, id, isSelected));
    }
    return projects;
  }

  Future<List<_SelectEntryInfo>> _getAccountProjectTasksInTimeSheet(
      String clientId, String projectId, String taskId) async {
    var tasks = <_SelectEntryInfo>[];
    String tasksJsonString =
        await _service.getAccountProjectTasksInTimeSheet(clientId, projectId);
    List<dynamic> tasksJson = json.decode(tasksJsonString);
    for (Map<String, dynamic> entry in tasksJson) {
      var id = entry['name'];
      var code = entry['value'];
      var isSelected = id == taskId;
      tasks.add(_SelectEntryInfo(code, id, isSelected));
    }
    return tasks;
  }

  TimeSheetPeriodInfo createFakePeriod(DateTime periodStartDate) {
    final allDays = TimeSheetPeriodInfo.allDatesOfPeriodFor(periodStartDate);
    final retVal = TimeSheetPeriodInfo(
        periodStart: periodStartDate, periodEnd: allDays.last);

    for (DateTime d in allDays) {
      final dateInfo = retVal.createOrGetDateInfo(d);
      dateInfo.ammendTimeEntryInfo(
        TimeEntryInfo(id: 'abc')
          ..clientCodes = <Info>[
            Info(id: '0', code: 'ACC'),
            Info(id: '1', code: 'iCare'),
            Info(id: '3', code: 'MOJ'),
            Info(id: '4', code: 'Internal')
          ]
          ..selectedClientCodeId = '4'
          ..projectCodes = <Info>[
            Info(id: '0', code: 'Administration'),
            Info(id: '1', code: 'Business Development'),
            Info(id: '3', code: 'Leave'),
          ]
          ..selectedProjectCodeId = '3'
          ..taskCodes = <Info>[
            Info(id: '0', code: 'Adminstration|Non-Billable Time'),
            Info(id: '1', code: 'Adminstration|Staff Update Sessions')
          ]
          ..selectedTaskCodeId = '0',
      );
    }
    return retVal;
  }
}

class _SelectEntryInfo {
  String id;
  String code;
  bool isSelected;
  _SelectEntryInfo(this.id, this.code, this.isSelected);
}
