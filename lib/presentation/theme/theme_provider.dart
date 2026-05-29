import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题模式枚举
enum AppThemeMode {
  /// 跟随系统
  system,

  /// 浅色模式
  light,

  /// 深色模式
  dark,
}

/// 主题模式扩展方法
extension AppThemeModeExtension on AppThemeMode {
  /// 转换为 Flutter ThemeMode
  ThemeMode toThemeMode() {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  /// 转换为存储用的字符串
  String toStorageString() {
    switch (this) {
      case AppThemeMode.system:
        return 'system';
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
    }
  }

  /// 显示名称
  String get displayName {
    switch (this) {
      case AppThemeMode.system:
        return '跟随系统';
      case AppThemeMode.light:
        return '浅色模式';
      case AppThemeMode.dark:
        return '深色模式';
    }
  }

  /// 图标
  IconData get icon {
    switch (this) {
      case AppThemeMode.system:
        return Icons.brightness_auto;
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
    }
  }
}

/// 主题状态管理
/// 使用 Riverpod 管理主题模式，并通过 SharedPreferences 持久化
class ThemeNotifier extends StateNotifier<AppThemeMode> {
  /// SharedPreferences 存储键名
  static const String _storageKey = 'app_theme_mode';

  /// SharedPreferences 实例（延迟初始化）
  SharedPreferences? _prefs;

  ThemeNotifier() : super(AppThemeMode.system) {
    _initPrefs();
  }

  /// 异步初始化 SharedPreferences
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadThemeMode();
  }

  /// 从本地存储加载主题模式
  void _loadThemeMode() {
    if (_prefs == null) return;
    final storedValue = _prefs!.getString(_storageKey);
    if (storedValue != null) {
      switch (storedValue) {
        case 'light':
          state = AppThemeMode.light;
          break;
        case 'dark':
          state = AppThemeMode.dark;
          break;
        case 'system':
        default:
          state = AppThemeMode.system;
          break;
      }
    }
  }

  /// 切换主题模式
  /// 传入 null 时按 system -> light -> dark 顺序循环切换
  void setThemeMode(AppThemeMode? mode) {
    if (mode != null) {
      state = mode;
    } else {
      // 循环切换：system -> light -> dark -> system
      switch (state) {
        case AppThemeMode.system:
          state = AppThemeMode.light;
          break;
        case AppThemeMode.light:
          state = AppThemeMode.dark;
          break;
        case AppThemeMode.dark:
          state = AppThemeMode.system;
          break;
      }
    }
    _saveThemeMode();
  }

  /// 保存主题模式到本地存储
  Future<void> _saveThemeMode() async {
    await _prefs?.setString(_storageKey, state.toStorageString());
  }
}

/// 主题模式 Provider
/// 监听主题模式变化，自动持久化到 SharedPreferences
final themeModeProvider =
    StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

/// Flutter ThemeMode Provider
/// 将自定义 AppThemeMode 转换为 Flutter 的 ThemeMode
final flutterThemeModeProvider = Provider<ThemeMode>((ref) {
  final appThemeMode = ref.watch(themeModeProvider);
  return appThemeMode.toThemeMode();
});
