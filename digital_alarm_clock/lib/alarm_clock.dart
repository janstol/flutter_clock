// Copyright 2020 Jan Štol. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';
import 'package:segment_display/segment_display.dart';

class AlarmClock extends StatefulWidget {
  final ClockModel model;

  const AlarmClock(this.model);

  @override
  _AlarmClockState createState() => _AlarmClockState();
}

class _AlarmClockState extends State<AlarmClock> {
  DateTime _now = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.now();
    final hourFormat = widget.model.is24HourFormat as bool ? 'HH' : 'hh';
    final time = DateFormat('$hourFormat:mm:ss').format(dateTime);
    //final date = DateFormat('dmy').format(dateTime);

    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            primaryColor: const Color(0xFF1E1A17),
            backgroundColor: const Color(0xFF6F7E5D),
          )
        : Theme.of(context).copyWith(
            primaryColor: const Color(0xFFFF0000),
            backgroundColor: Colors.black,
          );

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Digital alarm clock with time $time',
        value: time,
      ),
      child: Container(
        alignment: Alignment.center,
        color: theme.backgroundColor,
        child: SevenSegmentDisplay(
          value: time,
          size: size.width * 0.013,
          backgroundColor: theme.backgroundColor,
          segmentStyle: DefaultSegmentStyle(
            enabledColor: theme.primaryColor,
            disabledColor: theme.primaryColor.withOpacity(0.1),
          ),
        ),
      ),
    );
  }
}
