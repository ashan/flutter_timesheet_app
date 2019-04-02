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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  var _clientList = <DropdownMenuItem<String>>[];
  var _projectsList = <DropdownMenuItem<String>>[];
  var _tasksList = <DropdownMenuItem<String>>[];

  var _enableTime = false;
  var _enableNotes = false;

  var _dates = <DateTime, bool>{};
  var _allDatesSelected = false;

  bool _isEditable = false;

  Color _editableIconColor;

  final TextEditingController _hoursController = TextEditingController();
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

  void _init({bool isReInsertingData = false}) {
    if (isReInsertingData || widget._timeEntryInfo == null) {
      // we are trying to add a new time entry
      _timeEntryInfo =
          TimeEntryInfo(id: 'dummy time entry for copying purposes');
      _isEditable = true;
      _hoursController.text = '';
      _notesController.text = '';
    } else {
      // we are trying to display read only info or edit an existing time entry info
      // so read in from the passed in _timeEntryInfo
      _timeEntryInfo = widget._timeEntryInfo;
      _isEditable = _timeEntryInfo.isEditable;

      _enableTime = true;
      _enableNotes = true;
      _hoursController.text = _timeEntryInfo.hours == 0
          ? ''
          : widget._timeEntryInfo.hours.toString();
      _notesController.text = widget._timeEntryInfo.notes ?? '';
    }

    _setupDatesList();
    _setupClientsDropDownList();
    _setupProjectsDropDownList();
    _setupTasksDropDownList();
  }

  @override
  void dispose() {
    super.dispose();
    _hoursController.dispose();
  }

  void _setupDatesList() {
    if (_isEditable) {
      final currentPeriod = widget._calendar.currentTimeSheetPeriod;
      // new time entry, add all possible dates and mark selected dates
      currentPeriod.allDaysInPeriod.keys.forEach((DateTime d) =>
          _dates.putIfAbsent(d, () => currentPeriod.isSelectedDate(d)));
    } else {
      _dates.putIfAbsent(_timeEntryInfo.dateInfo.date, () => true);
    }
  }

  void _setupClientsDropDownList() {
    if (_dates.containsValue(true)) {
      List<Info> list = [];
      if (_timeEntryInfo.clientCodes.isNotEmpty) {
        list = List<Info>.from(_timeEntryInfo.clientCodes);
      } else {
        list = List<Info>.from(widget._calendar.getAllPossibleClientCodes());
        _timeEntryInfo.clientCodes = List<Info>.from(list);
      }
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
      _enableTime = false;
      _enableNotes = false;
      _hoursController.text =
          _timeEntryInfo.hours == 0 ? '' : _timeEntryInfo.hours.toString();
      _notesController.text = _timeEntryInfo.notes ?? '';
    }
  }

  void _setupProjectsDropDownList() {
    if (_timeEntryInfo.selectedClientId != null)
      _timeEntryInfo.projectCodes = List<Info>.from(widget._calendar
          .getAllPossibleProjectCodes(_timeEntryInfo.selectedClientId));

    _projectsList = _timeEntryInfo.projectCodes
        .map(
          (pc) => DropdownMenuItem<String>(
                child: Text(pc.code),
                value: pc.id,
              ),
        )
        .toList();
  }

  void _setupTasksDropDownList() {
    if (_timeEntryInfo.selectedClientId != null &&
        _timeEntryInfo.selectedProjectId != null)
      _timeEntryInfo.taskCodes = List<Info>.from(widget._calendar
          .getAllPossibleTaskCodes(_timeEntryInfo.selectedClientId,
              _timeEntryInfo.selectedProjectId));

    _tasksList = _timeEntryInfo.taskCodes
        .map(
          (tc) => DropdownMenuItem<String>(
                child: Text(tc.code),
                value: tc.id,
              ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                  _hours,
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
        selectedDropDownItem: _timeEntryInfo.selectedClientId,
        dropDownOnChanged: (val) => setState(
              () {
                _timeEntryInfo.selectedClientId = val;
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
        selectedDropDownItem: _timeEntryInfo.selectedProjectId,
        dropDownOnChanged: (val) => setState(
              () {
                _timeEntryInfo.selectedProjectId = val;
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
        selectedDropDownItem: _timeEntryInfo.selectedTaskId,
        dropDownOnChanged: (val) => setState(
              () {
                _timeEntryInfo.selectedTaskId = val;
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

  Widget get _hours => _textField(
      icon: Icons.timer,
      textInputType: TextInputType.number,
      editingtController: _hoursController,
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
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(
      () {
        _addButtonPressedOnce = true;
        _timeEntryInfo.hours =
            _hoursController.text != null && _hoursController.text.isNotEmpty
                ? double.parse(_hoursController.text)
                : 0.0;
        _timeEntryInfo.notes = _notesController.text;
      },
    );
    if (_validateForm()) {
      // copy the time entry details in to new time entry instances
      widget._calendar.currentTimeSheetPeriod.clearSelectedDays();
      _dates.forEach(
        (DateTime d, bool isSelected) {
          if (isSelected) {
            final dateInfo =
                widget._calendar.currentTimeSheetPeriod.createOrGetDateInfo(d);
            dateInfo.createOrGetTimeEntryInfoFrom(
                newId: Uuid().v1(), copyFrom: _timeEntryInfo);

            widget._calendar.onDateTap(d);
          }
        },
      );
    }
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text('Time added! '),
      ),
    );

    // re init
    _init(isReInsertingData: true);
  }

  bool _validateForm() {
    if (_addButtonPressedOnce) {
      setState(
        () {
          _showDateRequriedErrorMsg = !_dates.containsValue(true);
          _showClientRequiredErrorMsg =
              _timeEntryInfo.selectedClientId == null ||
                  _timeEntryInfo.selectedClientId.isEmpty;
          _showProjectRequriedErrorMsg =
              _timeEntryInfo.selectedProjectId == null ||
                  _timeEntryInfo.selectedProjectId.isEmpty;
          _showTaskRequiredErrorMsg = _timeEntryInfo.selectedTaskId == null ||
              _timeEntryInfo.selectedTaskId.isEmpty;
          _showTimeRequiredErrorMsg = _hoursController.text.isEmpty;
          try {
            double.parse(_hoursController.text);
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
