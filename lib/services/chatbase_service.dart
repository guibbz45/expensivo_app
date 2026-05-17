import 'package:flutter/foundation.dart';

import '../web/chatbase_identify.dart';

class ChatbaseService {
  static const String _tokenEnvKey = 'CHATBASE_IDENTIFY_TOKEN';

  static Future<void> identifyAfterLogin() async {
    if (!kIsWeb) return;

    final token = const String.fromEnvironment(_tokenEnvKey);
    if (token.isEmpty) return;

    await chatbaseIdentify(token);
  }
}







