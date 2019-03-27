import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart';
import 'package:intl/intl.dart';

class TimeSheetService {
  String _mainURL = "https://timesheet.tenzing.co.nz/TimeLive";
  final Map<String, String> _standardHeaders = {
    "Accept":
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
    "Accept-Encoding": "gzip, deflate, br",
    "Accept-Language": "en-US,en;q=0.9",
    "Cache-Control": "max-age=0",
    "Connection": "keep-alive",
    "Upgrade-Insecure-Requests": "1",
    "Content-Type": "application/x-www-form-urlencoded",
  };

  Map<String, String> _cookies;

  ///
  /// Factory constructor
  ///
  static final TimeSheetService _timeSheetService =
      TimeSheetService._internal();
  TimeSheetService._internal();
  factory TimeSheetService() => _timeSheetService;

  ///
  /// getters
  ///
  Future<bool> get isLoggedIn => Future.value(_cookies != null);

  ///
  /// Login to the Tenzing TimeSheet system
  ///
  Future<bool> login(String email, String password) async {
    Uri loginUrl = Uri.parse("$_mainURL/Default.aspx");
    IOClient ioClient = IOClient(_httpClient);

    String urlEncodedBody =
        r'__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=%2FwEPDwULLTExNDU5MzQ0NDFkZA%3D%3D&CtlLogin1%24Login1%24UserName=' +
            Uri.encodeComponent(email) +
            r'&CtlLogin1%24Login1%24Password=' +
            Uri.encodeComponent(password) +
            r'&CtlLogin1%24Login1%24Button1=Login';

    Response response = await ioClient.post(
      loginUrl,
      headers: _standardHeaders,
      body: urlEncodedBody,
    );
    if (response.statusCode != 302) {
      // login not successful return error
      print('Error: NOT 302 AS EXPECTED');
      return false;
    }

    // keep track of the cookie values and the employee page url
    _cookies = {};
    String cookiesStr = response.headers['set-cookie'];
    RegExp setCookieRegExp = new RegExp(r"(.*?)=(.*?)($|;|,(?! ))");
    setCookieRegExp.allMatches(cookiesStr).forEach((match) {
      String matchVal = match[0];
      if (matchVal.contains('SessionId'))
        _cookies.putIfAbsent("SessionID", () => match[0]);
      else if (matchVal.contains('AccountEmployeeId'))
        _cookies.putIfAbsent('AccountEmployeeId', () => matchVal.split(',')[1]);
      else if (matchVal.contains('ASPXAUTH') && !matchVal.contains('HttpOnly'))
        _cookies.putIfAbsent('ASPXAUTH', () => matchVal);
    });

    ioClient.close();
    return true;
  }

