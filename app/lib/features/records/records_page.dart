import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/date_utils.dart';
import '../../core/providers.dart';
import '../../domain/stats/records_stats.dart';
import '../../shared/widgets/app_card.dart';
import '../today/today_providers.dart';
import 'records_providers.dart';

/// 记录页：本周稳定度、月度小结、月历色阶与鼓励文案。
class RecordsPage extends ConsumerWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    return Scaffold(
      body: SafeArea(
        child: habits.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              '数据加载失败\n$error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          data: (_) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: const [
              _PageHead(),
              SizedBox(height: 20),
              _StabilityCard(),
              SizedBox(height: 16),
              _MonthSummaryCard(),
              SizedBox(height: 16),
              _CalendarCard(),
              SizedBox(height: 16),
              _CheerCard(),
              SizedBox(height: 12),
              _Hint(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageHead extends StatelessWidget {
  const _PageHead();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('回顾', style: theme.textTheme.bodySmall),
        const SizedBox(height: 6),
        Text('记录', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text('颜色越深，当天坚持的项目越多', style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _StabilityCard extends ConsumerWidget {
  const _StabilityCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final data = ref.watch(weekStabilityProvider);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('本周稳定度', style: theme.textTheme.titleMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data.label,
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 108,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                minY: 0,
                maxY: 1,
                barTouchData: BarTouchData(enabled: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.days.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _weekdayLabel(data.days[index].date),
                            style: theme.textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < data.days.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: data.days[i].ratio < 0.08 ? 0.08 : data.days[i].ratio,
                          width: 10,
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(5),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 1,
                            color: scheme.surfaceContainerHighest,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(data.cheer, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _MonthSummaryCard extends ConsumerWidget {
  const _MonthSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summary = ref.watch(monthSummaryProvider);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('本月小结', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              _SummaryItem(label: '完成项次', value: '${summary.done}'),
              _SummaryItem(label: '全勤天数', value: '${summary.fullDays}'),
              _SummaryItem(label: '在坚持项目', value: '${summary.activeHabits}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(value, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _CalendarCard extends ConsumerWidget {
  const _CalendarCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final summary = ref.watch(monthSummaryProvider);
    final month = ref.watch(recordsMonthProvider);
    final today = ref.watch(todayDateProvider);

    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final canGoNext = month.isBefore(currentMonth);

    final progressByDate = {
      for (final day in summary.days) day.date: day,
    };
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final offset = DateTime(month.year, month.month, 1).weekday - 1;

    final cells = <Widget>[
      for (var i = 0; i < offset; i++) const SizedBox.shrink(),
      for (var day = 1; day <= daysInMonth; day++)
        _DayCell(
          day: day,
          date: formatYmd(DateTime(month.year, month.month, day)),
          today: today,
          progress: progressByDate[
              formatYmd(DateTime(month.year, month.month, day))],
        ),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  ref.read(recordsMonthProvider.notifier).state =
                      DateTime(month.year, month.month - 1);
                },
                icon: const Icon(Icons.chevron_left),
                visualDensity: VisualDensity.compact,
                tooltip: '上个月',
              ),
              Expanded(
                child: Text(
                  DateFormat('yyyy年M月').format(month),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: canGoNext
                    ? () {
                        ref.read(recordsMonthProvider.notifier).state =
                            DateTime(month.year, month.month + 1);
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
                visualDensity: VisualDensity.compact,
                tooltip: '下个月',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final label in _weekdays)
                Expanded(
                  child: Center(
                    child: Text(label, style: theme.textTheme.bodySmall),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1,
            children: cells,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('少', style: theme.textTheme.bodySmall),
              const SizedBox(width: 6),
              for (var level = 1; level <= 4; level++) ...[
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: _levelColor(level, scheme),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              const SizedBox(width: 0),
              Text('多', style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.date,
    required this.today,
    required this.progress,
  });

  final int day;
  final String date;
  final String today;
  final DayProgress? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isFuture = date.compareTo(today) > 0;
    final isToday = date == today;

    Color? background;
    Color? textColor;
    if (isFuture) {
      background = null;
      textColor = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4);
    } else if (progress == null || !progress!.hasData) {
      background = null;
      textColor = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7);
    } else {
      final level = progress!.level;
      background = _levelColor(level, scheme);
      if (level >= 4) {
        textColor = Colors.white;
      } else if (level >= 3) {
        textColor = scheme.onSurface;
      } else if (level >= 1) {
        textColor = scheme.primary;
      } else {
        textColor = theme.textTheme.bodySmall?.color;
      }
    }

    return Container(
      margin: const EdgeInsets.all(2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: isToday ? Border.all(color: scheme.primary, width: 1.5) : null,
      ),
      child: Text(
        '$day',
        style: theme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontSize: 12,
          fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _CheerCard extends ConsumerWidget {
  const _CheerCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summary = ref.watch(monthSummaryProvider);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        children: [
          Text(summary.cheerTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            summary.cheerDesc,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint();

  @override
  Widget build(BuildContext context) {
    return Text(
      '格子颜色表示当天坚持成功的打卡项数量：主动项漏打、被动项破戒都会让当天变浅。',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

const List<String> _weekdays = ['一', '二', '三', '四', '五', '六', '日'];

String _weekdayLabel(String date) {
  final index = parseYmd(date).weekday - 1;
  if (index < 0 || index >= _weekdays.length) return '';
  return _weekdays[index];
}

/// 五级色阶：0 级用浅底，1–4 级按主题色逐渐加深。
Color _levelColor(int level, ColorScheme scheme) {
  switch (level) {
    case 1:
      return Color.alphaBlend(scheme.primary.withValues(alpha: 0.12), Colors.white);
    case 2:
      return Color.alphaBlend(scheme.primary.withValues(alpha: 0.26), Colors.white);
    case 3:
      return Color.alphaBlend(scheme.primary.withValues(alpha: 0.46), Colors.white);
    case 4:
      return scheme.primary;
    default:
      return scheme.surfaceContainerHighest;
  }
}
