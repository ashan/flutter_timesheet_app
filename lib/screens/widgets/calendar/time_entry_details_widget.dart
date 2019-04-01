import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../models/calendar.dart';
import '../../../models/time_entry_info.dart';

class TimeEntryDetailsWidget extends StatefulWidget {
  final CalendarModel _calendar;
  final TimeEntryInfo _timeEntryInfo;

  TimeEntryDetailsWidget(this._calendar, this._timeEntryInfo);

  @override
  State<StatefulWidget> createState() => _TimeEntryDetailsWidgetState();
}

class _TimeEntryDetailsWidgetState extends State<TimeEntryDetailsWidget> {
  TimeEntryInfo _timeEntryInfo;
  bool _isNewTimeEntry = false;
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
  var _allDatesSelected = false;

  bool _isEditable = false;

  Color _editableIconColor;

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // show hide error messages
  bool _addButtonPressedOnce = false;
  bool _showDateRequriedErrorMsg = false;
  bool _showClientRequiredErrorMsg = false;
  bool _showProjectRequriedErrorMsg = false;
  bool _showTaskRequiredErrorMsg = false;
  bool _showTimeRequiredErrorMsg = false;



  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    if (widget._timeEntryInfo == null) {
      // we are trying to add a new time entry
      _isNewTimeEntry = true;
      _timeEntryInfo = TimeEntryInfo(id: Uuid().v1());
      _isEditable = true;
      _timeController.text = '';
      _notesController.text = '';
    } else {
      // we are trying to display read only info or edit an existing time entry info
      // so read in from the passed in _timeEntryInfo
      _timeEntryInfo = widget._timeEntryInfo;
      _isEditable = _timeEntryInfo.isEditable;
      _timeController.text = _timeEntryInfo.hours == 0
          ? ''
          : widget._timeEntryInfo.hours.toString();
      _notesController.text = widget._timeEntryInfo.notes ?? '';
    }

