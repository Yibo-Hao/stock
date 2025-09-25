import 'dart:async';

import 'package:flutter/material.dart';

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;
  Debouncer({required this.milliseconds});
  run(VoidCallback action) {
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

///  Throttling
///  Have method [throttle]
class Throttling {
  Duration _duration;
  Duration get duration => _duration;
  set duration(Duration value) {
    // ignore: unnecessary_type_check
    assert(duration is Duration && !duration.isNegative);
    _duration = value;
  }

  bool _isReady = true;
  // ignore: recursive_getters
  bool get isReady => isReady;
  Future<void> get _waiter => Future.delayed(_duration);
  // ignore: close_sinks
  final StreamController<bool> _stateSC = StreamController<bool>.broadcast();

  Throttling({Duration duration = const Duration(seconds: 1)})
      // ignore: unnecessary_type_check
      : assert(duration is Duration && !duration.isNegative),
        _duration = duration {
    _stateSC.sink.add(true);
  }

  dynamic throttle(Function func) {
    if (!_isReady) return null;
    _stateSC.sink.add(false);
    _isReady = false;
    _waiter.then((_) {
      _isReady = true;
      _stateSC.sink.add(true);
    });
    return Function.apply(func, []);
  }

  StreamSubscription<bool> listen(Function(bool) onData) =>
      _stateSC.stream.listen(onData);

  dispose() {
    _stateSC.close();
  }
}
