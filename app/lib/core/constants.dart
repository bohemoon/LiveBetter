/// 内置打卡项 ID 与默认设置常量。
class HabitIds {
  HabitIds._();

  static const String sleepEarly = 'sleep_early';
  static const String noFap = 'no_fap';
  static const String noBuffet = 'no_buffet';
  static const String leanBody = 'lean_body';
  static const String water = 'water';

  /// 「基础健康」分区固定项目，其余归入「我的打卡项」。
  static const List<String> basic = [sleepEarly, water, leanBody];
}

/// 应用默认设置（与 Web 原型保持一致）。
class DefaultSettings {
  DefaultSettings._();

  static const bool strictMode = false;
  static const bool reminderEnabled = true;
  static const String reminderTime = '22:45';
  static const bool hideSensitiveNames = true;
  static const bool appLockEnabled = false;
  static const String gender = 'female';
  static const String theme = 'green';
  static const bool periodEnabled = false;
  static const int periodLength = 5;
  static const int cycleLength = 28;
  static const bool periodicReminderEnabled = true;
}

/// 默认早睡目标时间。
const String kDefaultSleepTarget = '23:30';

/// 首页卡片网格列数。
const int kTodayGridColumns = 2;
