import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';

const _numberDivider = _TextDivider('-', ' ');
const _digitDivider = _TextDivider('_', '   ');
const _middleDivider = _TextDivider('|', '       ');
const _newLineDivider = _TextDivider('\n', '\n');

const _digitsMap = <String, int>{
  '0': 0x7E3F, //111111000111111
  '1': 0x43F1, //100001111110001
  '2': 0x5EBD, //101111010111101
  '3': 0x7EB5, //111111010110101
  '4': 0x7C87, //111110010000111
  '5': 0x76B7, //111011010110111
  '6': 0x76BF, //111011010111111
  '7': 0xFA1, //000111110100001
  '8': 0x7EBF, //111111010111111
  '9': 0x7EB7, //111111010110111
};

class NumericClock extends StatefulWidget {
  final ClockModel model;

  const NumericClock(this.model);

  @override
  _NumericClockState createState() => _NumericClockState();
}

class _NumericClockState extends State<NumericClock> {
  DateTime _now = DateTime.now();
  Timer _timer;
  List<String> _template;
  ThemeData _theme;
  String _lastTime; // last time in 'hh:mm' format
  List<String> _enabledNumbers;
  List<TextSpan> _textSpans;

  @override
  void initState() {
    super.initState();
    _textSpans = [];
    _template ??= _generateClockTemplate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            primaryColor: const Color(0xFF101010), // Enabled number color.
            disabledColor: Colors.grey[200], // Disabled number color.
            highlightColor: Colors.red[600], // 'Seconds' highlight color.
            backgroundColor: Colors.grey[50],
          )
        : Theme.of(context).copyWith(
            primaryColor: Colors.grey[50],
            disabledColor: Colors.grey[900],
            highlightColor: Colors.red[600],
            backgroundColor: const Color(0xFF101010),
          );
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
      final hourFormat = widget.model.is24HourFormat as bool ? 'HH' : 'hh';

      _createTextSpans(
        time: DateFormat('${hourFormat}mm').format(_now),
        seconds: DateFormat('ss').format(_now),
        theme: _theme,
      );

      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  /// Generates 'template' for clock.
  List<String> _generateClockTemplate() {
    final template = <String>[];
    var counter = 0;

    for (var i = 0; i < 60; i++) {
      final row = (i / 12).floor();

      final number = '${row + counter}'.padLeft(2, '0');

      template.add(number);

      if (counter + 5 > 55) {
        template.add(_newLineDivider.placeholder);
        counter = 0;
      } else {
        if ([10, 40].contains(counter)) {
          template.add(_digitDivider.placeholder);
        } else if (counter == 25) {
          template.add(_middleDivider.placeholder);
        } else {
          template.add(_numberDivider.placeholder);
        }
        counter += 5;
      }
    }
    return template;
  }

  /// Returns list of numbers which should be enabled to display current time.
  List<String> _getEnabledNumbers(String time) {
    if (time == _lastTime && _enabledNumbers != null) {
      return _enabledNumbers;
    }

    final numbers = time.split("");
    _enabledNumbers = <String>[];

    for (var i = 0; i < numbers.length; i++) {
      final number = numbers[i];
      for (var j = 0; j < 15; j++) {
        if (_digitsMap[number] >> j & 1 == 1) {
          _enabledNumbers.add("${j + (i * 15)}".padLeft(2, '0'));
        }
      }
    }
    return _enabledNumbers;
  }

  /// Splits template into [TextSpan]s.
  ///
  /// This allows to set different color for different parts of clock.
  /// Optimized to reduce number of [TextSpan]s by 'grouping'.
  void _createTextSpans({
    @required String time,
    @required String seconds,
    @required ThemeData theme,
  }) {
    final enabledNumbers = _getEnabledNumbers(time);
    final disabledStyle = TextStyle(color: theme.disabledColor);
    final buffer = StringBuffer();
    int currentState;
    int previousState;
    var i = 0;
    _textSpans = [];

    for (var el in _template) {
      // check current state
      if (el == seconds) {
        currentState = 2;
      } else if (enabledNumbers.contains(el)) {
        currentState = 1;
      } else {
        if (el == _numberDivider.placeholder) {
          el = _numberDivider.value;
        } else if (el == _digitDivider.placeholder) {
          el = _digitDivider.value;
        } else if (el == _middleDivider.placeholder) {
          el = _middleDivider.value;
        } else if (el == _newLineDivider.placeholder) {
          el = _newLineDivider.value;
        } else {
          currentState = 0;
        }
        currentState ??= 0;
      }

      // when buffer is not empty
      // and state has changed or current element is last
      if (buffer.isNotEmpty &&
          (currentState != previousState || _template.length - 1 == i)) {
        TextStyle _style;
        if (previousState == 0) {
          _style = disabledStyle;
        } else if (previousState == 1) {
          _style = TextStyle(color: theme.primaryColor);
        } else {
          _style = TextStyle(color: theme.highlightColor);
        }
        _textSpans.add(TextSpan(text: '$buffer', style: _style));
        buffer.clear();
      }

      buffer.write(el);
      previousState = currentState;
      i++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hms().format(_now);

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Numeric clock with time $time',
        value: time,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 75.0),
        color: _theme.backgroundColor,
        child: FittedBox(
          child: Text.rich(
            TextSpan(
              children: _textSpans,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            textAlign: TextAlign.center,
            maxLines: 5,
            //wrapWords: false,
          ),
        ),
      ),
    );
  }
}

class _TextDivider {
  final String placeholder;
  final String value;

  const _TextDivider(this.placeholder, this.value);
}
