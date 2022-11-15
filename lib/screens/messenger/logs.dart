import 'package:evidya/model/chat_model.dart';
import 'package:flutter/material.dart';

class LogController extends ValueNotifier<List<ChatModel>> {
  LogController() : super([]);
  void addLog(ChatModel log) {
    if (value.contains(log)) {
      debugPrint('exists already ${log.toJson()}');
      return;
    }
    value = [
      ...value,
      log,
    ];
    // debugPrint(log);
  }

  // void addGroupLog(String log) {
  //   // value = [
  //   //   ...value,
  //   //   log,
  //   // ];
  //   debugPrint(log);
  // }

  void removeLog(int index) {
    value.removeAt(index);
    value = [...value];
  }

  void clear() {
    value.clear();
  }
}

class GroupLongController extends ValueNotifier<List<ChatModel>> {
  GroupLongController() : super([]);
  void addLog(ChatModel log) {
    if (value.contains(log)) return;
    value = [
      ...value,
      log,
    ];
    // debugPrint(log);
  }

  void addGroupLog(String log) {
    // value = [
    //   ...value,
    //   log,
    // ];
    debugPrint(log);
  }

  void removeLog(int index) {
    value.removeAt(index);
    value = [...value];
  }

  void clear() {
    value.clear();
  }
}

class MessageLog extends ValueNotifier<List<String>> {
  MessageLog() : super([]);
  void addLog(String log) {
    value = [
      ...value,
      log,
    ];
  }

  void removeLog(int index) {
    value.removeAt(index);
    value = [...value];
  }

  clear() {
    value.clear();
  }
}

class GroupMessageLog extends ValueNotifier<List<String>> {
  GroupMessageLog() : super([]);
  void addLog(String log) {
    value = [
      ...value,
      log,
    ];
  }

  void removegroupLog(String groupname) {
    value.removeWhere((item) => item == groupname);
    value = [...value];
  }

  void clear() {
    value.clear();
  }
}

class ClassLog extends ValueNotifier<List<String>> {
  ClassLog() : super([]);
  void addLog(String log) {
    value = [
      ...value,
      log,
    ];
  }

  void removeLog(int index) {
    value.removeAt(index);
    value = [...value];
  }
}
