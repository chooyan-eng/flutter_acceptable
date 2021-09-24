import 'package:acceptable/acceptable.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';

class MultipleCounter extends AcceptableStatefulWidget {
  const MultipleCounter({Key? key}) : super(key: key);

  @override
  _MultipleCounterState createState() => _MultipleCounterState();
}

class _MultipleCounterState
    extends AcceptableStatefulWidgetState<MultipleCounter> {
  @override
  void acceptProviders(Accept accept) {
    accept<CounterState, int>(
      watch: (state) => state.value,
      apply: (value) => _value = value * 2,
    );
  }

  late int _value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Twice'),
        Text(
          '$_value',
          style: Theme.of(context).textTheme.headline4,
        ),
      ],
    );
  }
}
