import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Function for detecting an object to observe.
typedef Watch<Value, T> = T Function(Value);

/// Function for applying provided data into state for UI
typedef Apply<T> = void Function(T);

/// Function for performing accepting mechanism.
typedef Accept = void Function<Value, T>(
    {required Watch<Value, T> watch, required Apply<T> apply});

/// Function for testing [Apply] should be called when depencencies change.
typedef ShouldApply<Value> = bool Function(Value);

/// [StatefulWidget] which is extended in order to receive
/// the change of [Value] provided by [Provider] before every rebuild times
/// so that the value can be converted to suitable data for UI.
abstract class AcceptableStatefulWidget extends StatefulWidget {
  const AcceptableStatefulWidget({Key? key}) : super(key: key);

  @override
  StatefulElement createElement() => _AcceptableStatefulElement(this);
}

/// [State] for [AcceptableStatefulWidget].
/// Every subclasses of [AcceptableStatefulWidget] must return an object of
/// [AcceptableStatefulWidgetState] in its [createState].
abstract class AcceptableStatefulWidgetState<T extends AcceptableStatefulWidget>
    extends State<T> {
  /// Preparation for accepting [Value] provided by [Provider].
  /// An object returned by [watch] is a target to observe changes.
  /// [accept] is called when the object returned by [watch] changes.
  ///
  /// {@tool snippet}
  ///
  /// In this example, [_MultipleCounterState] observs the change of [value] of
  /// [CounterState], which extends [ValueNotifier] and provided by [ChangeNotifierProvider].
  /// When [value] is changed, [appyl] is called with [value] as an argument.
  /// [value] is set to [_value] with being mutiplied, and used in [build] method.
  ///
  /// ```dart
  ///class _MultipleCounterState
  ///    extends AcceptableStatefulWidgetState<MultipleCounter> {
  ///  late int _value;
  ///
  ///   @override
  ///   void acceptProviders(Accept accept) {
  ///     accept<CounterState, int>(
  ///       watch: (state) => state.value,
  ///       apply: (value) => _value = value * 2,
  ///     );
  ///   }
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// [accept] can be called multiple times if observing multiple objects is necessary.
  void acceptProviders(Accept accept);
}

class _AcceptableStatefulElement extends StatefulElement {
  _AcceptableStatefulElement(StatefulWidget widget) : super(widget);

  final _applyLogics = <_ApplyLogic>[];
  var _isFirstBuild = true;

  @override
  Widget build() {
    // As watching Provider is allowed only in build(),
    // it is done here only at the first time.
    if (_isFirstBuild) {
      _isFirstBuild = false;
      assert(state is AcceptableStatefulWidgetState);

      final acceptableState = state as AcceptableStatefulWidgetState;
      acceptableState.acceptProviders(<Value, T>({
        required watch,
        required apply,
      }) {
        // depend on Value here to receive its changes.
        final original = watch(Provider.of<Value>(this));
        final shouldApply = (Value newValue) {
          return !const DeepCollectionEquality()
              .equals(watch(newValue), original);
        };

        _applyLogics.add(
          _ApplyLogic<Value, T>(apply, watch, shouldApply)..applyValue(this),
        );
      });
    }

    return super.build();
  }

  @override
  void didChangeDependencies() {
    for (final applyLogic in _applyLogics) {
      if (applyLogic.callShouldApply(this)) {
        applyLogic.applyValue(this);
        applyLogic.updateShouldApply(this);
      }
    }
    super.didChangeDependencies();
  }
}

class _ApplyLogic<Value, T> {
  /// Function for apply given data to UI
  final Apply<T> apply;

  /// Function for select what data of Value to watch.
  final Watch<Value, T> watch;

  /// Function to determin if watching data is changed or not.
  ShouldApply<Value> shouldApply;

  _ApplyLogic(this.apply, this.watch, this.shouldApply);

  bool callShouldApply(BuildContext context) => shouldApply(_read(context));
  void updateShouldApply(BuildContext context) {
    final original = watch(_read(context));
    shouldApply = (Value newValue) {
      return !const DeepCollectionEquality().equals(
        watch(newValue),
        original,
      );
    };
  }

  void applyValue(BuildContext context) => apply(watch(_read(context)));
  Value _read(BuildContext context) => context.read<Value>();
}
