import 'package:flutter/foundation.dart';

import 'chatbase_identify_nonweb_impl.dart'
    if (dart.library.html) 'chatbase_identify_web_impl.dart';

// Re-export the single function from the correct implementation.
export 'chatbase_identify_nonweb_impl.dart'
    if (dart.library.html) 'chatbase_identify_web_impl.dart';

