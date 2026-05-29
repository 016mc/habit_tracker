import 'dart:async';

import 'package:flutter/foundation.dart';

/// 网络连接状态
enum ConnectivityStatus {
  online,
  offline,
  unknown,
}

/// 网络连接状态变化事件
class ConnectivityEvent {
  final ConnectivityStatus status;

  const ConnectivityEvent({
    required this.status,
  });
}

/// 网络连接状态服务（简化版，不依赖 connectivity_plus）
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;
  ConnectivityService._();

  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;
  StreamController<ConnectivityEvent>? _controller;

  ConnectivityStatus get currentStatus => _currentStatus;

  /// 监听网络状态变化
  Stream<ConnectivityEvent> get onConnectivityChanged {
    _controller ??= StreamController<ConnectivityEvent>.broadcast();
    return _controller!.stream;
  }

  /// 检查当前网络状态（简化版：始终返回 online）
  Future<ConnectivityStatus> checkConnectivity() async {
    _currentStatus = ConnectivityStatus.online;
    return _currentStatus;
  }

  /// 释放资源
  void dispose() {
    _controller?.close();
    _controller = null;
  }
}
