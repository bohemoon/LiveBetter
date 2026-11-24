import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:livebetter/core/date_utils.dart';
import 'package:livebetter/data/db/database.dart';
import 'package:livebetter/data/models/models.dart';
import 'package:livebetter/data/repositories/local/local_maintenance_repository.dart';
import 'package:livebetter/domain/stats/habit_stats.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 真机 / 模拟器上的端到端验证：打卡 → 统计 → 重启 → 导出/导入。
/// 运行：`flutter test integration_test/app_flow_test.dart -d <device>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late File dbFile;

  setUp(() async {
    dir = await getApplicationSupportDirectory();
    dbFile = File(p.join(dir.path, 'integration_flow.sqlite'));
    for (final suffix in ['', '-wal', '-shm']) {
      final file = File('${dbFile.path}$suffix');
      if (file.existsSync()) file.deleteSync();
    }
  });

  tearDown(() {
    if (dbFile.existsSync()) dbFile.deleteSync();
  });

  testWidgets('打卡 → 统计 → 重启后数据仍在', (tester) async {
    final today = todayYmd();

    // 1. 真实 SQLite 建库（自动写入默认 5 项）
    var db = AppDatabase(NativeDatabase(dbFile));
    final rows = await db.habitDao.getAll();
    expect(rows.length, 5);

    final sleep = Habit.fromRow(
      rows.firstWhere((row) => row.id == 'sleep_early'),
    );
    expect(sleep.type, HabitType.active);

    // 2. 打卡
    await db.recordDao.upsert(
      DailyRecord(
        habitId: sleep.id,
        date: today,
        status: RecordStatus.success,
        recordedAt: nowIso(),
      ),
    );

    // 3. 统计
    final recordRows = await db.recordDao.byDate(today);
    expect(recordRows.length, 1);
    final stats = computeHabitStats(
      habit: sleep,
      records: recordRows.map(DailyRecord.fromRow).toList(),
      today: today,
      strictMode: false,
    );
    expect(stats.doneToday, isTrue);
    expect(stats.currentStreak, 1);
    expect(stats.totalDays, 1);

    // 4. 关闭并重新打开数据库，模拟应用重启
    await db.close();
    db = AppDatabase(NativeDatabase(dbFile));
    final afterRestart = await db.recordDao.byDate(today);
    expect(afterRestart.length, 1);
    expect(afterRestart.first.status, RecordStatus.success.value);

    // 5. 导出 → 清空 → 导入
    final maintenance = LocalMaintenanceRepository(db);
    final json = await maintenance.exportJson();
    expect(json.contains('"format": "livebetter"'), isTrue);

    await maintenance.clearAllData();
    expect((await db.recordDao.all()).isEmpty, isTrue);

    final summary = await maintenance.importJson(json);
    expect(summary.records, 1);
    final restored = await db.recordDao.byDate(today);
    expect(restored.length, 1);
    expect((await db.habitDao.getAll()).length, 5);

    await db.close();
    await tester.pumpAndSettle();
  });
}
