A flutter package `acceptable` provides `AcceptableStatefulWidget` which glues `Provider`s of `provider` package and `StatefulWidget`.

## Features

- Watch changes of target objects in state objects provided by `Provider`.
- Callback when watching object changes to convert the object to whatever state for UI.

## Getting started

As this package is completely depends on `provider` package, you *must* import the latest version of `provider` first.

Provide whatever state objects with `Provider` or other related classes to descendants.

Then, build `StatefulWidget` using `AcceptableStatefulWidget` instead of `StatefulWidget`  which represents whatever UI using data provided by those objects.

`AcceptableStatefulWidget` can accept that state object and detect its changes, and call `apply` function to convert the object to state for UI. 

## Usage

Thinking of implementing "Counter App" whose count is managed by `CounterState` which extends `ValueNotifier`, you can implement `MultipleCounter` which build `Text` displaying multiplied value of count like below.

```dart
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
    return Text('$_value');
  }
}
```

Most important method is `acceptProviders` which is called right before `build` is called at the first time.

`acceptProviders` passes `accept` function as an argument. You can call `accept` with two arguments of function.

### watch
`watch` returns what object to watch. In the example above, `MultipleCounter` observes `state.value`: `state` is an instance of `CounterState`. 

This method is quite similar to `context.select<Value, T>()` of `provider` package.

### apply
`apply` represents how to apply provided data, which is decided by calling `watch`, to the state of UI. 

In the example above, `value` is doubled and assigned to `_value` field of State. Then `_value` is used in the `build` method.

As `apply` is called before `build` is called when observing value is changed, you don't need to convert provided value in `build` method. 

## Motivation

By using `AcceptableStatefulWidget` you don't have to

- make state object which represents specific UI, which is typically called `ViewModel`.

and you can

- manage state of the UI in `State` class which totally follows the basic idea of Flutter.
- concentrate on providing data via `Provider` without considering "how it is used" in each UI.