    _setupDatesList();
  }

  @override
  void dispose() {
    super.dispose();
    _timeController.dispose();
  }

  void _setupDatesList() {
    if (_isEditable && _timeEntryInfo.dateInfo == null) {
      final currentPeriod = widget._calendar.currentTimeSheetPeriod;
      // new time entry, add all possible dates and mark selected dates
      currentPeriod.allDaysInPeriod.keys.forEach((DateTime d) =>
          _dates.putIfAbsent(d, () => currentPeriod.isSelectedDate(d)));
    } else {
      _dates.putIfAbsent(_timeEntryInfo.dateInfo.date, () => true);
    }
  }

  void _setupClientsDropDownList() {
    _selectedClientId = _timeEntryInfo.selectedClient?.id ?? null;

    if (_dates.containsValue(true)) {
      // if TimeEntry info already contains clients use them (i.e. we are in edit/view mode)
      List<Info> list = _timeEntryInfo.clientCodes.isNotEmpty
          ? _timeEntryInfo.clientCodes
          : widget._calendar.getAllPossibleClientCodes();
      _clientList = list
          .map(
            (cc) => DropdownMenuItem<String>(
                  child: Text(cc.code),
                  value: cc.id,
                ),
          )
          .toList();
    } else {
      _clientList = [];
      _projectsList = [];
      _tasksList = [];
      _selectedProjectId = null;
      _selectedTaskId = null;
      _enableTime = false;
      _enableNotes = false;
      _timeController.text =
          _timeEntryInfo.hours == 0 ? '' : _timeEntryInfo.hours.toString();
      _notesController.text = _timeEntryInfo.notes ?? '';
    }
  }

  void _setupProjectsDropDownList() {
    List<Info> list = _timeEntryInfo.projectCodes.isNotEmpty
        ? _timeEntryInfo.clientCodes
        : widget._calendar.getAllPossibleProjectCodes(_selectedClientId);
    _projectsList = list
        .map(
          (pc) => DropdownMenuItem<String>(
                child: Text(pc.code),
                value: pc.id,
              ),
        )
        .toList();
    _selectedProjectId = _timeEntryInfo.selectedProject?.id ?? null;
  }

  void _setupTasksDropDownList() {
    List<Info> list = _timeEntryInfo.taskCodes.isNotEmpty
        ? _timeEntryInfo.taskCodes
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
    _selectedTaskId = _timeEntryInfo.selectedTask?.id ?? null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: floatingActionButtonBar,
      body: SafeArea(
        child: body,
      ),
    );
  }

  Widget get floatingActionButtonBar {
    final children = <Widget>[
      FloatingActionButton(
        elevation: 8,
        mini: true,
        onPressed: () => Navigator.pop(context),
        child: Icon(Icons.close),
      ),
    ];
    if (_isEditable) {
      children.add(
        FloatingActionButton(
          elevation: 8,
          onPressed: _onSaveButtonPress,
          child: Icon(Icons.save_alt),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: children,
    );
  }

  Widget get body {
    _editableIconColor = _isEditable ? Theme.of(context).accentColor : null;
    return Center(
      child: Container(
        // height: MediaQuery.of(context).size.height - 50,
        // width: MediaQuery.of(context).size.width - 50,
        child: Card(
          child: Padding(
            padding: EdgeInsets.only(top: 20, bottom: 20, right: 20, left: 20),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
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
            selectedColor: _isEditable ? Theme.of(context).accentColor : null,
            onSelected: _isEditable
                ? (bool) {
                    setState(
                      () {
                        _dates[d] = !isSelected;
                        _setupClientsDropDownList();
                        _validateForm();
                      },
                    );
                  }
                : null,
            selected: isSelected,
            avatar: _isEditable && isSelected
                ? Icon(
                    Icons.done,
                    color: Colors.white,
                  )
                : null,
            label: Text(
              DateFormat('d E').format(d),
              style: TextStyle(
                color: _isEditable && isSelected ? Colors.white : null,
              ),
            ),
          ),
        );
      },
    );

    // select all chip
    if (_isEditable) {
      children.add(
        ChoiceChip(
          selectedColor: Theme.of(context).accentColor,
          onSelected: (bool val) {
            setState(
              () {
                _allDatesSelected = val;
                for (DateTime d in _dates.keys) {
                  _dates[d] = _allDatesSelected;
                }
                _setupClientsDropDownList();
                _validateForm();
              },
            );
          },
          selected: _allDatesSelected,
          avatar: _isEditable && _allDatesSelected
              ? Icon(
                  Icons.done,
                  color: Colors.white,
                )
              : null,
          label: Text(
            _allDatesSelected ? 'Deselect All' : 'Select All',
            style: TextStyle(
              color: _isEditable && _allDatesSelected ? Colors.white : null,
            ),
          ),
        ),
      );
    }

    Widget validationMessage = Text(
      _showDateRequriedErrorMsg
          ? 'Please select one or more days to enter time'
          : '',
      style: TextStyle(color: Theme.of(context).errorColor),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.date_range,
              color: _editableIconColor,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 1.0,
                children: children,
              ),
            ),
          ],
        ),
        validationMessage,
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
        isError: _showClientRequiredErrorMsg,
      );

  Widget get _projects => _dropDown(
        icon: Icons.folder,
        readOnlyText: _isEditable ? null : _timeEntryInfo.selectedProject.code,
        dropDownHintText: 'Project',
        dropDownItemList: _projectsList,
        selectedDropDownItem: _selectedProjectId,
        dropDownOnChanged: (val) => setState(
              () {
                _selectedProjectId = val;
                _setupTasksDropDownList();
              },
            ),
        isError: _showProjectRequriedErrorMsg,
      );

  Widget get _tasks => _dropDown(
        icon: Icons.work,
        readOnlyText: _isEditable ? null : _timeEntryInfo.selectedTask.code,
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
        isError: _showTaskRequiredErrorMsg,
      );

  Widget _dropDown(
      {IconData icon,
      String readOnlyText,
      String dropDownHintText,
      List<DropdownMenuItem<String>> dropDownItemList,
      String selectedDropDownItem,
      Function(String val) dropDownOnChanged,
      bool isError}) {
    var children = <Widget>[
      Icon(
        icon,
        color: dropDownItemList.length > 0 ? _editableIconColor : null,
      ),
      SizedBox(width: 10),
    ];

    if (_isEditable) {
      children.add(
        Expanded(
          child: DropdownButton(
            hint: Text(dropDownHintText),
            items: dropDownItemList,
            value: selectedDropDownItem,
            onChanged: (String val) {
              dropDownOnChanged(val);
              _validateForm();
            },
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

    Widget validationMessage = Text(
      isError ? '$dropDownHintText required' : '',
      style: TextStyle(color: Theme.of(context).errorColor),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(children: children),
        validationMessage,
      ],
    );
  }

  Widget get _time => _textField(
      icon: Icons.timer,
      textInputType: TextInputType.number,
      editingtController: _timeController,
      enableTextField: _enableTime,
      inputLabel: 'Time',
      isError: _showTimeRequiredErrorMsg);

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
      bool enableTextField,
      bool isError}) {
    if (!_isEditable && editingtController.text.isEmpty) return Container();
    final children = <Widget>[
      Icon(
        icon,
        color: enableTextField ? _editableIconColor : null,
      ),
      SizedBox(width: 10),
    ];

    if (_isEditable) {
      children.add(
        Expanded(
          child: TextField(
            enabled: enableTextField,
            controller: editingtController,
            keyboardType: textInputType,
            decoration: InputDecoration(labelText: inputLabel),
            onChanged: (String val) => _validateForm(),
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

    Widget validationMessage = isError == null
        ? Container()
        : Text(
            isError ? '$inputLabel required' : '',
            style: TextStyle(color: Theme.of(context).errorColor),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(children: children),
        validationMessage,
      ],
    );
  }

  void _onSaveButtonPress() {
    setState(() => _addButtonPressedOnce = true);
    if (_validateForm()) {
      // is it a new time entry?
      if (_isNewTimeEntry) {
        // add the time entry in to the correct date
        _dates.forEach(
          (DateTime d, bool isSelected) {
            if(isSelected){
              final dateInfo = widget._calendar.currentTimeSheetPeriod.createOrGetDateInfo(d);

            }
          },
        );
      }
    }
  }

  bool _validateForm() {
    if (_addButtonPressedOnce) {
      setState(
        () {
          _showDateRequriedErrorMsg = !_dates.containsValue(true);
          _showClientRequiredErrorMsg =
              _selectedClientId == null || _selectedClientId.isEmpty;
          _showProjectRequriedErrorMsg =
              _selectedProjectId == null || _selectedProjectId.isEmpty;
          _showTaskRequiredErrorMsg =
              _selectedTaskId == null || _selectedTaskId.isEmpty;
          _showTimeRequiredErrorMsg = _timeController.text.isEmpty;
          try {
            double.parse(_timeController.text);
          } catch (error) {
            _showTimeRequiredErrorMsg = true;
          }
        },
      );
    }
    return !_showClientRequiredErrorMsg &&
        !_showClientRequiredErrorMsg &&
        !_showProjectRequriedErrorMsg &&
        !_showTaskRequiredErrorMsg &&
        !_showTimeRequiredErrorMsg;
  }
}
