// Core - Network connectivity checker interface and implementation.
//
// Provides an abstraction over device connectivity status so that
// repositories can check for internet access before making API calls.
// The implementation uses the `connectivity_plus` package.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

/// Abstract interface for checking network connectivity.
///
/// Depend on this abstraction (not the implementation) to enable
/// easy mocking in tests.
abstract class NetworkInfo {
  /// Returns `true` if the device currently has network connectivity.
  Future<bool> get isConnected;

  /// A broadcast stream that emits `true`/`false` whenever connectivity changes.
  Stream<bool> get onConnectivityChanged;
}

/// Implementation of [NetworkInfo] using `connectivity_plus`.
///
/// Considers Wi-Fi, mobile, ethernet, and VPN as connected states.
/// Only [ConnectivityResult.none] is treated as disconnected.
@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  /// Creates a [NetworkInfoImpl].
  ///
  /// [connectivity] is injected via the DI container.
  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_hasConnection);
  }

  /// Returns `true` if any of the connectivity results indicate an active connection.
  bool _hasConnection(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      return false;
    }
    return results.isNotEmpty;
  }
}