import 'package:evidya/screens/messenger/call_history_screen.dart';
import 'package:flutter/material.dart';

class LogController extends ValueNotifier<List<String>> {
  LogController() : super([]);

  void addLog(
    String log,
  ) {
    value = [...value, log];
  }
}

class CallLogController extends ValueNotifier<List<CallModel>> {
  CallLogController() : super([]);

  void addLog(
    CallModel log,
  ) {
    value = [...value, log];
  }

  void clear() {
    value.clear();
  }
}
