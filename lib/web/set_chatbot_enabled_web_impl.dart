import 'dart:js' as js;

void setChatbotEnabled(bool enabled) {
  // Web: manipulate the global JS function.
  js.context.callMethod('__expensivo_setChatbotEnabled', [enabled]);
}

