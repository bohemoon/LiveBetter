import '../data/models/models.dart';

/// 健康推荐预设，四组共 25 项，创建项目时一键填充参数。
class HabitPreset {
  const HabitPreset({
    required this.name,
    required this.type,
    required this.group,
    this.goal,
    this.unit,
    this.intervalDays,
  });

  final String name;
  final HabitType type;
  final String group;
  final int? goal;
  final String? unit;
  final int? intervalDays;
}

const List<HabitPreset> kHabitPresets = [
  // 日常（12）
  HabitPreset(name: '早起', type: HabitType.active, group: '日常'),
  HabitPreset(name: '运动', type: HabitType.active, group: '日常'),
  HabitPreset(name: '阅读', type: HabitType.active, group: '日常'),
  HabitPreset(name: '学习', type: HabitType.active, group: '日常'),
  HabitPreset(name: '冥想', type: HabitType.active, group: '日常'),
  HabitPreset(name: '护肤', type: HabitType.active, group: '日常'),
  HabitPreset(name: '拉伸', type: HabitType.active, group: '日常'),
  HabitPreset(name: '泡脚', type: HabitType.active, group: '日常'),
  HabitPreset(name: '防晒', type: HabitType.active, group: '日常'),
  HabitPreset(name: '早晚刷牙', type: HabitType.active, group: '日常'),
  HabitPreset(name: '护眼远眺', type: HabitType.active, group: '日常'),
  HabitPreset(name: '用牙线', type: HabitType.active, group: '日常'),
  // 自律（8）
  HabitPreset(name: '控糖', type: HabitType.passive, group: '自律'),
  HabitPreset(name: '不喝奶茶', type: HabitType.passive, group: '自律'),
  HabitPreset(name: '戒烟', type: HabitType.passive, group: '自律'),
  HabitPreset(name: '戒酒', type: HabitType.passive, group: '自律'),
  HabitPreset(name: '不熬夜', type: HabitType.passive, group: '自律'),
  HabitPreset(name: '不久坐', type: HabitType.passive, group: '自律'),
  HabitPreset(name: '不吃夜宵', type: HabitType.passive, group: '自律'),
  HabitPreset(name: '少喝甜饮', type: HabitType.passive, group: '自律'),
  // 计量（1）
  HabitPreset(
    name: '蔬果份数',
    type: HabitType.meter,
    group: '计量',
    goal: 5,
    unit: '份',
  ),
  // 定期检查（4）
  HabitPreset(
    name: '定期洗牙',
    type: HabitType.periodic,
    group: '定期检查',
    intervalDays: 180,
  ),
  HabitPreset(
    name: '视力检测',
    type: HabitType.periodic,
    group: '定期检查',
    intervalDays: 365,
  ),
  HabitPreset(
    name: '定期体检',
    type: HabitType.periodic,
    group: '定期检查',
    intervalDays: 365,
  ),
  HabitPreset(
    name: '量血压',
    type: HabitType.periodic,
    group: '定期检查',
    intervalDays: 90,
  ),
];

/// 按预设原有顺序分组。
Map<String, List<HabitPreset>> groupHabitPresets() {
  final groups = <String, List<HabitPreset>>{};
  for (final preset in kHabitPresets) {
    groups.putIfAbsent(preset.group, () => []).add(preset);
  }
  return groups;
}
