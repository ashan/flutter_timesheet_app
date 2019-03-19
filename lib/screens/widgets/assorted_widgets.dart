import 'package:flutter/material.dart';

class AssortedWidgets{
  static Widget get progressIndicator => Stack(
        children: <Widget>[
          Opacity(
            opacity: 0.5,
            child: ModalBarrier(
              dismissible: false,
              color: Colors.grey,
            ),
          ),
          Center(
            child: Card(
              elevation: 8,
              child: Padding(
                padding: EdgeInsets.only(
                  top: 10.0,
                  bottom: 10.0,
                  left: 25.0,
                  right: 25.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(width: 15.0),
                    Text('In progress')
                  ],
                ),
              ),
            ),
          ),
        ],
      );
}