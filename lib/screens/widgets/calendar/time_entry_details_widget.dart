import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/calendar.dart';
import '../../../models/time_entry_info.dart';

class TimeEntryDetailsWidget extends StatefulWidget {
  final CalendarModel _calendar;
  final TimeEntryInfo _timeEntryInfo;

  TimeEntryDetailsWidget(this._calendar, this._timeEntryInfo);

  @override
  State<StatefulWidget> createState() {
    return _TimeEntryDetailsWidgetState();
  }
}

class _TimeEntryDetailsWidgetState extends State<TimeEntryDetailsWidget> {
  final _formKey = GlobalKey<FormState>();

  var _clientList = <DropdownMenuItem<String>>[];
  String _selectedClientId = '';

  var _projectsList = <DropdownMenuItem<String>>[];
  String _selectedProjectId = '';

  var _tasksList = <DropdownMenuItem<String>>[];
  String _selectedTaskId = '';

  var _enableTime = false;
  var _enableNotes = false;

  var _dates = <DateTime, bool>{};

  bool _isEditable = false;

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupClientsDropDownList();
    _isEditable = widget._timeEntryInfo.isEditable;
    _timeController.text = widget._timeEntryInfo.hours?.toString() ?? '';
    _notesController.text = widget._timeEntryInfo.notes ?? '';