  ///
  /// Logout from Tenzing TimeSheet system
  ///
  Future<bool> logout() async {
    Uri logoutUrl =
        Uri.parse("$_mainURL/Employee/AccountEmployeeTimeEntryPeriodView.aspx");
    IOClient ioClient = IOClient(_httpClient);

    String urlEncodedBody =
        r"__EVENTTARGET=ctl00%24ctl00%24ctl00%24C%24C%24H1%24L%24LoginStatus1%24ctl00&__EVENTARGUMENT=&__LASTFOCUS=&__VIEWSTATE=&ctl00_ctl00_ctl00_C_C_Spt_SplitterDistance=155&ctl00_ctl00_ctl00_C_C_Spt_CollapseState=False&ctl00_ctl00_ctl00_C_C_Spt_ScrollPos=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24ddlEmployee=118&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24txtTimeEntryDate%24textBox=15%2F03%2F2019&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24txtTimeEntryDate%24hidden=15%2F03%2F2019&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24txtTimeEntryDate%24validateHidden=03%2F15%2F2019&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24txtTimeEntryDate%24enableHidden=true&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24txtTimesheetTotal=88%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24C=24&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24P=36&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24CP_ClientState=36%3A%3A%3AAdministration&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24PT=69&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24CT_ClientState=69%3A%3A%3AAdministration%7C+Non-Billable+Time&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24TT0=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24MT0_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24TT1=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24MT1_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24TT2=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24MT2_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24TT3=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24MT3_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24TT4=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24MT4_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24TT5=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24MT5_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24TT6=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24MT6_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24TT7=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24MT7_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24TT8=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24MT8_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24TT9=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24MT9_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24TT10=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24MT10_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24TT11=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24MT11_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24TT12=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24MT12_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24TT13=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24MT13_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24TT14=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl02%24MT14_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24C=72&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24CP_ClientState=%3A%3A%3A&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24CT_ClientState=%3A%3A%3A&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24TT0=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24MT0_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24TT1=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24MT1_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24TT2=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24MT2_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24TT3=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24MT3_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24TT4=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24MT4_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24TT5=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24MT5_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24TT6=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24MT6_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24TT7=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24MT7_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24TT8=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24MT8_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24TT9=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24MT9_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24TT10=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24MT10_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24TT11=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24MT11_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24TT12=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24MT12_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24TT13=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24MT13_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24TT14=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl03%24MT14_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24C=72&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24CP_ClientState=%3A%3A%3A&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24CT_ClientState=%3A%3A%3A&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24TT0=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24MT0_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24TT1=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24MT1_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24TT2=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24MT2_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24TT3=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24MT3_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24TT4=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24MT4_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24TT5=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24MT5_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24TT6=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24MT6_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24TT7=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24MT7_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24TT8=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24MT8_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24TT9=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24MT9_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24TT10=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24MT10_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24TT11=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24MT11_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24TT12=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24MT12_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24TT13=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24MT13_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24TT14=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl04%24MT14_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24C=72&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24CP_ClientState=%3A%3A%3A&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24CT_ClientState=%3A%3A%3A&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24TT0=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24MT0_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24TT1=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24MT1_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24TT2=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24MT2_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24TT3=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24MT3_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24TT4=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24MT4_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24TT5=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24MT5_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24TT6=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24MT6_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24TT7=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24MT7_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24TT8=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24MT8_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24TT9=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24MT9_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24TT10=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24MT10_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24TT11=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24MT11_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24TT12=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24MT12_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24TT13=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24MT13_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24TT14=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl05%24MT14_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24C=72&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24CP_ClientState=%3A%3A%3A&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24CT_ClientState=%3A%3A%3A&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24TT0=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24MT0_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24TT1=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24MT1_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24TT2=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24MT2_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24TT3=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24MT3_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24TT4=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24MT4_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24TT5=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24MT5_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24TT6=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24MT6_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24TT7=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24MT7_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24TT8=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24MT8_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24TT9=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24MT9_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24TT10=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24MT10_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24TT11=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24MT11_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24TT12=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24MT12_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24TT13=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24MT13_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24TT14=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl06%24MT14_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24C=72&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24CP_ClientState=%3A%3A%3A&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24CT_ClientState=%3A%3A%3A&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24TT0=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24MT0_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24TT1=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24MT1_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24TT2=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24MT2_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24TT3=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24MT3_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24TT4=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24MT4_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24TT5=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24MT5_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24TT6=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24MT6_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24TT7=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24MT7_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24TT8=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24MT8_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24TT9=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24MT9_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24TT10=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24MT10_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24TT11=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24MT11_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24TT12=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24MT12_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24TT13=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24MT13_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24TT14=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl07%24MT14_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24C=72&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24CP_ClientState=%3A%3A%3A&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24CT_ClientState=%3A%3A%3A&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24TT0=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24MT0_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24TT1=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24MT1_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24TT2=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24MT2_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24TT3=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24MT3_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24TT4=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24MT4_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24TT5=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24MT5_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24TT6=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24MT6_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24TT7=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24MT7_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24TT8=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24MT8_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24TT9=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24MT9_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24TT10=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24MT10_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24TT11=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24MT11_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24TT12=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24MT12_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24TT13=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24MT13_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24TT14=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl08%24MT14_ClientState=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl09%24st0=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl09%24st1=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl09%24st2=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl09%24st3=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl09%24st4=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl09%24st5=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl09%24st6=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl09%24st7=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl09%24st8=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl09%24st9=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl09%24st10=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl09%24st11=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl09%24st12=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl09%24st13=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24G%24ctl09%24st14=08%3A00&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24txtPeriodDescription=&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24CopyFromCalendarPopup%24textBox=11%2F03%2F2019&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24CopyFromCalendarPopup%24hidden=11%2F03%2F2019&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24CopyFromCalendarPopup%24validateHidden=03%2F11%2F2019&ctl00%24ctl00%24ctl00%24C%24C%24H1%24C%24W%24CopyFromCalendarPopup%24enableHidden=true&hiddenInputToUpdateATBuffer_CommonToolkitScripts=1";

    Response response = await ioClient.post(
      logoutUrl,
      headers: _loggedInHeaders,
      body: urlEncodedBody,
    );

    if (response.statusCode != 302) {
      var test = "";
    }
    _cookies = null;
    return Future.value(true);
  }

