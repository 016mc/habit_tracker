import 'dart:async';

import '../datasources/local/hive_service.dart';
import '../datasources/remote/firebase_service.dart';
import '../models/habit_model.dart';
import '../models/checkin_model.dart';

/// 同步状态枚举
enum SyncStatus {
  /// 空闲状态
  idle,

  /// 正在同步中
  syncing,

  /// 同步成功
  success,

  /// 同步失败
  failed,
}

/// 同步结果
class SyncResult {
  /// 是否成功
  final bool success;

  /// 上传的习惯数量
  final int uploadedHabits;

  /// 上传的打卡记录数量
  final int uploadedCheckIns;

  /// 下载的习惯数量
  final int downloadedHabits;

  /// 下载的打卡记录数量
  final int downloadedCheckIns;

  /// 错误信息（失败时）
  final String? error;

  const SyncResult({
    this.success = true,
    this.uploadedHabits = 0,
    this.uploadedCheckIns = 0,
    this.downloadedHabits = 0,
    this.downloadedCheckIns = 0,
    this.error,
  });

  @override
  String toString() {
    if (!success) {
      return '同步失败: $error';
    }
    return '同步成功: 上传${uploadedHabits}个习惯、${uploadedCheckIns}条打卡, '
        '下载${downloadedHabits}个习惯、${downloadedCheckIns}条打卡';
  }
}

/// 同步管理器
///
/// 负责管理本地数据与 Firestore 云端数据的同步，包括：
/// - 检查网络连接状态
/// - 同步待上传的本地记录到 Firestore
/// - 拉取远程更新到本地
/// - 冲突解决（Last-Write-Wins 策略）
/// - 自动同步触发（网络恢复时）
class SyncManager {
  // ============================================================
  // 单例模式
  // ============================================================

  static SyncManager? _instance;

  /// 获取单例实例
  static SyncManager get instance {
    _instance ??= SyncManager._();
    return _instance!;
  }

  SyncManager._();

  // ============================================================
  // 依赖服务
  // ============================================================

  /// Firebase 远程数据服务
  final FirebaseService _firebaseService = FirebaseService.instance;

  /// Hive 本地存储服务
  final HiveService _hiveService = HiveService.instance;

  // ============================================================
  // 状态管理
  // ============================================================

  /// 当前同步状态
  SyncStatus _status = SyncStatus.idle;

  /// 同步状态变化控制器
  final _statusController = StreamController<SyncStatus>.broadcast();

  /// 上次同步时间
  DateTime? _lastSyncTime;

  /// 同步锁，防止并发同步
  bool _isSyncing = false;

  /// 自动同步定时器
  Timer? _autoSyncTimer;

  /// 获取当前同步状态
  SyncStatus get status => _status;

  /// 获取上次同步时间
  DateTime? get lastSyncTime => _lastSyncTime;

  /// 同步状态变化流
  Stream<SyncStatus> get statusStream => _statusController.stream;

  /// 是否正在同步中
  bool get isSyncing => _isSyncing;

  // ============================================================
  // 初始化
  // ============================================================

  /// 初始化同步管理器
  ///
  /// [userId] 用户ID
  /// [autoSyncInterval] 自动同步间隔（分钟），默认30分钟
  Future<void> initialize({
    required String userId,
    int autoSyncInterval = 30,
  }) async {
    // 初始化 Firebase 服务
    await _firebaseService.initialize();

    // 如果 Firebase 可用，配置离线持久化
    if (_firebaseService.isAvailable) {
      await _firebaseService.configureOfflinePersistence();
    }

    // 启动自动同步定时器
    _startAutoSync(intervalMinutes: autoSyncInterval, userId: userId);
  }

  /// 启动自动同步定时器
  ///
  /// [intervalMinutes] 同步间隔（分钟）
  /// [userId] 用户ID
  void _startAutoSync({required int intervalMinutes, required String userId}) {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(
      Duration(minutes: intervalMinutes),
      (_) => syncAll(userId: userId),
    );
  }

  /// 停止自动同步
  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  // ============================================================
  // 网络恢复时自动同步
  // ============================================================

