import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';
import '../../models/models.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.attachedDatabase);

  Future<AppSettingsRow?> find() async {
    final query = select(appSettings)..limit(1);
    return query.getSingleOrNull();
  }

  Stream<AppSettingsRow?> watchSingle() {
    final query = select(appSettings)..limit(1);
    return query.watchSingleOrNull();
  }

  Future<void> save(AppSettingsData settings) async {
    await into(appSettings).insertOnConflictUpdate(settings.toCompanion());
  }
}
