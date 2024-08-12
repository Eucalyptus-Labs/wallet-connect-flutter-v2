import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:walletconnect_flutter_v2/apis/core/connectivity/i_connectivity.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class ConnectivityState implements IConnectivity {
  final ICore _core;
  ConnectivityState({required ICore core}) : _core = core;

  bool _initialized = false;

  bool _isOnline = false;
  @override
  bool get isOnline => _isOnline;

  @override
  Future<void> init() async {
    if (_initialized) return;
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
    Connectivity().onConnectivityChanged.listen(
          _updateConnectionStatus,
        );
    _initialized = true;
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    _core.logger.i('[$runtimeType] Connectivity changed $result');
    final isMobileData = result.contains(ConnectivityResult.mobile);
    final isWifi = result.contains(ConnectivityResult.wifi);

    _isOnline = isMobileData || isWifi;

    if (_isOnline && !_core.relayClient.isConnected) {
      await _core.relayClient.connect();
    } else if (!_isOnline && _core.relayClient.isConnected) {
      await _core.relayClient.disconnect();
    }
  }
}
