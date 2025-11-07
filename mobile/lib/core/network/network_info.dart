import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mobile/core/utils/logger.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl({required this.connectivity});

  @override
  Future<bool> get isConnected async {
    try {
      final result = await connectivity.checkConnectivity();
      return _isConnectedResult(result);
    } catch (e) {
      AppLogger.e('Error checking connectivity', e);
      return false;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map(_isConnectedResult);
  }

  bool _isConnectedResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        return true;
      case ConnectivityResult.none:
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.vpn:
      case ConnectivityResult.other:
        return false;
    }
  }

  static NetworkInfo create() {
    return NetworkInfoImpl(connectivity: Connectivity());
  }
}