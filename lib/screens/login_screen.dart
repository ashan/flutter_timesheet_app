import 'package:flutter/material.dart';

import '../providers/tmesheet.dart';
import './calendar_screen.dart';
import './widgets/assorted_widgets.dart';

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

  final _emailRegExp = RegExp(r'^[a-zA-Z0-9._]*@tenzing.co.nz$');
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
    _emailController.addListener(() {
      setState(() {
        _dirtyEmail = true;
        if (validateEmail(_emailController.text) == null)
          _emailSuffixIcon = Icons.done;
        else
          _emailSuffixIcon = Icons.help_outline;
      });
    });

    _passwordController.addListener(() {
      setState(() {
        _dirtyPassword = true;
        if (validatePassword(_passwordController.text) == null)
          _passwordSuffixIcon = Icons.done;
        else
          _passwordSuffixIcon = Icons.help_outline;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final childWidgets = <Widget>[
      SingleChildScrollView(
        child: _loginForm,
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
      ),
      body: Stack(
        children: childWidgets,
      ),
    );
  }

  Widget get _loginForm {
    final loginWidget = Container(
      padding: EdgeInsets.all(20.0),
      height: 300.0,
      child: Center(
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: _emailField),
            Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: _passwordField),
            SizedBox(height: 20.0),
            Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: _loginButton,
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
        autofocus: true,
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

  Widget get _passwordField => TextFormField(
        textInputAction: TextInputAction.done,
        focusNode: _passwordFocusNode,
        onFieldSubmitted: (String val) => onLoginButtonPress(),
        controller: _passwordController,
        autovalidate: true,
        validator: validatePassword,
        obscureText: true,
        decoration: InputDecoration(
          suffixIcon: Icon(_passwordSuffixIcon),
          labelText: 'Password',
        ),
      );

  Widget get _loginButton => RawMaterialButton(
        onPressed: onLoginButtonPress,
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

  void onLoginButtonPress() {
    if (_formKey.currentState.validate()) {
      setState(() => _logOnInProgress = true);
      TimeSheetProvider()
          .logIn(_emailController.text, _passwordController.text)
          .then(
        (bool success) {
          setState(() => _logOnInProgress = false);

          if (success) {
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
