import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  ToastService._();

  static final _active = <String>{};

  static void show({
    required String key,
    Widget? title,
    Widget? description,
    ToastificationType type = ToastificationType.info,
    Duration duration = const Duration(seconds: 4),
    bool applyBlurEffect = false,
  }) {
    if (_active.contains(key)) return;
    _active.add(key);
    toastification.show(
      title: title,
      description: description,
      type: type,
      applyBlurEffect: applyBlurEffect,
      autoCloseDuration: duration,
      callbacks: ToastificationCallbacks(onDismissed: (_) => _active.remove(key), onAutoCompleteCompleted: (_) => _active.remove(key)),
    );
  }
}
