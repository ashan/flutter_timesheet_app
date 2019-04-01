import 'package:flutter/foundation.dart';
import './date_info.dart';

class TimeEntryInfo {
  DateInfo dateInfo;
  String id;

  List<Info> clientCodes = [];
  String selectedClientId;
  Info get selectedClient => clientCodes
      .firstWhere((Info c) => c.id == selectedClientId, orElse: () => null);
  set selectedClientWithID(String id) => selectedClientId = id;
  set selectedClient(Info selectedClient) =>
      selectedClientId = selectedClient.id;

  List<Info> projectCodes = [];
  String selectedProjectId;
  Info get selectedProject =>
      projectCodes.firstWhere((Info p) => p.id == selectedProjectId,
          orElse: () => null);
  set selectedProject(Info selectedProject) =>
      selectedProjectId = selectedProject.id;

  List<Info> taskCodes = [];
  String selectedTaskId;
  Info get selectedTask => taskCodes
      .firstWhere((Info t) => t.id == selectedTaskId, orElse: () => null);
  set selectedTask(Info selectedTask) => selectedTaskId = selectedTask.id;

  double hours = 0.0;

  String notes;

  TimeEntryInfo({@required this.id});

  bool get isEditable => dateInfo?.isEditable ?? true;

  static TimeEntryInfo from(String newId, TimeEntryInfo other) =>
      TimeEntryInfo(id: newId)
        ..clientCodes = List<Info>.from(other.clientCodes)
        ..projectCodes = List<Info>.from(other.projectCodes)
        ..taskCodes = List<Info>.from(other.taskCodes)
        ..selectedClient = Info.from(other.selectedClient)
        ..selectedProject = Info.from(other.selectedProject)
        ..selectedTask = Info.from(other.selectedTask)
        ..notes = other.notes
        ..hours = other.hours;
}

class Info {
  String id;
  String code;
  Info({@required this.id, @required this.code});
  @override
  String toString() => code;

  static Info from(Info info) => Info(id: info.id, code: info.code);
}
