import 'package:acceptable/acceptable.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';

class AppendUnitCounter extends AcceptableStatefulWidget {
  const AppendUnitCounter({Key? key}) : super(key: key);

  @override
  _AppendUnitCounterState createState() => _AppendUnitCounterState();
}

class _AppendUnitCounterState
    extends AcceptableStatefulWidgetState<AppendUnitCounter> {
  late String _value;

  @override
  void acceptProviders(Accept accept) {
    accept<CounterState, int>(
      watch: (state) => state.value,
      apply: (value) => _value = '$value HITS',
      perform: (value) {
        if (value == 10) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text('$value'),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('with Unit'),
        Text(
          _value,
          style: Theme.of(context).textTheme.headline4,
        ),
      ],
    );
  }
}
