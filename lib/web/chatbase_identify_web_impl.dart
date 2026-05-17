import 'dart:js' as js;

Future<void> chatbaseIdentify(String token) async {
  try {
    // Typical Chatbase pattern: window.chatbase('identify', { token })
    if (!js.context.hasProperty('chatbase')) return;

    js.context.callMethod('chatbase', [
      'identify',
      js.JsObject.jsify({'token': token}),
    ]);
  } catch (_) {
    // Never break login flow.
  }
}