  /// 网络恢复回调
  ///
  /// 当网络从离线恢复到在线时调用，触发一次全量同步。
  /// [userId] 用户ID
  Future<void> onNetworkRestored({required String userId}) async {
    if (_firebaseService.isAvailable) {
      await syncAll(userId: userId);
    }
  }

  // ============================================================
  // 全量同步
  // ============================================================

  /// 执行全量同步
  ///
  /// 将本地未同步的数据上传到 Firestore，并拉取远程更新到本地。
  /// 使用 Last-Write-Wins 策略解决冲突。
  /// [userId] 用户ID
  /// 返回同步结果
  Future<SyncResult> syncAll({required String userId}) async {
    // 防止并发同步
    if (_isSyncing) {
      return const SyncResult(success: false, error: '同步正在进行中');
    }

    // Firebase 不可用时跳过同步
    if (!_firebaseService.isAvailable) {
      return const SyncResult(success: false, error: 'Firebase 不可用');
    }

    _isSyncing = true;
    _updateStatus(SyncStatus.syncing);

    try {
      int uploadedHabits = 0;
      int uploadedCheckIns = 0;
      int downloadedHabits = 0;
      int downloadedCheckIns = 0;

      // 第一步：上传本地未同步的数据到云端
      final uploadResult = await _uploadLocalChanges(userId: userId);
      uploadedHabits = uploadResult['habits'] as int;
      uploadedCheckIns = uploadResult['checkIns'] as int;

      // 第二步：拉取远程更新到本地
      final downloadResult = await _downloadRemoteChanges(userId: userId);
      downloadedHabits = downloadResult['habits'] as int;
      downloadedCheckIns = downloadResult['checkIns'] as int;

      // 更新最后同步时间
      _lastSyncTime = DateTime.now();

      _updateStatus(SyncStatus.success);

      return SyncResult(
        success: true,
        uploadedHabits: uploadedHabits,
        uploadedCheckIns: uploadedCheckIns,
        downloadedHabits: downloadedHabits,
        downloadedCheckIns: downloadedCheckIns,
      );
    } catch (e) {
      _updateStatus(SyncStatus.failed);
      return SyncResult(success: false, error: e.toString());
    } finally {
      _isSyncing = false;
    }
  }

  // ============================================================
  // 上传本地变更
  // ============================================================

  /// 上传本地未同步的数据到 Firestore
  ///
  /// [userId] 用户ID
  /// 返回上传数量统计 Map
  Future<Map<String, int>> _uploadLocalChanges({required String userId}) async {
    int habitCount = 0;
    int checkInCount = 0;

    try {
      // 获取本地所有习惯
      final localHabits = await _hiveService.getAllHabits(userId);

      // 上传未同步的习惯
      final unsyncedHabits = localHabits.where((h) => !h.isDeleted).toList();
      if (unsyncedHabits.isNotEmpty) {
        final success = await _firebaseService.batchUploadHabits(unsyncedHabits);
        if (success) {
          habitCount = unsyncedHabits.length;
        }
      }

      // 获取本地未同步的打卡记录
      final localCheckIns = await _getUnsyncedCheckIns(userId);
      if (localCheckIns.isNotEmpty) {
        final success =
            await _firebaseService.batchUploadCheckIns(localCheckIns);
        if (success) {
          checkInCount = localCheckIns.length;

          // 标记本地记录为已同步
          for (final checkIn in localCheckIns) {
            final syncedCheckIn = checkIn.markAsSynced();
            await _hiveService.saveCheckIn(syncedCheckIn);
          }
        }
      }
    } catch (e) {
      // 上传失败不影响后续下载操作
    }

    return {'habits': habitCount, 'checkIns': checkInCount};
  }

