import 'dart:async';

import 'package:flutter/foundation.dart';

/// Adapter that turns any `Stream` into a `Listenable`, suitable for
/// `GoRouter.refreshListenable`. The router re-evaluates redirects on every
/// emission of the underlying stream.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription =
        stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
