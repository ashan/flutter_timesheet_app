import 'package:flutter/material.dart';

import '../../../models/calendar.dart';
import '../../../models/time_entry_info.dart';

class TimeEntryDetailsWidget extends StatefulWidget {
  final CalendarModel calendar;
  final TimeEntryInfo timeEntryInfo;

  TimeEntryDetailsWidget(this.calendar, this.timeEntryInfo);

  @override
  State<StatefulWidget> createState() {
    return _TimeEntryDetailsWidgetState();
  }
}

class _TimeEntryDetailsWidgetState extends State<TimeEntryDetailsWidget> {
  String _selectedClientId = '';
  String _selectedProjectId = '';
  String _selectedTaskId = '';
  bool _isEditable = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedClientId = widget.timeEntryInfo.selectedClient.id;
    _selectedProjectId = widget.timeEntryInfo.selectedProject.id;
    _selectedTaskId = widget.timeEntryInfo.selectedTaskCode.id;
    _isEditable = widget.timeEntryInfo.isEditable;
    _controller.text = widget.timeEntryInfo.notes;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 50,
        width: MediaQuery.of(context).size.width - 50,
        child: SingleChildScrollView(
          child: Card(
            elevation: 8.0,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  clientSelection,
                  SizedBox(height: 20.0),
                  Divider(),
                  projectSelection,
                  SizedBox(height: 20.0),
                  Divider(),
                  taskSelection,
                  SizedBox(height: 20.0),
                  Divider(),
                  notes,
                  RaisedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Dismiss'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get clientSelection {
    final children = <Widget>[title('Client')]..addAll(
        widget.timeEntryInfo.clientCodes.map(
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
                        color: Colors.white, fontWeight: FontWeight.bold,)
                    : null,
              ),
        ),
      );
    return Wrap(
      spacing: 2,
      alignment: WrapAlignment.spaceBetween,
      children: children,
    );
  }

  Widget get projectSelection {
    final children = <Widget>[title('Project')]..addAll(
        widget.timeEntryInfo.projectCodes.map(
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
                        color: Colors.white, fontWeight: FontWeight.bold,)
                    : null,
              ),
        ),
      );
    return Wrap(
      spacing: 2,
      alignment: WrapAlignment.spaceBetween,
      children: children,
    );
  }

  Widget get taskSelection {
    final children = <Widget>[title('Task')]..addAll(
        widget.timeEntryInfo.projectCodes.map(
          (tc) => ChoiceChip(
                elevation: 8,
                label: Text(
                  tc.code,
                ),
                avatar: _selectedTaskId == tc.id ? Icon(Icons.done) : null,
                onSelected: _isEditable
                    ? (bool selected) => setState(() => _selectedTaskId =
                        _selectedTaskId == tc.id ? null : tc.id)
                    : null,
                selected: tc.id == _selectedTaskId,
                selectedColor:
                    _isEditable ? Theme.of(context).accentColor : null,
                disabledColor: Theme.of(context).chipTheme.disabledColor,
                labelStyle: _selectedTaskId == tc.id
                    ? TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )
                    : null,
              ),
        ),
      );
    return Wrap(
      spacing: 2,
      alignment: WrapAlignment.spaceBetween,
      children: children,
    );
  }

  Widget get notes {
    return Wrap(
      spacing: 2,
      alignment: WrapAlignment.spaceBetween,
      children: <Widget>[
        title('Notes'),
        TextField(
          maxLines: null,
          keyboardType: TextInputType.multiline,
          controller: _controller,
        ),
      ],
    );
  }

  Widget title(String title, {bool withDevider = true}) => Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              title,
              textScaleFactor: 0.9,
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(color: Colors.black, shadows: [
                BoxShadow(
                  color: Colors.grey[500],
                  offset: Offset(0.0, 2.5),
                  blurRadius: 5.5,
                ),
              ]),
            ),
          ),
        ],
      );
}
