import 'package:flutter/foundation.dart';
import './date_info.dart';

class TimeEntryInfo {
  DateInfo dateInfo;
  String id;

  List<Info> clientCodes = [];
  String selectedClientCodeId;
  Info get selectedClient =>
      clientCodes.firstWhere((Info c) => c.id == selectedClientCodeId);
  set selectedClientWithID(String id) => selectedClientCodeId = id;
  set selectedClient(Info selectedClient) =>
      selectedClientCodeId = selectedClient.id;

  List<Info> projectCodes = [];
  String selectedProjectCodeId;
  Info get selectedProject =>
      projectCodes.firstWhere((Info p) => p.id == selectedProjectCodeId);

  List<Info> taskCodes = [];
  String selectedTaskCodeId;
  Info get selectedTaskCode =>
      taskCodes.firstWhere((Info t) => t.id == selectedTaskCodeId);

  double hours = 0.0;

  String notes;

  TimeEntryInfo({@required this.id});

  bool get isEditable => dateInfo.isEditable;
}

class Info {
  String id;
  String code;
  Info({@required this.id, @required this.code});
  @override
  String toString() => code;
}
