import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/date_utils.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/habit_presets.dart';
import '../../shared/widgets/app_bottom_sheet.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/habit_background_card.dart';
import '../../shared/widgets/segmented_control.dart';
import '../../shared/widgets/toast.dart';
import '../today/today_providers.dart';

/// 新建 / 编辑打卡项。
class HabitEditorPage extends ConsumerWidget {
  const HabitEditorPage({super.key, this.habitId});

  final String? habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEdit = habitId != null;
    final habit = isEdit ? ref.watch(habitByIdProvider(habitId!)) : null;

    if (isEdit && habit == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text('未找到该打卡项', style: Theme.of(context).textTheme.bodySmall),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(isEdit ? '编辑项目' : '新建项目'),
      ),
      body: _HabitForm(habit: habit),
    );
  }
}

class _HabitForm extends ConsumerStatefulWidget {
  const _HabitForm({this.habit});

  final Habit? habit;

  @override
  ConsumerState<_HabitForm> createState() => _HabitFormState();
}

class _HabitFormState extends ConsumerState<_HabitForm> {
  late final TextEditingController _name;
  late final TextEditingController _alias;
  late final TextEditingController _goal;
  late final TextEditingController _unit;
  late final TextEditingController _interval;
  late HabitType _type;

  bool get _isEdit => widget.habit != null;

  @override
  void initState() {
    super.initState();
    final habit = widget.habit;
    _name = TextEditingController(text: habit?.name ?? '');
    _alias = TextEditingController(text: habit?.alias ?? '');
    _goal = TextEditingController(text: '${habit?.goal ?? 8}');
    _unit = TextEditingController(text: habit?.unit ?? '杯');
    _interval = TextEditingController(text: '${habit?.intervalDays ?? 180}');
    _type = habit?.type ?? HabitType.active;
  }

  @override
  void dispose() {
    _name.dispose();
    _alias.dispose();
    _goal.dispose();
    _unit.dispose();
    _interval.dispose();
    super.dispose();
  }

  void _applyPreset(HabitPreset preset) {
    setState(() {
      _name.text = preset.name;
      _type = preset.type;
      if (preset.goal != null) _goal.text = '${preset.goal}';
      if (preset.unit != null) _unit.text = preset.unit!;
      if (preset.intervalDays != null) {
        _interval.text = '${preset.intervalDays}';
      }
    });
  }

