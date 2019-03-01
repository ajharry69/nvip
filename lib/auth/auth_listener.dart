import 'package:nvip/data_repo/cache_db/user_cache.dart';

enum AuthState { SIGNED_IN, SIGNED_IN_AND_VERIFIED, SIGNED_OUT }

abstract class AuthStateListener {
  void onAuthStateChanged(AuthState state);
}

class AuthStateProvider {
  static final List<AuthStateListener> _subscribers = List<AuthStateListener>();

  static final AuthStateProvider _stateProvider = AuthStateProvider.internal();

  AuthStateProvider.internal() {
//    _subscribers = List<AuthStateListener>();
    initState();
  }

  factory AuthStateProvider() => _stateProvider;

  int getSubscribersCount() => _subscribers.length ?? 0;

  void initState() async {
    var userCache = UserCache();

    bool isVerified = await userCache.isAccountVerified();

    if (isVerified) {
      notify(AuthState.SIGNED_IN_AND_VERIFIED);
    } else {
      await userCache.isSignedIn()
          ? notify(AuthState.SIGNED_IN)
          : notify(AuthState.SIGNED_OUT);
    }
  }

  void notify(AuthState state) => _subscribers.forEach(
      (AuthStateListener listener) => listener.onAuthStateChanged(state));

  void subscribe(AuthStateListener listener) {
    _subscribers.add(listener);
  }

  void unsubscribe(AuthStateListener listener) =>
      _subscribers.forEach((subscriber) {
        if (subscriber == listener) _subscribers.remove(subscriber);
      });

  void unsubscribeAll() => _subscribers.clear();
}
