import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

/// 应用程序入口
/// 负责初始化本地数据库并启动应用
void main() async {
  // 确保 Flutter 绑定初始化完成（使用 async 前必须调用）
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Hive 本地数据库
  await Hive.initFlutter();

  // 运行应用，使用 ProviderScope 包裹以提供 Riverpod 状态管理
  runApp(
    const ProviderScope(
      child: HabitTrackerApp(),
    ),
  );
}