  Future<void> _save() async {
    final habits = ref.read(habitsProvider).valueOrNull ?? const <Habit>[];
    final name = _name.text.trim();
    if (name.isEmpty) {
      Toast.show(context, '先给项目起个名字');
      return;
    }
    if (name.length > 8) {
      Toast.show(context, '名称最多 8 个字');
      return;
    }
    final duplicated = habits.any(
      (habit) => habit.name == name && habit.id != widget.habit?.id,
    );
    if (duplicated) {
      Toast.show(context, '已经有同名项目了');
      return;
    }

    final now = nowIso();
    final repository = ref.read(habitRepositoryProvider);

    if (_isEdit) {
      final alias = _alias.text.trim();
      final updated = widget.habit!.copyWith(
        name: name,
        alias: alias.isEmpty ? null : alias,
        clearAlias: alias.isEmpty,
        updatedAt: now,
      );
      await repository.save(updated);
      if (!mounted) return;
      Toast.show(context, '已保存');
      context.pop();
      return;
    }

    final sortOrder = habits.isEmpty
        ? 1
        : habits.map((habit) => habit.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    final habit = Habit(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: _type,
      isRequired: false,
      enabled: true,
      sensitive: false,
      sortOrder: sortOrder,
      createdAt: todayYmd(),
      updatedAt: now,
    );

    if (_type == HabitType.meter) {
      final goal = int.tryParse(_goal.text.trim()) ?? 0;
      if (goal < 1 || goal > 9999) {
        Toast.show(context, '每日目标需在 1–9999 之间');
        return;
      }
      final unit = _unit.text.trim();
      await repository.save(habit.copyWith(
        goal: goal,
        unit: unit.isEmpty ? '次' : unit,
        step: 1,
      ));
    } else if (_type == HabitType.periodic) {
      final interval = int.tryParse(_interval.text.trim()) ?? 0;
      if (interval < 1 || interval > 3650) {
        Toast.show(context, '间隔天数需在 1–3650 之间');
        return;
      }
      await repository.save(habit.copyWith(intervalDays: interval));
    } else {
      await repository.save(habit);
    }

    if (!mounted) return;
    Toast.show(context, '已添加「$name」');
    context.pop();
  }

  Future<void> _delete() async {
    final habit = widget.habit!;
    final keepHistory = await AppBottomSheet.show<bool>(
      context: context,
      title: '删除「${habit.name}」',
      builder: (ctx) => const _DeleteSheet(),
    );
    if (keepHistory == null) return;
    await ref
        .read(habitRepositoryProvider)
        .delete(habit.id, keepHistory: keepHistory);
    if (!mounted) return;
    Toast.show(context, keepHistory ? '已删除，历史记录保留' : '已删除项目与历史');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          _isEdit
              ? '调整名称或别名，修改后立即生效。'
              : '新项目从今天开始计算，之后可以随时在「我的」里调整。',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _name,
          maxLength: 8,
          decoration: const InputDecoration(
            labelText: '项目名称',
            hintText: '如：每天喝 8 杯水',
          ),
        ),
        if (_isEdit) ...[
          const SizedBox(height: 4),
          TextField(
            controller: _alias,
            maxLength: 8,
            decoration: const InputDecoration(
              labelText: '别名',
              hintText: '敏感项隐藏名称后显示，可留空',
            ),
          ),
        ],
        const SizedBox(height: 8),
        if (!_isEdit) ...[
          Text('健康推荐', style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          for (final entry in groupHabitPresets().entries) ...[
            Text(entry.key, style: theme.textTheme.bodySmall),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preset in entry.value)
                  _PresetChip(
                    label: preset.name,
                    selected: _name.text == preset.name,
                    onTap: () => _applyPreset(preset),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Text('打卡方式', style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          SegmentedControl<HabitType>(
            value: _type,
            options: const [
              SegmentedOption(value: HabitType.active, label: '主动'),
              SegmentedOption(value: HabitType.passive, label: '被动'),
              SegmentedOption(value: HabitType.meter, label: '计量'),
              SegmentedOption(value: HabitType.periodic, label: '周期'),
            ],
            onChanged: (value) => setState(() => _type = value),
          ),
          const SizedBox(height: 16),
          if (_type == HabitType.meter)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _goal,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '每日目标'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _unit,
                    maxLength: 2,
                    decoration: const InputDecoration(labelText: '单位'),
                  ),
                ),
              ],
            ),
          if (_type == HabitType.periodic)
            TextField(
              controller: _interval,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '间隔天数'),
            ),
        ] else
          AppCard(
            child: Row(
              children: [
                Text('类型', style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(_type.label, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        if (_isEdit) ...[
          const SizedBox(height: 20),
          HabitBackgroundCard(habit: widget.habit!),
        ],
        const SizedBox(height: 24),
        FilledButton(onPressed: _save, child: Text(_isEdit ? '保存' : '创建')),
        if (_isEdit && !widget.habit!.isRequired) ...[
          const SizedBox(height: 10),
          TextButton(
            onPressed: _delete,
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('删除项目'),
          ),
        ],
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _DeleteSheet extends StatefulWidget {
  const _DeleteSheet();

  @override
  State<_DeleteSheet> createState() => _DeleteSheetState();
}

class _DeleteSheetState extends State<_DeleteSheet> {
  bool _keepHistory = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '删除后项目不再出现在列表中。历史记录可选择保留或一并删除。',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('保留历史记录'),
          subtitle: const Text('关闭后同时删除该项目的全部记录'),
          value: _keepHistory,
          onChanged: (value) => setState(() => _keepHistory = value),
        ),
        const SizedBox(height: 12),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
          ),
          onPressed: () => Navigator.of(context).pop(_keepHistory),
          child: const Text('确认删除'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ],
    );
  }
}
