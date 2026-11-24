// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $HabitsTable extends Habits with TableInfo<$HabitsTable, HabitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 8,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
    'alias',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRequiredMeta = const VerificationMeta(
    'isRequired',
  );
  @override
  late final GeneratedColumn<int> isRequired = GeneratedColumn<int>(
    'required',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<int> enabled = GeneratedColumn<int>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _targetTimeMeta = const VerificationMeta(
    'targetTime',
  );
  @override
  late final GeneratedColumn<String> targetTime = GeneratedColumn<String>(
    'target_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<int> goal = GeneratedColumn<int>(
    'goal',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepMeta = const VerificationMeta('step');
  @override
  late final GeneratedColumn<int> step = GeneratedColumn<int>(
    'step',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bgPathMeta = const VerificationMeta('bgPath');
  @override
  late final GeneratedColumn<String> bgPath = GeneratedColumn<String>(
    'bg_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sensitiveMeta = const VerificationMeta(
    'sensitive',
  );
  @override
  late final GeneratedColumn<int> sensitive = GeneratedColumn<int>(
    'sensitive',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    alias,
    type,
    isRequired,
    enabled,
    targetTime,
    goal,
    unit,
    step,
    intervalDays,
    bgPath,
    sensitive,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('alias')) {
      context.handle(
        _aliasMeta,
        alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('required')) {
      context.handle(
        _isRequiredMeta,
        isRequired.isAcceptableOrUnknown(data['required']!, _isRequiredMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('target_time')) {
      context.handle(
        _targetTimeMeta,
        targetTime.isAcceptableOrUnknown(data['target_time']!, _targetTimeMeta),
      );
    }
    if (data.containsKey('goal')) {
      context.handle(
        _goalMeta,
        goal.isAcceptableOrUnknown(data['goal']!, _goalMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('step')) {
      context.handle(
        _stepMeta,
        step.isAcceptableOrUnknown(data['step']!, _stepMeta),
      );
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('bg_path')) {
      context.handle(
        _bgPathMeta,
        bgPath.isAcceptableOrUnknown(data['bg_path']!, _bgPathMeta),
      );
    }
    if (data.containsKey('sensitive')) {
      context.handle(
        _sensitiveMeta,
        sensitive.isAcceptableOrUnknown(data['sensitive']!, _sensitiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      alias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      isRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}required'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}enabled'],
      )!,
      targetTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_time'],
      ),
      goal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      step: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step'],
      ),
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      ),
      bgPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bg_path'],
      ),
      sensitive: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sensitive'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class HabitRow extends DataClass implements Insertable<HabitRow> {
  final String id;
  final String name;

  /// 敏感项的对外显示名。
  final String? alias;

  /// `active` / `passive` / `meter` / `periodic`。
  final String type;

  /// 必选项（早睡），不可关闭。
  final int isRequired;
  final int enabled;

  /// 早睡目标时间 `HH:mm`。
  final String? targetTime;

  /// 计量项每日目标。
  final int? goal;

  /// 计量单位。
  final String? unit;

  /// 计量项每次累加值。
  final int? step;

  /// 周期项间隔天数。
  final int? intervalDays;
  final String? bgPath;
  final int sensitive;
  final int sortOrder;

  /// 统计起点，早于该日期不参与统计。
  final String createdAt;
  final String updatedAt;
  const HabitRow({
    required this.id,
    required this.name,
    this.alias,
    required this.type,
    required this.isRequired,
    required this.enabled,
    this.targetTime,
    this.goal,
    this.unit,
    this.step,
    this.intervalDays,
    this.bgPath,
    required this.sensitive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || alias != null) {
      map['alias'] = Variable<String>(alias);
    }
    map['type'] = Variable<String>(type);
    map['required'] = Variable<int>(isRequired);
    map['enabled'] = Variable<int>(enabled);
    if (!nullToAbsent || targetTime != null) {
      map['target_time'] = Variable<String>(targetTime);
    }
    if (!nullToAbsent || goal != null) {
      map['goal'] = Variable<int>(goal);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || step != null) {
      map['step'] = Variable<int>(step);
    }
    if (!nullToAbsent || intervalDays != null) {
      map['interval_days'] = Variable<int>(intervalDays);
    }
    if (!nullToAbsent || bgPath != null) {
      map['bg_path'] = Variable<String>(bgPath);
    }
    map['sensitive'] = Variable<int>(sensitive);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      name: Value(name),
      alias: alias == null && nullToAbsent
          ? const Value.absent()
          : Value(alias),
      type: Value(type),
      isRequired: Value(isRequired),
      enabled: Value(enabled),
      targetTime: targetTime == null && nullToAbsent
          ? const Value.absent()
          : Value(targetTime),
      goal: goal == null && nullToAbsent ? const Value.absent() : Value(goal),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      step: step == null && nullToAbsent ? const Value.absent() : Value(step),
      intervalDays: intervalDays == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalDays),
      bgPath: bgPath == null && nullToAbsent
          ? const Value.absent()
          : Value(bgPath),
      sensitive: Value(sensitive),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory HabitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      alias: serializer.fromJson<String?>(json['alias']),
      type: serializer.fromJson<String>(json['type']),
      isRequired: serializer.fromJson<int>(json['isRequired']),
      enabled: serializer.fromJson<int>(json['enabled']),
      targetTime: serializer.fromJson<String?>(json['targetTime']),
      goal: serializer.fromJson<int?>(json['goal']),
      unit: serializer.fromJson<String?>(json['unit']),
      step: serializer.fromJson<int?>(json['step']),
      intervalDays: serializer.fromJson<int?>(json['intervalDays']),
      bgPath: serializer.fromJson<String?>(json['bgPath']),
      sensitive: serializer.fromJson<int>(json['sensitive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'alias': serializer.toJson<String?>(alias),
      'type': serializer.toJson<String>(type),
      'isRequired': serializer.toJson<int>(isRequired),
      'enabled': serializer.toJson<int>(enabled),
      'targetTime': serializer.toJson<String?>(targetTime),
      'goal': serializer.toJson<int?>(goal),
      'unit': serializer.toJson<String?>(unit),
      'step': serializer.toJson<int?>(step),
      'intervalDays': serializer.toJson<int?>(intervalDays),
      'bgPath': serializer.toJson<String?>(bgPath),
      'sensitive': serializer.toJson<int>(sensitive),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  HabitRow copyWith({
    String? id,
    String? name,
    Value<String?> alias = const Value.absent(),
    String? type,
    int? isRequired,
    int? enabled,
    Value<String?> targetTime = const Value.absent(),
    Value<int?> goal = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    Value<int?> step = const Value.absent(),
    Value<int?> intervalDays = const Value.absent(),
    Value<String?> bgPath = const Value.absent(),
    int? sensitive,
    int? sortOrder,
    String? createdAt,
    String? updatedAt,
  }) => HabitRow(
    id: id ?? this.id,
    name: name ?? this.name,
    alias: alias.present ? alias.value : this.alias,
    type: type ?? this.type,
    isRequired: isRequired ?? this.isRequired,
    enabled: enabled ?? this.enabled,
    targetTime: targetTime.present ? targetTime.value : this.targetTime,
    goal: goal.present ? goal.value : this.goal,
    unit: unit.present ? unit.value : this.unit,
    step: step.present ? step.value : this.step,
    intervalDays: intervalDays.present ? intervalDays.value : this.intervalDays,
    bgPath: bgPath.present ? bgPath.value : this.bgPath,
    sensitive: sensitive ?? this.sensitive,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HabitRow copyWithCompanion(HabitsCompanion data) {
    return HabitRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      alias: data.alias.present ? data.alias.value : this.alias,
      type: data.type.present ? data.type.value : this.type,
      isRequired: data.isRequired.present
          ? data.isRequired.value
          : this.isRequired,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      targetTime: data.targetTime.present
          ? data.targetTime.value
          : this.targetTime,
      goal: data.goal.present ? data.goal.value : this.goal,
      unit: data.unit.present ? data.unit.value : this.unit,
      step: data.step.present ? data.step.value : this.step,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      bgPath: data.bgPath.present ? data.bgPath.value : this.bgPath,
      sensitive: data.sensitive.present ? data.sensitive.value : this.sensitive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('alias: $alias, ')
          ..write('type: $type, ')
          ..write('isRequired: $isRequired, ')
          ..write('enabled: $enabled, ')
          ..write('targetTime: $targetTime, ')
          ..write('goal: $goal, ')
          ..write('unit: $unit, ')
          ..write('step: $step, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('bgPath: $bgPath, ')
          ..write('sensitive: $sensitive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    alias,
    type,
    isRequired,
    enabled,
    targetTime,
    goal,
    unit,
    step,
    intervalDays,
    bgPath,
    sensitive,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.alias == this.alias &&
          other.type == this.type &&
          other.isRequired == this.isRequired &&
          other.enabled == this.enabled &&
          other.targetTime == this.targetTime &&
          other.goal == this.goal &&
          other.unit == this.unit &&
          other.step == this.step &&
          other.intervalDays == this.intervalDays &&
          other.bgPath == this.bgPath &&
          other.sensitive == this.sensitive &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class HabitsCompanion extends UpdateCompanion<HabitRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> alias;
  final Value<String> type;
  final Value<int> isRequired;
  final Value<int> enabled;
  final Value<String?> targetTime;
  final Value<int?> goal;
  final Value<String?> unit;
  final Value<int?> step;
  final Value<int?> intervalDays;
  final Value<String?> bgPath;
  final Value<int> sensitive;
  final Value<int> sortOrder;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.alias = const Value.absent(),
    this.type = const Value.absent(),
    this.isRequired = const Value.absent(),
    this.enabled = const Value.absent(),
    this.targetTime = const Value.absent(),
    this.goal = const Value.absent(),
    this.unit = const Value.absent(),
    this.step = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.bgPath = const Value.absent(),
    this.sensitive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitsCompanion.insert({
    required String id,
    required String name,
    this.alias = const Value.absent(),
    required String type,
    this.isRequired = const Value.absent(),
    this.enabled = const Value.absent(),
    this.targetTime = const Value.absent(),
    this.goal = const Value.absent(),
    this.unit = const Value.absent(),
    this.step = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.bgPath = const Value.absent(),
    this.sensitive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<HabitRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? alias,
    Expression<String>? type,
    Expression<int>? isRequired,
    Expression<int>? enabled,
    Expression<String>? targetTime,
    Expression<int>? goal,
    Expression<String>? unit,
    Expression<int>? step,
    Expression<int>? intervalDays,
    Expression<String>? bgPath,
    Expression<int>? sensitive,
    Expression<int>? sortOrder,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (alias != null) 'alias': alias,
      if (type != null) 'type': type,
      if (isRequired != null) 'required': isRequired,
      if (enabled != null) 'enabled': enabled,
      if (targetTime != null) 'target_time': targetTime,
      if (goal != null) 'goal': goal,
      if (unit != null) 'unit': unit,
      if (step != null) 'step': step,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (bgPath != null) 'bg_path': bgPath,
      if (sensitive != null) 'sensitive': sensitive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? alias,
    Value<String>? type,
    Value<int>? isRequired,
    Value<int>? enabled,
    Value<String?>? targetTime,
    Value<int?>? goal,
    Value<String?>? unit,
    Value<int?>? step,
    Value<int?>? intervalDays,
    Value<String?>? bgPath,
    Value<int>? sensitive,
    Value<int>? sortOrder,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      alias: alias ?? this.alias,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      enabled: enabled ?? this.enabled,
      targetTime: targetTime ?? this.targetTime,
      goal: goal ?? this.goal,
      unit: unit ?? this.unit,
      step: step ?? this.step,
      intervalDays: intervalDays ?? this.intervalDays,
      bgPath: bgPath ?? this.bgPath,
      sensitive: sensitive ?? this.sensitive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isRequired.present) {
      map['required'] = Variable<int>(isRequired.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<int>(enabled.value);
    }
    if (targetTime.present) {
      map['target_time'] = Variable<String>(targetTime.value);
    }
    if (goal.present) {
      map['goal'] = Variable<int>(goal.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (step.present) {
      map['step'] = Variable<int>(step.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (bgPath.present) {
      map['bg_path'] = Variable<String>(bgPath.value);
    }
    if (sensitive.present) {
      map['sensitive'] = Variable<int>(sensitive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('alias: $alias, ')
          ..write('type: $type, ')
          ..write('isRequired: $isRequired, ')
          ..write('enabled: $enabled, ')
          ..write('targetTime: $targetTime, ')
          ..write('goal: $goal, ')
          ..write('unit: $unit, ')
          ..write('step: $step, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('bgPath: $bgPath, ')
          ..write('sensitive: $sensitive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyRecordsTable extends DailyRecords
    with TableInfo<$DailyRecordsTable, DailyRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<String> recordedAt = GeneratedColumn<String>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    date,
    status,
    amount,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'records';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {habitId, date},
  ];
  @override
  DailyRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $DailyRecordsTable createAlias(String alias) {
    return $DailyRecordsTable(attachedDatabase, alias);
  }
}

class DailyRecordRow extends DataClass implements Insertable<DailyRecordRow> {
  final int id;
  final String habitId;

  /// 本地自然日 `YYYY-MM-DD`。
  final String date;

  /// `success` / `fail` / `slip`，计量项为空。
  final String? status;

  /// 计量项当日累计。
  final int? amount;
  final String recordedAt;
  const DailyRecordRow({
    required this.id,
    required this.habitId,
    required this.date,
    this.status,
    this.amount,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<int>(amount);
    }
    map['recorded_at'] = Variable<String>(recordedAt);
    return map;
  }

  DailyRecordsCompanion toCompanion(bool nullToAbsent) {
    return DailyRecordsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      date: Value(date),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      recordedAt: Value(recordedAt),
    );
  }

  factory DailyRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyRecordRow(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      date: serializer.fromJson<String>(json['date']),
      status: serializer.fromJson<String?>(json['status']),
      amount: serializer.fromJson<int?>(json['amount']),
      recordedAt: serializer.fromJson<String>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<String>(habitId),
      'date': serializer.toJson<String>(date),
      'status': serializer.toJson<String?>(status),
      'amount': serializer.toJson<int?>(amount),
      'recordedAt': serializer.toJson<String>(recordedAt),
    };
  }

  DailyRecordRow copyWith({
    int? id,
    String? habitId,
    String? date,
    Value<String?> status = const Value.absent(),
    Value<int?> amount = const Value.absent(),
    String? recordedAt,
  }) => DailyRecordRow(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    date: date ?? this.date,
    status: status.present ? status.value : this.status,
    amount: amount.present ? amount.value : this.amount,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  DailyRecordRow copyWithCompanion(DailyRecordsCompanion data) {
    return DailyRecordRow(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      amount: data.amount.present ? data.amount.value : this.amount,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyRecordRow(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('amount: $amount, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, habitId, date, status, amount, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyRecordRow &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.date == this.date &&
          other.status == this.status &&
          other.amount == this.amount &&
          other.recordedAt == this.recordedAt);
}

class DailyRecordsCompanion extends UpdateCompanion<DailyRecordRow> {
  final Value<int> id;
  final Value<String> habitId;
  final Value<String> date;
  final Value<String?> status;
  final Value<int?> amount;
  final Value<String> recordedAt;
  const DailyRecordsCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.amount = const Value.absent(),
    this.recordedAt = const Value.absent(),
  });
  DailyRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String habitId,
    required String date,
    this.status = const Value.absent(),
    this.amount = const Value.absent(),
    required String recordedAt,
  }) : habitId = Value(habitId),
       date = Value(date),
       recordedAt = Value(recordedAt);
  static Insertable<DailyRecordRow> custom({
    Expression<int>? id,
    Expression<String>? habitId,
    Expression<String>? date,
    Expression<String>? status,
    Expression<int>? amount,
    Expression<String>? recordedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (amount != null) 'amount': amount,
      if (recordedAt != null) 'recorded_at': recordedAt,
    });
  }

  DailyRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? habitId,
    Value<String>? date,
    Value<String?>? status,
    Value<int?>? amount,
    Value<String>? recordedAt,
  }) {
    return DailyRecordsCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<String>(recordedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyRecordsCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('amount: $amount, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _strictModeMeta = const VerificationMeta(
    'strictMode',
  );
  @override
  late final GeneratedColumn<bool> strictMode = GeneratedColumn<bool>(
    'strict_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("strict_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _reminderTimeMeta = const VerificationMeta(
    'reminderTime',
  );
  @override
  late final GeneratedColumn<String> reminderTime = GeneratedColumn<String>(
    'reminder_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('22:45'),
  );
  static const VerificationMeta _hideSensitiveNamesMeta =
      const VerificationMeta('hideSensitiveNames');
  @override
  late final GeneratedColumn<bool> hideSensitiveNames = GeneratedColumn<bool>(
    'hide_sensitive_names',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hide_sensitive_names" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _appLockEnabledMeta = const VerificationMeta(
    'appLockEnabled',
  );
  @override
  late final GeneratedColumn<bool> appLockEnabled = GeneratedColumn<bool>(
    'app_lock_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("app_lock_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('female'),
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('green'),
  );
  static const VerificationMeta _periodEnabledMeta = const VerificationMeta(
    'periodEnabled',
  );
  @override
  late final GeneratedColumn<bool> periodEnabled = GeneratedColumn<bool>(
    'period_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("period_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _periodStartMeta = const VerificationMeta(
    'periodStart',
  );
  @override
  late final GeneratedColumn<String> periodStart = GeneratedColumn<String>(
    'period_start',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _periodLengthMeta = const VerificationMeta(
    'periodLength',
  );
  @override
  late final GeneratedColumn<int> periodLength = GeneratedColumn<int>(
    'period_length',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _cycleLengthMeta = const VerificationMeta(
    'cycleLength',
  );
  @override
  late final GeneratedColumn<int> cycleLength = GeneratedColumn<int>(
    'cycle_length',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(28),
  );
  static const VerificationMeta _periodicReminderEnabledMeta =
      const VerificationMeta('periodicReminderEnabled');
  @override
  late final GeneratedColumn<bool> periodicReminderEnabled =
      GeneratedColumn<bool>(
        'periodic_reminder_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("periodic_reminder_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    strictMode,
    reminderEnabled,
    reminderTime,
    hideSensitiveNames,
    appLockEnabled,
    pinHash,
    gender,
    theme,
    periodEnabled,
    periodStart,
    periodLength,
    cycleLength,
    periodicReminderEnabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('strict_mode')) {
      context.handle(
        _strictModeMeta,
        strictMode.isAcceptableOrUnknown(data['strict_mode']!, _strictModeMeta),
      );
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
        _reminderTimeMeta,
        reminderTime.isAcceptableOrUnknown(
          data['reminder_time']!,
          _reminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('hide_sensitive_names')) {
      context.handle(
        _hideSensitiveNamesMeta,
        hideSensitiveNames.isAcceptableOrUnknown(
          data['hide_sensitive_names']!,
          _hideSensitiveNamesMeta,
        ),
      );
    }
    if (data.containsKey('app_lock_enabled')) {
      context.handle(
        _appLockEnabledMeta,
        appLockEnabled.isAcceptableOrUnknown(
          data['app_lock_enabled']!,
          _appLockEnabledMeta,
        ),
      );
    }
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    }
    if (data.containsKey('period_enabled')) {
      context.handle(
        _periodEnabledMeta,
        periodEnabled.isAcceptableOrUnknown(
          data['period_enabled']!,
          _periodEnabledMeta,
        ),
      );
    }
    if (data.containsKey('period_start')) {
      context.handle(
        _periodStartMeta,
        periodStart.isAcceptableOrUnknown(
          data['period_start']!,
          _periodStartMeta,
        ),
      );
    }
    if (data.containsKey('period_length')) {
      context.handle(
        _periodLengthMeta,
        periodLength.isAcceptableOrUnknown(
          data['period_length']!,
          _periodLengthMeta,
        ),
      );
    }
    if (data.containsKey('cycle_length')) {
      context.handle(
        _cycleLengthMeta,
        cycleLength.isAcceptableOrUnknown(
          data['cycle_length']!,
          _cycleLengthMeta,
        ),
      );
    }
    if (data.containsKey('periodic_reminder_enabled')) {
      context.handle(
        _periodicReminderEnabledMeta,
        periodicReminderEnabled.isAcceptableOrUnknown(
          data['periodic_reminder_enabled']!,
          _periodicReminderEnabledMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      strictMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}strict_mode'],
      )!,
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      reminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_time'],
      )!,
      hideSensitiveNames: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hide_sensitive_names'],
      )!,
      appLockEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}app_lock_enabled'],
      )!,
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme'],
      )!,
      periodEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}period_enabled'],
      )!,
      periodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_start'],
      ),
      periodLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_length'],
      )!,
      cycleLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_length'],
      )!,
      periodicReminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}periodic_reminder_enabled'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingsRow extends DataClass implements Insertable<AppSettingsRow> {
  final int id;
  final bool strictMode;
  final bool reminderEnabled;
  final String reminderTime;
  final bool hideSensitiveNames;
  final bool appLockEnabled;

  /// 加盐哈希，不存明文。
  final String? pinHash;
  final String gender;

  /// `green` / `blue` / `pink`。
  final String theme;
  final bool periodEnabled;
  final String? periodStart;
  final int periodLength;
  final int cycleLength;

  /// 周期项到期当天的一次性提醒开关。
  final bool periodicReminderEnabled;
  const AppSettingsRow({
    required this.id,
    required this.strictMode,
    required this.reminderEnabled,
    required this.reminderTime,
    required this.hideSensitiveNames,
    required this.appLockEnabled,
    this.pinHash,
    required this.gender,
    required this.theme,
    required this.periodEnabled,
    this.periodStart,
    required this.periodLength,
    required this.cycleLength,
    required this.periodicReminderEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['strict_mode'] = Variable<bool>(strictMode);
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    map['reminder_time'] = Variable<String>(reminderTime);
    map['hide_sensitive_names'] = Variable<bool>(hideSensitiveNames);
    map['app_lock_enabled'] = Variable<bool>(appLockEnabled);
    if (!nullToAbsent || pinHash != null) {
      map['pin_hash'] = Variable<String>(pinHash);
    }
    map['gender'] = Variable<String>(gender);
    map['theme'] = Variable<String>(theme);
    map['period_enabled'] = Variable<bool>(periodEnabled);
    if (!nullToAbsent || periodStart != null) {
      map['period_start'] = Variable<String>(periodStart);
    }
    map['period_length'] = Variable<int>(periodLength);
    map['cycle_length'] = Variable<int>(cycleLength);
    map['periodic_reminder_enabled'] = Variable<bool>(periodicReminderEnabled);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      strictMode: Value(strictMode),
      reminderEnabled: Value(reminderEnabled),
      reminderTime: Value(reminderTime),
      hideSensitiveNames: Value(hideSensitiveNames),
      appLockEnabled: Value(appLockEnabled),
      pinHash: pinHash == null && nullToAbsent
          ? const Value.absent()
          : Value(pinHash),
      gender: Value(gender),
      theme: Value(theme),
      periodEnabled: Value(periodEnabled),
      periodStart: periodStart == null && nullToAbsent
          ? const Value.absent()
          : Value(periodStart),
      periodLength: Value(periodLength),
      cycleLength: Value(cycleLength),
      periodicReminderEnabled: Value(periodicReminderEnabled),
    );
  }

  factory AppSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      strictMode: serializer.fromJson<bool>(json['strictMode']),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      reminderTime: serializer.fromJson<String>(json['reminderTime']),
      hideSensitiveNames: serializer.fromJson<bool>(json['hideSensitiveNames']),
      appLockEnabled: serializer.fromJson<bool>(json['appLockEnabled']),
      pinHash: serializer.fromJson<String?>(json['pinHash']),
      gender: serializer.fromJson<String>(json['gender']),
      theme: serializer.fromJson<String>(json['theme']),
      periodEnabled: serializer.fromJson<bool>(json['periodEnabled']),
      periodStart: serializer.fromJson<String?>(json['periodStart']),
      periodLength: serializer.fromJson<int>(json['periodLength']),
      cycleLength: serializer.fromJson<int>(json['cycleLength']),
      periodicReminderEnabled: serializer.fromJson<bool>(
        json['periodicReminderEnabled'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'strictMode': serializer.toJson<bool>(strictMode),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'reminderTime': serializer.toJson<String>(reminderTime),
      'hideSensitiveNames': serializer.toJson<bool>(hideSensitiveNames),
      'appLockEnabled': serializer.toJson<bool>(appLockEnabled),
      'pinHash': serializer.toJson<String?>(pinHash),
      'gender': serializer.toJson<String>(gender),
      'theme': serializer.toJson<String>(theme),
      'periodEnabled': serializer.toJson<bool>(periodEnabled),
      'periodStart': serializer.toJson<String?>(periodStart),
      'periodLength': serializer.toJson<int>(periodLength),
      'cycleLength': serializer.toJson<int>(cycleLength),
      'periodicReminderEnabled': serializer.toJson<bool>(
        periodicReminderEnabled,
      ),
    };
  }

  AppSettingsRow copyWith({
    int? id,
    bool? strictMode,
    bool? reminderEnabled,
    String? reminderTime,
    bool? hideSensitiveNames,
    bool? appLockEnabled,
    Value<String?> pinHash = const Value.absent(),
    String? gender,
    String? theme,
    bool? periodEnabled,
    Value<String?> periodStart = const Value.absent(),
    int? periodLength,
    int? cycleLength,
    bool? periodicReminderEnabled,
  }) => AppSettingsRow(
    id: id ?? this.id,
    strictMode: strictMode ?? this.strictMode,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderTime: reminderTime ?? this.reminderTime,
    hideSensitiveNames: hideSensitiveNames ?? this.hideSensitiveNames,
    appLockEnabled: appLockEnabled ?? this.appLockEnabled,
    pinHash: pinHash.present ? pinHash.value : this.pinHash,
    gender: gender ?? this.gender,
    theme: theme ?? this.theme,
    periodEnabled: periodEnabled ?? this.periodEnabled,
    periodStart: periodStart.present ? periodStart.value : this.periodStart,
    periodLength: periodLength ?? this.periodLength,
    cycleLength: cycleLength ?? this.cycleLength,
    periodicReminderEnabled:
        periodicReminderEnabled ?? this.periodicReminderEnabled,
  );
  AppSettingsRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      strictMode: data.strictMode.present
          ? data.strictMode.value
          : this.strictMode,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      hideSensitiveNames: data.hideSensitiveNames.present
          ? data.hideSensitiveNames.value
          : this.hideSensitiveNames,
      appLockEnabled: data.appLockEnabled.present
          ? data.appLockEnabled.value
          : this.appLockEnabled,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      gender: data.gender.present ? data.gender.value : this.gender,
      theme: data.theme.present ? data.theme.value : this.theme,
      periodEnabled: data.periodEnabled.present
          ? data.periodEnabled.value
          : this.periodEnabled,
      periodStart: data.periodStart.present
          ? data.periodStart.value
          : this.periodStart,
      periodLength: data.periodLength.present
          ? data.periodLength.value
          : this.periodLength,
      cycleLength: data.cycleLength.present
          ? data.cycleLength.value
          : this.cycleLength,
      periodicReminderEnabled: data.periodicReminderEnabled.present
          ? data.periodicReminderEnabled.value
          : this.periodicReminderEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('id: $id, ')
          ..write('strictMode: $strictMode, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('hideSensitiveNames: $hideSensitiveNames, ')
          ..write('appLockEnabled: $appLockEnabled, ')
          ..write('pinHash: $pinHash, ')
          ..write('gender: $gender, ')
          ..write('theme: $theme, ')
          ..write('periodEnabled: $periodEnabled, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodLength: $periodLength, ')
          ..write('cycleLength: $cycleLength, ')
          ..write('periodicReminderEnabled: $periodicReminderEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    strictMode,
    reminderEnabled,
    reminderTime,
    hideSensitiveNames,
    appLockEnabled,
    pinHash,
    gender,
    theme,
    periodEnabled,
    periodStart,
    periodLength,
    cycleLength,
    periodicReminderEnabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.id == this.id &&
          other.strictMode == this.strictMode &&
          other.reminderEnabled == this.reminderEnabled &&
          other.reminderTime == this.reminderTime &&
          other.hideSensitiveNames == this.hideSensitiveNames &&
          other.appLockEnabled == this.appLockEnabled &&
          other.pinHash == this.pinHash &&
          other.gender == this.gender &&
          other.theme == this.theme &&
          other.periodEnabled == this.periodEnabled &&
          other.periodStart == this.periodStart &&
          other.periodLength == this.periodLength &&
          other.cycleLength == this.cycleLength &&
          other.periodicReminderEnabled == this.periodicReminderEnabled);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<int> id;
  final Value<bool> strictMode;
  final Value<bool> reminderEnabled;
  final Value<String> reminderTime;
  final Value<bool> hideSensitiveNames;
  final Value<bool> appLockEnabled;
  final Value<String?> pinHash;
  final Value<String> gender;
  final Value<String> theme;
  final Value<bool> periodEnabled;
  final Value<String?> periodStart;
  final Value<int> periodLength;
  final Value<int> cycleLength;
  final Value<bool> periodicReminderEnabled;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.strictMode = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.hideSensitiveNames = const Value.absent(),
    this.appLockEnabled = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.gender = const Value.absent(),
    this.theme = const Value.absent(),
    this.periodEnabled = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodLength = const Value.absent(),
    this.cycleLength = const Value.absent(),
    this.periodicReminderEnabled = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.strictMode = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.hideSensitiveNames = const Value.absent(),
    this.appLockEnabled = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.gender = const Value.absent(),
    this.theme = const Value.absent(),
    this.periodEnabled = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodLength = const Value.absent(),
    this.cycleLength = const Value.absent(),
    this.periodicReminderEnabled = const Value.absent(),
  });
  static Insertable<AppSettingsRow> custom({
    Expression<int>? id,
    Expression<bool>? strictMode,
    Expression<bool>? reminderEnabled,
    Expression<String>? reminderTime,
    Expression<bool>? hideSensitiveNames,
    Expression<bool>? appLockEnabled,
    Expression<String>? pinHash,
    Expression<String>? gender,
    Expression<String>? theme,
    Expression<bool>? periodEnabled,
    Expression<String>? periodStart,
    Expression<int>? periodLength,
    Expression<int>? cycleLength,
    Expression<bool>? periodicReminderEnabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (strictMode != null) 'strict_mode': strictMode,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (hideSensitiveNames != null)
        'hide_sensitive_names': hideSensitiveNames,
      if (appLockEnabled != null) 'app_lock_enabled': appLockEnabled,
      if (pinHash != null) 'pin_hash': pinHash,
      if (gender != null) 'gender': gender,
      if (theme != null) 'theme': theme,
      if (periodEnabled != null) 'period_enabled': periodEnabled,
      if (periodStart != null) 'period_start': periodStart,
      if (periodLength != null) 'period_length': periodLength,
      if (cycleLength != null) 'cycle_length': cycleLength,
      if (periodicReminderEnabled != null)
        'periodic_reminder_enabled': periodicReminderEnabled,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? strictMode,
    Value<bool>? reminderEnabled,
    Value<String>? reminderTime,
    Value<bool>? hideSensitiveNames,
    Value<bool>? appLockEnabled,
    Value<String?>? pinHash,
    Value<String>? gender,
    Value<String>? theme,
    Value<bool>? periodEnabled,
    Value<String?>? periodStart,
    Value<int>? periodLength,
    Value<int>? cycleLength,
    Value<bool>? periodicReminderEnabled,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      strictMode: strictMode ?? this.strictMode,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      hideSensitiveNames: hideSensitiveNames ?? this.hideSensitiveNames,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      pinHash: pinHash ?? this.pinHash,
      gender: gender ?? this.gender,
      theme: theme ?? this.theme,
      periodEnabled: periodEnabled ?? this.periodEnabled,
      periodStart: periodStart ?? this.periodStart,
      periodLength: periodLength ?? this.periodLength,
      cycleLength: cycleLength ?? this.cycleLength,
      periodicReminderEnabled:
          periodicReminderEnabled ?? this.periodicReminderEnabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (strictMode.present) {
      map['strict_mode'] = Variable<bool>(strictMode.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<String>(reminderTime.value);
    }
    if (hideSensitiveNames.present) {
      map['hide_sensitive_names'] = Variable<bool>(hideSensitiveNames.value);
    }
    if (appLockEnabled.present) {
      map['app_lock_enabled'] = Variable<bool>(appLockEnabled.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (periodEnabled.present) {
      map['period_enabled'] = Variable<bool>(periodEnabled.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<String>(periodStart.value);
    }
    if (periodLength.present) {
      map['period_length'] = Variable<int>(periodLength.value);
    }
    if (cycleLength.present) {
      map['cycle_length'] = Variable<int>(cycleLength.value);
    }
    if (periodicReminderEnabled.present) {
      map['periodic_reminder_enabled'] = Variable<bool>(
        periodicReminderEnabled.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('strictMode: $strictMode, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('hideSensitiveNames: $hideSensitiveNames, ')
          ..write('appLockEnabled: $appLockEnabled, ')
          ..write('pinHash: $pinHash, ')
          ..write('gender: $gender, ')
          ..write('theme: $theme, ')
          ..write('periodEnabled: $periodEnabled, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodLength: $periodLength, ')
          ..write('cycleLength: $cycleLength, ')
          ..write('periodicReminderEnabled: $periodicReminderEnabled')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $DailyRecordsTable dailyRecords = $DailyRecordsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final HabitDao habitDao = HabitDao(this as AppDatabase);
  late final RecordDao recordDao = RecordDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    habits,
    dailyRecords,
    appSettings,
  ];
}

typedef $$HabitsTableCreateCompanionBuilder = HabitsCompanion Function({
  required String id,
  required String name,
  Value<String?> alias,
  required String type,
  Value<int> isRequired,
  Value<int> enabled,
  Value<String?> targetTime,
  Value<int?> goal,
  Value<String?> unit,
  Value<int?> step,
  Value<int?> intervalDays,
  Value<String?> bgPath,
  Value<int> sensitive,
  Value<int> sortOrder,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$HabitsTableUpdateCompanionBuilder = HabitsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> alias,
  Value<String> type,
  Value<int> isRequired,
  Value<int> enabled,
  Value<String?> targetTime,
  Value<int?> goal,
  Value<String?> unit,
  Value<int?> step,
  Value<int?> intervalDays,
  Value<String?> bgPath,
  Value<int> sensitive,
  Value<int> sortOrder,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

final class $$HabitsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitsTable, HabitRow> {
  $$HabitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DailyRecordsTable, List<DailyRecordRow>>
  _dailyRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dailyRecords,
    aliasName: 'habits__id__records__habit_id',
  );

  $$DailyRecordsTableProcessedTableManager get dailyRecordsRefs {
    final manager = $$DailyRecordsTableTableManager(
      $_db,
      $_db.dailyRecords,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dailyRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isRequired => $composableBuilder(
    column: $table.isRequired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTime => $composableBuilder(
    column: $table.targetTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bgPath => $composableBuilder(
    column: $table.bgPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sensitive => $composableBuilder(
    column: $table.sensitive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dailyRecordsRefs(
    Expression<bool> Function($$DailyRecordsTableFilterComposer f) f,
  ) {
    final $$DailyRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyRecords,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyRecordsTableFilterComposer(
            $db: $db,
            $table: $db.dailyRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isRequired => $composableBuilder(
    column: $table.isRequired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTime => $composableBuilder(
    column: $table.targetTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bgPath => $composableBuilder(
    column: $table.bgPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sensitive => $composableBuilder(
    column: $table.sensitive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get isRequired => $composableBuilder(
    column: $table.isRequired,
    builder: (column) => column,
  );

  GeneratedColumn<int> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get targetTime => $composableBuilder(
    column: $table.targetTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get step =>
      $composableBuilder(column: $table.step, builder: (column) => column);

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bgPath =>
      $composableBuilder(column: $table.bgPath, builder: (column) => column);

  GeneratedColumn<int> get sensitive =>
      $composableBuilder(column: $table.sensitive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> dailyRecordsRefs<T extends Object>(
    Expression<T> Function($$DailyRecordsTableAnnotationComposer a) f,
  ) {
    final $$DailyRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyRecords,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.dailyRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          HabitRow,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (HabitRow, $$HabitsTableReferences),
          HabitRow,
          PrefetchHooks Function({bool dailyRecordsRefs})
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> alias = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> isRequired = const Value.absent(),
                Value<int> enabled = const Value.absent(),
                Value<String?> targetTime = const Value.absent(),
                Value<int?> goal = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<int?> step = const Value.absent(),
                Value<int?> intervalDays = const Value.absent(),
                Value<String?> bgPath = const Value.absent(),
                Value<int> sensitive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                name: name,
                alias: alias,
                type: type,
                isRequired: isRequired,
                enabled: enabled,
                targetTime: targetTime,
                goal: goal,
                unit: unit,
                step: step,
                intervalDays: intervalDays,
                bgPath: bgPath,
                sensitive: sensitive,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> alias = const Value.absent(),
                required String type,
                Value<int> isRequired = const Value.absent(),
                Value<int> enabled = const Value.absent(),
                Value<String?> targetTime = const Value.absent(),
                Value<int?> goal = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<int?> step = const Value.absent(),
                Value<int?> intervalDays = const Value.absent(),
                Value<String?> bgPath = const Value.absent(),
                Value<int> sensitive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                name: name,
                alias: alias,
                type: type,
                isRequired: isRequired,
                enabled: enabled,
                targetTime: targetTime,
                goal: goal,
                unit: unit,
                step: step,
                intervalDays: intervalDays,
                bgPath: bgPath,
                sensitive: sensitive,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitsTable, HabitRow>(table),
                  $$HabitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dailyRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (dailyRecordsRefs) db.dailyRecords],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dailyRecordsRefs)
                    await $_getPrefetchedDataByColumns<
                      HabitRow,
                      $HabitsTable,
                      DailyRecordRow,
                      $DailyRecordsTable
                    >(
                      currentTable: table,
                      referencedTable: $$HabitsTableReferences
                          ._dailyRecordsRefsTable(db),
                      managerFromTypedResult: (p0) => $$HabitsTableReferences(
                        db,
                        table,
                        p0,
                      ).dailyRecordsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'habit_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      HabitRow,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (HabitRow, $$HabitsTableReferences),
      HabitRow,
      PrefetchHooks Function({bool dailyRecordsRefs})
    >;
typedef $$DailyRecordsTableCreateCompanionBuilder =
    DailyRecordsCompanion Function({
      Value<int> id,
      required String habitId,
      required String date,
      Value<String?> status,
      Value<int?> amount,
      required String recordedAt,
    });
typedef $$DailyRecordsTableUpdateCompanionBuilder =
    DailyRecordsCompanion Function({
      Value<int> id,
      Value<String> habitId,
      Value<String> date,
      Value<String?> status,
      Value<int?> amount,
      Value<String> recordedAt,
    });

final class $$DailyRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $DailyRecordsTable, DailyRecordRow> {
  $$DailyRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HabitsTable _habitIdTable(_$AppDatabase db) =>
      db.habits.createAlias('records__habit_id__habits__id');

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<String>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DailyRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyRecordsTable> {
  $$DailyRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyRecordsTable> {
  $$DailyRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyRecordsTable> {
  $$DailyRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyRecordsTable,
          DailyRecordRow,
          $$DailyRecordsTableFilterComposer,
          $$DailyRecordsTableOrderingComposer,
          $$DailyRecordsTableAnnotationComposer,
          $$DailyRecordsTableCreateCompanionBuilder,
          $$DailyRecordsTableUpdateCompanionBuilder,
          (DailyRecordRow, $$DailyRecordsTableReferences),
          DailyRecordRow,
          PrefetchHooks Function({bool habitId})
        > {
  $$DailyRecordsTableTableManager(_$AppDatabase db, $DailyRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<int?> amount = const Value.absent(),
                Value<String> recordedAt = const Value.absent(),
              }) => DailyRecordsCompanion(
                id: id,
                habitId: habitId,
                date: date,
                status: status,
                amount: amount,
                recordedAt: recordedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String habitId,
                required String date,
                Value<String?> status = const Value.absent(),
                Value<int?> amount = const Value.absent(),
                required String recordedAt,
              }) => DailyRecordsCompanion.insert(
                id: id,
                habitId: habitId,
                date: date,
                status: status,
                amount: amount,
                recordedAt: recordedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyRecordsTable, DailyRecordRow>(table),
                  $$DailyRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.habitId,
                        referencedTable: $$DailyRecordsTableReferences
                            ._habitIdTable(db),
                        referencedColumn: $$DailyRecordsTableReferences
                            ._habitIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DailyRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyRecordsTable,
      DailyRecordRow,
      $$DailyRecordsTableFilterComposer,
      $$DailyRecordsTableOrderingComposer,
      $$DailyRecordsTableAnnotationComposer,
      $$DailyRecordsTableCreateCompanionBuilder,
      $$DailyRecordsTableUpdateCompanionBuilder,
      (DailyRecordRow, $$DailyRecordsTableReferences),
      DailyRecordRow,
      PrefetchHooks Function({bool habitId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<bool> strictMode,
      Value<bool> reminderEnabled,
      Value<String> reminderTime,
      Value<bool> hideSensitiveNames,
      Value<bool> appLockEnabled,
      Value<String?> pinHash,
      Value<String> gender,
      Value<String> theme,
      Value<bool> periodEnabled,
      Value<String?> periodStart,
      Value<int> periodLength,
      Value<int> cycleLength,
      Value<bool> periodicReminderEnabled,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<bool> strictMode,
      Value<bool> reminderEnabled,
      Value<String> reminderTime,
      Value<bool> hideSensitiveNames,
      Value<bool> appLockEnabled,
      Value<String?> pinHash,
      Value<String> gender,
      Value<String> theme,
      Value<bool> periodEnabled,
      Value<String?> periodStart,
      Value<int> periodLength,
      Value<int> cycleLength,
      Value<bool> periodicReminderEnabled,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get strictMode => $composableBuilder(
    column: $table.strictMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hideSensitiveNames => $composableBuilder(
    column: $table.hideSensitiveNames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get periodEnabled => $composableBuilder(
    column: $table.periodEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodLength => $composableBuilder(
    column: $table.periodLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cycleLength => $composableBuilder(
    column: $table.cycleLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get periodicReminderEnabled => $composableBuilder(
    column: $table.periodicReminderEnabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get strictMode => $composableBuilder(
    column: $table.strictMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hideSensitiveNames => $composableBuilder(
    column: $table.hideSensitiveNames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get periodEnabled => $composableBuilder(
    column: $table.periodEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodLength => $composableBuilder(
    column: $table.periodLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cycleLength => $composableBuilder(
    column: $table.cycleLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get periodicReminderEnabled => $composableBuilder(
    column: $table.periodicReminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get strictMode => $composableBuilder(
    column: $table.strictMode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hideSensitiveNames => $composableBuilder(
    column: $table.hideSensitiveNames,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<bool> get periodEnabled => $composableBuilder(
    column: $table.periodEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get periodLength => $composableBuilder(
    column: $table.periodLength,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cycleLength => $composableBuilder(
    column: $table.cycleLength,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get periodicReminderEnabled => $composableBuilder(
    column: $table.periodicReminderEnabled,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingsRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingsRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsRow>,
          ),
          AppSettingsRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> strictMode = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<String> reminderTime = const Value.absent(),
                Value<bool> hideSensitiveNames = const Value.absent(),
                Value<bool> appLockEnabled = const Value.absent(),
                Value<String?> pinHash = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<bool> periodEnabled = const Value.absent(),
                Value<String?> periodStart = const Value.absent(),
                Value<int> periodLength = const Value.absent(),
                Value<int> cycleLength = const Value.absent(),
                Value<bool> periodicReminderEnabled = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                strictMode: strictMode,
                reminderEnabled: reminderEnabled,
                reminderTime: reminderTime,
                hideSensitiveNames: hideSensitiveNames,
                appLockEnabled: appLockEnabled,
                pinHash: pinHash,
                gender: gender,
                theme: theme,
                periodEnabled: periodEnabled,
                periodStart: periodStart,
                periodLength: periodLength,
                cycleLength: cycleLength,
                periodicReminderEnabled: periodicReminderEnabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> strictMode = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<String> reminderTime = const Value.absent(),
                Value<bool> hideSensitiveNames = const Value.absent(),
                Value<bool> appLockEnabled = const Value.absent(),
                Value<String?> pinHash = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<bool> periodEnabled = const Value.absent(),
                Value<String?> periodStart = const Value.absent(),
                Value<int> periodLength = const Value.absent(),
                Value<int> cycleLength = const Value.absent(),
                Value<bool> periodicReminderEnabled = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                strictMode: strictMode,
                reminderEnabled: reminderEnabled,
                reminderTime: reminderTime,
                hideSensitiveNames: hideSensitiveNames,
                appLockEnabled: appLockEnabled,
                pinHash: pinHash,
                gender: gender,
                theme: theme,
                periodEnabled: periodEnabled,
                periodStart: periodStart,
                periodLength: periodLength,
                cycleLength: cycleLength,
                periodicReminderEnabled: periodicReminderEnabled,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSettingsRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppSettingsTable,
                    AppSettingsRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingsRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingsRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsRow>,
      ),
      AppSettingsRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$DailyRecordsTableTableManager get dailyRecords =>
      $$DailyRecordsTableTableManager(_db, _db.dailyRecords);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
