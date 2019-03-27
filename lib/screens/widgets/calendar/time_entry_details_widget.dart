import 'package:flutter/material.dart';

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
  String _selectedDate = '';
  String _selectedClientId = '';
  String _selectedProjectId = '';
  String _selectedTaskId = '';
  bool _isEditable = false;
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedClientId = widget._timeEntryInfo.selectedClient.id;
    _selectedProjectId = widget._timeEntryInfo.selectedProject.id;
    _selectedTaskId = widget._timeEntryInfo.selectedTaskCode.id;
    _isEditable = widget._timeEntryInfo.isEditable;
    _timeController.text = widget._timeEntryInfo.hours.toString();
    _notesController.text = widget._timeEntryInfo.notes;
  }

  @override
  void dispose() {
    super.dispose();
    _timeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            dateSelection,
            SizedBox(height: 15.0),
            clientSelection,
            SizedBox(height: 15.0),
            projectSelection,
            SizedBox(height: 15.0),
            taskSelection,
            SizedBox(height: 15.0),
            time,
            SizedBox(height: 20),
            notes,
            // RaisedButton(
            //   onPressed: () => Navigator.pop(context),
            //   child: Text('Dismiss'),
            // )
          ],
        ),
      ),
      Align(
        alignment: Alignment.topRight,
        child: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      )
    ];

    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 50,
        width: MediaQuery.of(context).size.width - 50,
        child: SingleChildScrollView(
          child: Card(
            child: Stack(
              children: children,
            ),
          ),
        ),
      ),
    );
  }

  Widget get dateSelection {
    final children = <Widget>[title('Date')];
    if (!_isEditable) {
      children.add(
        ChoiceChip(
          elevation: 0,
          label: Text(
            widget._timeEntryInfo.dateInfo.toString(),
          ),
          avatar: Icon(Icons.done),
          onSelected: null,
          selected: true,
        ),
      );
    } else {
      children.addAll(
        widget._calendar.currentTimeSheetPeriod.periodDays.values.map(
          (d) => ChoiceChip(
                elevation: 8,
                label: Text(
                  d.toString(),
                ),
                avatar: _selectedDate == d.toString() ? Icon(Icons.done) : null,
                onSelected: _isEditable
                    ? (bool selected) =>
                        setState(() => _selectedDate = d.toString())
                    : null,
                selected: d.toString() == _selectedDate,
                selectedColor:
                    _isEditable ? Theme.of(context).accentColor : null,
                labelStyle: _selectedDate == d.toString()
                    ? TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )
                    : null,
              ),
        ),
      );
    }

    return Wrap(
      spacing: 2,
      alignment: WrapAlignment.spaceBetween,
      children: children,
    );
  }

  Widget get clientSelection {
    final children = <Widget>[title('Client')];
    if (!_isEditable) {
      children.add(
        ChoiceChip(
          elevation: 0,
          label: Text(widget._timeEntryInfo.selectedClient.toString()),
          onSelected: null,
          selected: true,
          avatar: Icon(Icons.done),
        ),
      );
    } else {
      children.addAll(
        widget._timeEntryInfo.clientCodes.map(
          (cc) => ChoiceChip(
                elevation: 8,
                label: Text(
                  cc.code,
                ),
                avatar: _selectedClientId == cc.id ? Icon(Icons.done) : null,
                onSelected: _isEditable
                    ? (bool selected) =>
                        setState(() => _selectedClientId = cc.id)
                    : null,
                selected: cc.id == _selectedClientId,
                selectedColor:
                    _isEditable ? Theme.of(context).accentColor : null,
                labelStyle: _selectedClientId == cc.id
                    ? TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )
                    : null,
              ),
        ),
      );
    }

    return Wrap(
      spacing: 2,
      alignment: WrapAlignment.spaceBetween,
      children: children,
    );
  }

  Widget get projectSelection {
    final children = <Widget>[title('Project')];
    if (!_isEditable) {
      children.add(
        ChoiceChip(
          elevation: 0,
          label: Text(widget._timeEntryInfo.selectedProject.toString()),
          onSelected: null,
          selected: true,
          avatar: Icon(Icons.done),
        ),
      );
    } else {
      children.addAll(
        widget._timeEntryInfo.projectCodes.map(
          (pc) => ChoiceChip(
                elevation: 8,
                label: Text(
                  pc.code,
                ),
                avatar: _selectedProjectId == pc.id ? Icon(Icons.done) : null,
                onSelected: _isEditable
                    ? (bool selected) => setState(() => _selectedProjectId =
                        _selectedProjectId == pc.id ? null : pc.id)
                    : null,
                selected: pc.id == _selectedProjectId,
                selectedColor:
                    _isEditable ? Theme.of(context).accentColor : null,
                disabledColor: Theme.of(context).chipTheme.disabledColor,
                labelStyle: _selectedProjectId == pc.id
                    ? TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )
                    : null,
              ),
        ),
      );
    }

    return Wrap(
      spacing: 2,
      alignment: WrapAlignment.spaceBetween,
      children: children,
    );
  }

  Widget get taskSelection {
    final children = <Widget>[title('Task')];
    if (!_isEditable) {
      children.add(
        ChoiceChip(
          elevation: 0,
          label: Text(widget._timeEntryInfo.selectedTaskCode.toString()),
          onSelected: null,
          selected: true,
          avatar: Icon(Icons.done),
        ),
      );
    } else {
      children.addAll(widget._timeEntryInfo.projectCodes.map(
        (tc) => ChoiceChip(
              elevation: 8,
              label: Text(
                tc.code,
              ),
              avatar: _selectedTaskId == tc.id ? Icon(Icons.done) : null,
              onSelected: _isEditable
                  ? (bool selected) => setState(() =>
                      _selectedTaskId = _selectedTaskId == tc.id ? null : tc.id)
                  : null,
              selected: tc.id == _selectedTaskId,
              selectedColor: _isEditable ? Theme.of(context).accentColor : null,
              disabledColor: Theme.of(context).chipTheme.disabledColor,
              labelStyle: _selectedTaskId == tc.id
                  ? TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )
                  : null,
            ),
      ));
    }

    return Wrap(
      spacing: 2,
      alignment: WrapAlignment.spaceBetween,
      children: children,
    );
  }

  Widget get time {
    return Wrap(
      spacing: 2,
      alignment: WrapAlignment.spaceBetween,
      children: <Widget>[
        title('Time'),
        TextField(
          enabled: _isEditable,
          controller: _timeController,
        ),
      ],
    );
  }

  Widget get notes {
    return Wrap(
      spacing: 2,
      alignment: WrapAlignment.spaceBetween,
      children: <Widget>[
        title('Notes'),
        TextField(
          enabled: _isEditable,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          controller: _notesController,
        ),
      ],
    );
  }

  Widget title(String title, {bool withDismiss = false}) {
    final children = <Widget>[
      Container(
        child: Text(
          title,
          textScaleFactor: 0.9,
          style: Theme.of(context).textTheme.title.copyWith(
            color: Colors.black54,
            shadows: [
              BoxShadow(
                color: Colors.grey[500],
                offset: Offset(0.0, 2.5),
                blurRadius: 5.5,
              ),
            ],
          ),
        ),
      ),
    ];

    if (withDismiss) {
      children.add(
        IconButton(
          icon: Icon(Icons.close),
          alignment: Alignment.topRight,
          onPressed: () => Navigator.pop(context),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    );
  }
}
