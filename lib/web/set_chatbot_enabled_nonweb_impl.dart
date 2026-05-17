import 'package:flutter/material.dart';

// Global key or value notifier could be used here to manage state globally,
// but for simplicity, we provide a way for the UI to know it should show the button.
final ValueNotifier<bool> chatbotVisibilityNotifier = ValueNotifier<bool>(false);

void setChatbotEnabled(bool enabled) {
  chatbotVisibilityNotifier.value = enabled;
}

