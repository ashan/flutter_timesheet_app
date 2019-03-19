class TimeEntryInfo {
  String id;

  List<Info> clientCodes;
  String selectedClientCodeId;
  Info get selectedClientCodeInfo =>
      clientCodes.firstWhere((Info c) => c.id == selectedClientCodeId);
  set selectedClient(Info selectedClient) => selectedClientCodeId =selectedClient.id;

  List<Info> projectCodes;
  String selectedProjectCodeId;
  Info get selectedProjectCodeInfo =>
      projectCodes.firstWhere((Info p) => p.id == selectedProjectCodeId);
  

  List<Info> taskCodes;
  String selectedTaskCodeId;
  Info get selectedTaskCodeInfo =>
      taskCodes.firstWhere((Info t) => t.code == selectedProjectCodeId);
}

class Info {
  String id;
  String code;
  Info(this.id, this.code);
  @override
  String toString() => code;
}
