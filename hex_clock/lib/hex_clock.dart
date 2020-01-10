// Copyright 2020 Jan Štol. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';

class HexClock extends StatefulWidget {
  final ClockModel model;

  const HexClock(this.model);

  @override
  _HexClockState createState() => _HexClockState();
}

class _HexClockState extends State<HexClock> {
  DateTime _now = DateTime.now();
  Timer _timer;
  int _r, _g, _b;

  @override
  void initState() {
    super.initState();
    _r = 0;
    _g = 0;
    _b = 0;
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
      _r = _now.hour.toRange(0, 23, 0, 255).toInt();
      _g = _now.minute.toRange(0, 59, 0, 255).toInt();
      _b = _now.second.toRange(0, 59, 0, 255).toInt();

      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.now();
    final hourFormat = widget.model.is24HourFormat ? 'HH' : 'hh';
    final time = DateFormat("$hourFormat:mm:ss").format(dateTime);
    final color = Color.fromARGB(255, _r, _g, _b);

    final theme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            primaryColor:
                color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            backgroundColor: color,
          )
        : Theme.of(context).copyWith(
            primaryColor: color,
            backgroundColor: Colors.black,
          );

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Hex clock with time $time',
        value: time,
      ),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 800),
        color: theme.backgroundColor,
        alignment: Alignment.center,
        child: AutoSizeText(
          '$time',
          maxLines: 1,
          minFontSize: 70.0,
          stepGranularity: 0.5,
          textAlign: TextAlign.center,
          wrapWords: false,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),

          //stepGranularity: 0.1,
        ),
      ),
    );
  }
}

extension on num {
  double toRange(num oldMin, num oldMax, num newMin, num newMax) =>
      (((this - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin;
}