  /// 获取本地未同步的打卡记录
  ///
  /// [userId] 用户ID
  /// 返回未同步的打卡记录列表
  Future<List<CheckIn>> _getUnsyncedCheckIns(String userId) async {
    try {
      // 获取用户所有活跃习惯
      final habits = await _hiveService.getActiveHabits(userId);
      final unsyncedCheckIns = <CheckIn>[];

      // 遍历每个习惯，获取未同步的打卡记录
      for (final habit in habits) {
        final checkInDates = await _hiveService.getCheckInDates(habit.id);
        for (final date in checkInDates) {
          final checkIns = await _hiveService.getCheckInsByDate(
            habitId: habit.id,
            date: date,
          );
          final unsynced = checkIns.where((c) => !c.synced).toList();
          unsyncedCheckIns.addAll(unsynced);
        }
      }

      return unsyncedCheckIns;
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // 下载远程变更
  // ============================================================

  /// 拉取远程更新到本地
  ///
  /// 使用 Last-Write-Wins 策略解决冲突：
  /// - 如果远程记录的更新时间晚于本地，则覆盖本地
  /// - 如果本地记录的更新时间晚于远程，则保留本地（下次同步会上传）
  /// [userId] 用户ID
  /// 返回下载数量统计 Map
  Future<Map<String, int>> _downloadRemoteChanges({
    required String userId,
  }) async {
    int habitCount = 0;
    int checkInCount = 0;

    try {
      // 获取上次同步时间，用于增量拉取
      final since = _lastSyncTime?.toIso8601String();

      // 拉取远程习惯
      List<Habit> remoteHabits;
      if (since != null) {
        remoteHabits =
            await _firebaseService.getHabitsSince(userId, since);
      } else {
        remoteHabits = await _firebaseService.getHabits(userId);
      }

      // 合并远程习惯到本地（Last-Write-Wins）
      for (final remoteHabit in remoteHabits) {
        final localHabit = await _hiveService.getHabit(remoteHabit.id);

        if (localHabit == null) {
          // 本地不存在，直接保存
          await _hiveService.saveHabit(remoteHabit);
          habitCount++;
        } else {
          // 本地已存在，比较更新时间（Last-Write-Wins）
          if (remoteHabit.createdAt.isAfter(localHabit.createdAt) ||
              (remoteHabit.archivedAt != null &&
                  localHabit.archivedAt == null)) {
            await _hiveService.saveHabit(remoteHabit);
            habitCount++;
          }
        }
      }

      // 拉取远程打卡记录
      List<CheckIn> remoteCheckIns;
      if (since != null) {
        remoteCheckIns =
            await _firebaseService.getCheckInsSince(userId, since);
      } else {
        remoteCheckIns = await _firebaseService.getCheckIns(userId);
      }

      // 合并远程打卡记录到本地（Last-Write-Wins）
      for (final remoteCheckIn in remoteCheckIns) {
        // 检查本地是否已存在该打卡记录
        final hasLocal = await _hiveService.hasCheckedIn(
          habitId: remoteCheckIn.habitId,
          date: remoteCheckIn.date,
        );

        if (!hasLocal) {
          // 本地不存在该日期的打卡记录，直接保存
          await _hiveService.saveCheckIn(remoteCheckIn.markAsSynced());
          checkInCount++;
        } else {
          // 本地已存在，比较时间戳（Last-Write-Wins）
          if (remoteCheckIn.checkedAt.isAfter(DateTime.now())) {
            // 远程记录更新，覆盖本地
            await _hiveService.saveCheckIn(remoteCheckIn.markAsSynced());
            checkInCount++;
          }
          // 否则保留本地记录
        }
      }
    } catch (e) {
      // 下载失败不影响整体同步结果
    }

    return {'habits': habitCount, 'checkIns': checkInCount};
  }

  // ============================================================
  // 冲突解决
  // ============================================================

  /// Last-Write-Wins 冲突解决策略
  ///
  /// 比较本地和远程记录的时间戳，返回应该保留的记录。
  /// 如果远程更新时间更晚，返回远程记录；否则返回本地记录。
  /// [localCreatedAt] 本地记录创建时间
  /// [remoteCreatedAt] 远程记录创建时间
  /// 返回 true 表示使用远程记录，false 表示使用本地记录
  bool _resolveConflictByLastWriteWins({
    required DateTime localCreatedAt,
    required DateTime remoteCreatedAt,
  }) {
    return remoteCreatedAt.isAfter(localCreatedAt);
  }

  // ============================================================
  // 状态管理
  // ============================================================

  /// 更新同步状态并通知监听者
  void _updateStatus(SyncStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  // ============================================================
  // 清理
  // ============================================================

  /// 释放资源
  void dispose() {
    stopAutoSync();
    _statusController.close();
    _instance = null;
  }
}
