import 'package:flutter/foundation.dart';

// Web uses JS; non-web (Android/iOS/etc) is a no-op.
import 'set_chatbot_enabled_nonweb_impl.dart'
    if (dart.library.html) 'set_chatbot_enabled_web_impl.dart';

export 'set_chatbot_enabled_nonweb_impl.dart'
    if (dart.library.html) 'set_chatbot_enabled_web_impl.dart';