    _setupDatesList();
  }

  @override
  void dispose() {
    super.dispose();
    _timeController.dispose();
  }

  void _setupDatesList() {
    if (_isEditable && widget._timeEntryInfo.dateInfo == null) {
      final currentPeriod = widget._calendar.currentTimeSheetPeriod;
      // new time entry, add all possible dates and mark selected dates
      currentPeriod.allDaysInPeriod.keys.forEach((DateTime d) =>
          _dates.putIfAbsent(d, () => currentPeriod.isSelectedDate(d)));
    } else {
      _dates.putIfAbsent(widget._timeEntryInfo.dateInfo.date, () => true);
    }
  }

  void _setupClientsDropDownList() {
    // if TimeEntry info already contains clients use them (i.e. we are in edit/view mode)
    List<Info> list = widget._timeEntryInfo.clientCodes.isNotEmpty
        ? widget._timeEntryInfo.clientCodes
        : widget._calendar.getAllPossibleClientCodes();
    _clientList = list
        .map(
          (cc) => DropdownMenuItem<String>(
                child: Text(cc.code),
                value: cc.id,
              ),
        )
        .toList();

    _selectedClientId = widget._timeEntryInfo.selectedClient?.id ?? null;
  }

  void _setupProjectsDropDownList() {
    List<Info> list = widget._timeEntryInfo.projectCodes.isNotEmpty
        ? widget._timeEntryInfo.clientCodes
        : widget._calendar.getAllPossibleProjectCodes(_selectedClientId);
    _projectsList = list
        .map(
          (pc) => DropdownMenuItem<String>(
                child: Text(pc.code),
                value: pc.id,
              ),
        )
        .toList();
    _selectedProjectId = widget._timeEntryInfo.selectedProject?.id ?? null;
  }

  void _setupTasksDropDownList() {
    List<Info> list = widget._timeEntryInfo.taskCodes.isNotEmpty
        ? widget._timeEntryInfo.taskCodes
        : widget._calendar
            .getAllPossibleTaskCodes(_selectedClientId, _selectedProjectId);
    _tasksList = list
        .map(
          (tc) => DropdownMenuItem<String>(
                child: Text(tc.code),
                value: tc.id,
              ),
        )
        .toList();
    _selectedTaskId = widget._timeEntryInfo.selectedTask?.id ?? null;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height - 50,
        width: MediaQuery.of(context).size.width - 50,
        child: Card(
          child: Padding(
            padding: EdgeInsets.only(top: 0, bottom: 5, right: 20, left: 20),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      padding: EdgeInsets.all(0),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  _selectedDates,
                  _clients,
                  _projects,
                  _tasks,
                  _time,
                  _notes,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get _selectedDates {
    final children = <Widget>[];
    _dates.forEach(
      (DateTime d, bool isSelected) {
        children.add(
          ChoiceChip(
            onSelected: (bool) {
              setState(() => _dates[d] = !isSelected);
            },
            selected: isSelected,
            avatar: _isEditable && isSelected ? Icon(Icons.done) : null,
            label: Text(
              DateFormat.MMMd().format(d),
            ),
          ),
        );
      },
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(Icons.date_range),
        SizedBox(width: 10),
        Expanded(
          child: Wrap(
            spacing: 8.0,
            runSpacing: 1.0,
            children: children,
          ),
        )
      ],
    );
  }

  Widget get _clients => _dropDown(
        icon: Icons.person,
        readOnlyText:
            _isEditable ? null : widget._timeEntryInfo.selectedClient.code,
        dropDownHintText: 'Client',
        dropDownItemList: _clientList,
        selectedDropDownItem: _selectedClientId,
        dropDownOnChanged: (val) => setState(
              () {
                _selectedClientId = val;
                _setupProjectsDropDownList();
              },
            ),
      );

  Widget get _projects => _dropDown(
        icon: Icons.folder,
        readOnlyText:
            _isEditable ? null : widget._timeEntryInfo.selectedProject.code,
        dropDownHintText: 'Project',
        dropDownItemList: _projectsList,
        selectedDropDownItem: _selectedProjectId,
        dropDownOnChanged: (val) => setState(
              () {
                _selectedProjectId = val;
                _setupTasksDropDownList();
              },
            ),
      );

  Widget get _tasks => _dropDown(
        icon: Icons.work,
        readOnlyText:
            _isEditable ? null : widget._timeEntryInfo.selectedTask.code,
        dropDownHintText: 'Task',
        dropDownItemList: _tasksList,
        selectedDropDownItem: _selectedTaskId,
        dropDownOnChanged: (val) => setState(
              () {
                _selectedTaskId = val;
                _enableTime = true;
                _enableNotes = true;
              },
            ),
      );

  Widget _dropDown(
      {IconData icon,
      String readOnlyText,
      String dropDownHintText,
      List<DropdownMenuItem<String>> dropDownItemList,
      String selectedDropDownItem,
      Function(String val) dropDownOnChanged}) {
    var children = <Widget>[
      Icon(icon),
      SizedBox(width: 10),
    ];

    if (_isEditable) {
      children.add(
        Expanded(
          child: DropdownButton(
            hint: Text(dropDownHintText),
            items: dropDownItemList,
            value: selectedDropDownItem,
            onChanged: dropDownOnChanged,
            isExpanded: true,
          ),
        ),
      );
    } else {
      children.add(
        Expanded(
          child: Text(readOnlyText),
        ),
      );
    }
    return Row(children: children);
  }

  Widget get _time => _textField(
        icon: Icons.timer,
        textInputType: TextInputType.number,
        editingtController: _timeController,
        enableTextField: _enableTime,
        inputLabel: 'Time',
      );

  Widget get _notes => _textField(
        icon: Icons.note,
        textInputType: TextInputType.multiline,
        editingtController: _notesController,
        enableTextField: _enableNotes,
        inputLabel: 'Notes',
      );

  Widget _textField(
      {IconData icon,
      TextEditingController editingtController,
      TextInputType textInputType,
      String inputLabel,
      bool enableTextField}) {
    if (!_isEditable && editingtController.text.isEmpty) return Container();
    final children = <Widget>[
      Icon(icon),
      SizedBox(width: 10),
    ];

    if (_isEditable) {
      children.add(
        Expanded(
          child: TextFormField(
            enabled: enableTextField,
            controller: editingtController,
            keyboardType: textInputType,
            decoration: InputDecoration(labelText: inputLabel),
          ),
        ),
      );
    } else {
      children.add(
        Expanded(
          child: Text(editingtController.text),
        ),
      );
    }
    return Row(children: children);
  }
}