  ///
  /// Get accountEmployeeTimeEntryPeriodView.aspx
  ///
  Future<Document> getAccountEmployeeTimeEntryPeriodView(
      {@required DateTime periodStartDate}) async {
    final formattedStartDate = DateFormat('MM/dd/yyyy').format(periodStartDate);
    Uri timeEntryUrl = Uri.parse(
        "$_mainURL/Employee/AccountEmployeeTimeEntryPeriodView.aspx?Mode=Week&StartDate=$formattedStartDate&AccountEmployeeId=$_accountEmployeeID");
    IOClient ioClient = IOClient(_httpClient);
    Response response = await ioClient.get(
      timeEntryUrl,
      headers: _loggedInHeaders,
    );
    // final body = response.body;
    final doc = parse(response.body);
    return doc;
  }

  ///
  /// returns the project of a client after calling GetAccuntProjectsByClient.aspx
  ///
  Future<String> getAccountProjectsByClient(String selectedClientID) async {
    Uri url = Uri.parse(
        "$_mainURL/Services/ProjectService.asmx/GetAccountProjectsByClient");
    IOClient ioClient = IOClient(_httpClient);

    Response response = await ioClient.post(url,
        headers: _jsonHeader,
        body:
            '{"knownCategoryValues":"undefined:$selectedClientID;","category":"$_accountEmployeeID,0,True,1,0,False"}');
    final body = response.body;
    return Future.value(body);
  }

  ///
  /// returns the tasks after calling GetAccountProjectTasksInTimeSheet.aspx
  ///
  Future<String> getAccountProjectTasksInTimeSheet(
      String selectedClientID, String selectedProjectID) async {
    Uri url = Uri.parse(
        '$_mainURL//Services/ProjectService.asmx/GetAccountProjectTasksInTimeSheet');
    IOClient ioClient = IOClient(_httpClient);

    Response response = await ioClient.post(url,
        headers: _jsonHeader,
        body:
            '{"knownCategoryValues":"undefined:$selectedClientID;$_accountEmployeeID,0,True,1,0,False:$selectedProjectID;","category":"$_accountEmployeeID,False,0,1,0,0"}');
    final body = response.body;
    return Future.value(body);
  }

  ///
  /// ----------- private methods -----------------------
  ///
  HttpClient get _httpClient => HttpClient()
    ..badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

  Map<String, String> get _loggedInHeaders =>
      Map<String, String>.from(_standardHeaders)
        ..addAll({
          "Cookie": _cookies.values.join(),
        });

  String get _accountEmployeeID => _cookies != null
      ? _cookies['AccountEmployeeId'].split('=')[1].replaceAll(';', '').trim()
      : null;

  Map<String, String> get _jsonHeader =>
      Map<String, String>.from(_loggedInHeaders)
        ..update(
            'Content-Type', (String val) => 'application/json; charset=UTF-8');
}
