import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../providers/tmesheet.dart';
import './calendar_screen.dart';
import './widgets/assorted_widgets.dart';
import '../models/calendar.dart';

class LoginScreen extends StatefulWidget {
  static const String ROUTE = "/";
  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _emailRegExp = RegExp(r'^[a-zA-Z0-9._]*@tenzing\.co\.nz$');
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();

  var _emailFocusNode = FocusNode();
  var _passwordFocusNode = FocusNode();

  var _dirtyEmail = false;
  var _dirtyPassword = false;
  var _emailSuffixIcon = Icons.help_outline;
  var _passwordSuffixIcon = Icons.help_outline;

  var _logOnInProgress = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(
      () {
        if (!_emailFocusNode.hasFocus) {
          setState(() {
            if (!_dirtyEmail) _dirtyEmail = true;
            _emailSuffixIcon = validateEmail(_emailController.text) == null
                ? Icons.done
                : Icons.help_outline;
          });
        }
      },
    );
    _passwordFocusNode.addListener(
      () {
        if (!_passwordFocusNode.hasFocus) {
          setState(() {
            if (!_dirtyPassword) _dirtyPassword = true;
            _passwordSuffixIcon =
                validatePassword(_passwordController.text) == null
                    ? Icons.done
                    : Icons.help_outline;
          });
        }
      },
    );
    _emailController.addListener(() {
      setState(() {
        if (!_dirtyEmail && _emailController.text.isNotEmpty)
          _dirtyEmail = true;
        _emailSuffixIcon =
            _dirtyEmail && validateEmail(_emailController.text) == null
                ? _emailSuffixIcon = Icons.done
                : _emailSuffixIcon = Icons.help_outline;
      });
    });

    _passwordController.addListener(() {
      setState(() {
        if (!_dirtyPassword && _passwordController.text.isNotEmpty)
          _dirtyPassword = true;
        _passwordSuffixIcon =
            _dirtyPassword && validatePassword(_passwordController.text) == null
                ? _emailSuffixIcon = Icons.done
                : _emailSuffixIcon = Icons.help_outline;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<CalendarModel>(
      builder: (context, widget, calendar) {
        final childWidgets = <Widget>[
          SingleChildScrollView(
            child: _loginForm(calendar),
          ),
        ];

        if (_logOnInProgress) {
          childWidgets.add(AssortedWidgets.progressIndicator);
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            centerTitle: true,
            title: Text('Login'),
            elevation: 8.0,
          ),
          body: Center(
            child: Stack(
              children: childWidgets,
            ),
          ),
        );
      },
    );
  }

  Widget _loginForm(CalendarModel calendar) {
    final loginWidget = Container(
      padding: EdgeInsets.all(20.0),
      height: 300.0,
      child: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: _emailField,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: _passwordField(calendar),
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: _loginButton(calendar),
            ),
          ],
        ),
      ),
    );

    return Center(
      child: Form(
        key: _formKey,
        child: loginWidget,
      ),
    );
  }

  Widget get _emailField => TextFormField(
        focusNode: _emailFocusNode,
        textInputAction: TextInputAction.done,
        controller: _emailController,
        autovalidate: true,
        onFieldSubmitted: (String val) {
          _emailFocusNode.unfocus();
          FocusScope.of(context).requestFocus(_passwordFocusNode);
        },
        validator: validateEmail,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          suffixIcon: Icon(_emailSuffixIcon),
          labelText: 'Email',
        ),
      );

  Widget _passwordField(CalendarModel calendar) => TextFormField(
        textInputAction: TextInputAction.done,
        focusNode: _passwordFocusNode,
        onFieldSubmitted: (String val) => onLoginButtonPress(calendar),
        controller: _passwordController,
        autovalidate: true,
        validator: validatePassword,
        obscureText: true,
        decoration: InputDecoration(
          suffixIcon: Icon(_passwordSuffixIcon),
          labelText: 'Password',
        ),
      );

  Widget _loginButton(CalendarModel calendar) => RawMaterialButton(
        onPressed: () => onLoginButtonPress(calendar),
        splashColor: Theme.of(context).buttonTheme.colorScheme.primaryVariant,
        textStyle: Theme.of(context)
            .textTheme
            .subtitle
            .copyWith(color: Colors.white, fontWeight: FontWeight.w400),
        child: Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Theme.of(context).buttonTheme.colorScheme.primary,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Submit'),
              Icon(Icons.exit_to_app),
            ],
          ),
        ),
      );

  String validateEmail(String val) {
    if (_dirtyEmail &&
        (val.trim().length == 0 || !_emailRegExp.hasMatch(val))) {
      return 'Invalid Tenzing Email';
    }
    return null;
  }

  String validatePassword(String val) {
    if (_dirtyPassword && val.trim().length == 0) {
      return 'Invalid Password';
    }
    return null;
  }

  void onLoginButtonPress(CalendarModel calendar) {
    if (_formKey.currentState.validate()) {
      setState(() => _logOnInProgress = true);
      TimeSheetProvider()
          .logIn(_emailController.text, _passwordController.text)
          .then(
        (bool success) {
          setState(() => _logOnInProgress = false);

          if (success) {
            calendar.init();
            Navigator.of(context).pushNamed(CalendarScreen.ROUTE);
          } else {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('Login error, please retry! '),
            ));
          }
        },
      );
    }
  }
}
