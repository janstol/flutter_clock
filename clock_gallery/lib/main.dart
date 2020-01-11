// Copyright 2019 Jan Štol. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:analog_clock/analog_clock.dart';
import 'package:digital_alarm_clock/alarm_clock.dart';
import 'package:digital_clock/digital_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:hex_clock/hex_clock.dart';

void main() => runApp(ClockCustomizer((model) => App(clockModel: model)));

class App extends StatefulWidget {
  final ClockModel clockModel;

  const App({Key key, this.clockModel}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  PageController _controller;
  List<Clock> _clocks;
  Clock _clock;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
    _clocks = [
      Clock(
        name: 'Analog clock',
        author: 'The Chromium Authors',
        widget: AnalogClock(widget.clockModel),
      ),
      Clock(
        name: 'Digital alarm clock',
        author: 'Jan Štol',
        widget: Builder(builder: (context) => AlarmClock(widget.clockModel)),
      ),
      Clock(
        name: 'Digital clock',
        author: 'The Chromium Authors',
        widget: Builder(builder: (context) => DigitalClock(widget.clockModel)),
      ),
      Clock(
        name: 'Hex clock',
        author: 'Jan Štol',
        widget: HexClock(widget.clockModel),
      ),
    ];

    _clock = _clocks[_controller.initialPage];

    _controller.addListener(() {
      setState(() {
        _clock = _clocks[_controller.page.round()];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 800, maxHeight: 480),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = MediaQuery.of(context).size;
            final newSize = constraints.constrain(size);

            return MediaQuery(
              data: MediaQuery.of(context).copyWith(size: newSize),
              child: Stack(
                children: [
                  PageView(
                    controller: _controller,
                    pageSnapping: true,
                    children: _clocks.map((c) => c.widget).toList(),
                  ),
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Tooltip(
                      message: 'Swipe left/right to change the clock.\n'
                          'Click to display options '
                          '(cog icon at the top-right corner of the screen).',
                      child: Opacity(
                        opacity: 0.25,
                        child: Icon(Icons.help_outline),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Tooltip(
                      message: '"${_clock.name}"\n by ${_clock.author}',
                      child: Opacity(
                        opacity: 0.25,
                        child: Icon(Icons.info_outline),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class Clock {
  final String name;
  final String author;
  final Widget widget;

  const Clock({this.name, this.author, this.widget});
}
