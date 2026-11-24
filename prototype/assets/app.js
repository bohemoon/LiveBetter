(function () {
  'use strict';

  /* =========================================================
   * 常量与工具
   * ======================================================= */

  const HABITS_KEY = 'lb.habits';
  const RECORDS_KEY = 'lb.records';
  const SETTINGS_KEY = 'lb.settings';

  const WEEKDAYS = ['一', '二', '三', '四', '五', '六', '日'];

  const DEFAULT_SETTINGS = {
    strictMode: false,
    reminderEnabled: true,
    reminderTime: '22:45',
    hideSensitiveNames: true,
    appLockEnabled: false,
    pin: '',
    healthIndexMode: 'stability',
    gender: 'female',
    theme: 'green',
    periodEnabled: false,
    periodStart: '',
    periodLength: 5,
    cycleLength: 28
  };

  // 基础健康项：始终列在「我的」中，可直接开关
  const BASIC_HABIT_IDS = ['sleep_early', 'water', 'lean_body'];

  // 常用推荐：按类别分组，覆盖日常、自律、计量与定期检查
  const HABIT_PRESETS = [
    { name: '早起', type: 'active', group: '日常' },
    { name: '运动', type: 'active', group: '日常' },
    { name: '阅读', type: 'active', group: '日常' },
    { name: '学习', type: 'active', group: '日常' },
    { name: '冥想', type: 'active', group: '日常' },
    { name: '护肤', type: 'active', group: '日常' },
    { name: '拉伸', type: 'active', group: '日常' },
    { name: '泡脚', type: 'active', group: '日常' },
    { name: '防晒', type: 'active', group: '日常' },
    { name: '早晚刷牙', type: 'active', group: '日常' },
    { name: '护眼远眺', type: 'active', group: '日常' },
    { name: '用牙线', type: 'active', group: '日常' },
    { name: '控糖', type: 'passive', group: '自律' },
    { name: '不喝奶茶', type: 'passive', group: '自律' },
    { name: '戒烟', type: 'passive', group: '自律' },
    { name: '戒酒', type: 'passive', group: '自律' },
    { name: '不熬夜', type: 'passive', group: '自律' },
    { name: '不久坐', type: 'passive', group: '自律' },
    { name: '不吃夜宵', type: 'passive', group: '自律' },
    { name: '少喝甜饮', type: 'passive', group: '自律' },
    { name: '蔬果份数', type: 'meter', group: '计量', goal: 5, unit: '份' },
    { name: '定期洗牙', type: 'periodic', group: '定期检查', interval: 180 },
    { name: '视力检测', type: 'periodic', group: '定期检查', interval: 365 },
    { name: '定期体检', type: 'periodic', group: '定期检查', interval: 365 },
    { name: '量血压', type: 'periodic', group: '定期检查', interval: 90 }
  ];

  // 主题色：影响强调色、底色与分隔线
  const THEMES = [
    { key: 'green', name: '绿', color: '#5d7264', bg: '#f4f6f3' },
    { key: 'blue', name: '蓝', color: '#5f7488', bg: '#f5f6f7' },
    { key: 'pink', name: '粉', color: '#9d7180', bg: '#f9f6f7' }
  ];

  const pad = n => String(n).padStart(2, '0');
  const dkey = d => d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());
  const parseDate = s => {
    const p = s.split('-');
    return new Date(+p[0], +p[1] - 1, +p[2]);
  };
  const addDays = (s, n) => {
    const d = parseDate(s);
    d.setDate(d.getDate() + n);
    return dkey(d);
  };
  const diffDays = (a, b) => Math.round((parseDate(b) - parseDate(a)) / 864e5);
  const todayKey = () => dkey(new Date());
  const startOfMonth = s => {
    const d = parseDate(s);
    return new Date(d.getFullYear(), d.getMonth(), 1);
  };
  const weekStart = s => {
    const d = parseDate(s);
    d.setDate(d.getDate() - ((d.getDay() + 6) % 7));
    return dkey(d);
  };
  const minutesOf = t => {
    const p = String(t || '23:30').split(':');
    return (+p[0]) * 60 + (+p[1] || 0);
  };
  const fmtTime = m => (m >= 1440 ? '24:00' : pad(Math.floor(m / 60)) + ':' + pad(m % 60));
  const nowMinutes = () => {
    const d = new Date();
    return d.getHours() * 60 + d.getMinutes();
  };
  const weekdayOf = s => WEEKDAYS[(parseDate(s).getDay() + 6) % 7];
  const fmtLeft = left => {
    const h = Math.floor(left / 60);
    const m = left % 60;
    return h > 0 ? h + ' 小时 ' + m + ' 分' : m + ' 分钟';
  };

  /* =========================================================
   * 状态
   * ======================================================= */

  let habits = [];
  let records = [];
  let settings = Object.assign({}, DEFAULT_SETTINGS);

  let activeTab = 'today';
  let detailHabitId = null;
  let calCursor = startOfMonth(todayKey());
  let unlocked = false;
  let toastTimer = null;

  function buildDefaultHabits() {
    const t = todayKey();
    return [
      {
        id: 'sleep_early', name: '早睡', type: 'active', required: true,
        enabled: true, targetTime: '23:30', createdAt: t, sensitive: false
      },
      {
        id: 'no_fap', name: '禁飞', type: 'passive', required: false,
        enabled: true, alias: '自律项', createdAt: t, sensitive: true
      },
      {
        id: 'no_buffet', name: '不吃自助', type: 'passive', required: false,
        enabled: true, createdAt: t, sensitive: false
      },
      {
        id: 'lean_body', name: '薄肌打造', type: 'active', required: false,
        enabled: false, targetTime: '', createdAt: t, sensitive: false
      },
      {
        id: 'water', name: '喝水', type: 'meter', required: false,
        enabled: true, goal: 8, unit: '杯', step: 1, createdAt: t, sensitive: false
      }
    ];
  }

  function safeParse(key) {
    try {
      return JSON.parse(localStorage.getItem(key) || 'null');
    } catch (e) {
      return null;
    }
  }

  function loadState() {
    const h = safeParse(HABITS_KEY);
    const r = safeParse(RECORDS_KEY);
    const s = safeParse(SETTINGS_KEY);

    habits = Array.isArray(h) && h.length ? h : buildDefaultHabits();
    records = Array.isArray(r) ? r : [];
    settings = Object.assign({}, DEFAULT_SETTINGS, s || {});

    // 旧数据：开启了应用锁但没有设置密码，按未开启处理
    if (settings.appLockEnabled && !settings.pin) {
      settings.appLockEnabled = false;
      localStorage.setItem(SETTINGS_KEY, JSON.stringify(settings));
    }

    habits.forEach(function (item) {
      if (item.id === 'no_fap') item.sensitive = true;
      if (!item.alias && item.sensitive) item.alias = '自律项';
    });
    if (!habits.some(function (item) { return item.id === 'sleep_early'; })) {
      habits.unshift(buildDefaultHabits()[0]);
    }
    // 保证有一个可记录数量的项目（喝水）
    if (!habits.some(function (item) { return item.type === 'meter'; })) {
      habits.push(buildDefaultHabits().filter(function (item) { return item.id === 'water'; })[0]);
    }
  }

  const saveHabits = () => localStorage.setItem(HABITS_KEY, JSON.stringify(habits));
  const saveRecords = () => localStorage.setItem(RECORDS_KEY, JSON.stringify(records));
  const saveSettings = () => localStorage.setItem(SETTINGS_KEY, JSON.stringify(settings));
  const saveAll = () => { saveHabits(); saveRecords(); saveSettings(); };

  /* =========================================================
   * 数据查询与统计
   * ======================================================= */

  function buildMap() {
    const map = {};
    records.forEach(function (r) {
      if (!map[r.habitId]) map[r.habitId] = new Map();
      map[r.habitId].set(r.date, r);
    });
    return map;
  }

  const listOf = (map, id) => map[id] || new Map();

  function habitName(h) {
    if (h.sensitive && settings.hideSensitiveNames) return h.alias || '自律项';
    return h.name;
  }

  function checkLabel(h) {
    if (h.id === 'sleep_early') return '我要睡了';
    if (h.id === 'lean_body') return '今天练完了';
    if (h.type === 'periodic') return '今天完成了';
    return '完成打卡';
  }

  // 当天是否算坚持成功
  function dayMet(h, rec) {
    if (h.type === 'passive') return !rec || rec.status !== 'slip';
    if (h.type === 'meter') return !!(rec && (rec.amount || 0) >= (h.goal || 1));
    return !!(rec && rec.status === 'success');
  }

  // 主动型：漏打即失败；温和模式下每周 1 次豁免
  function activeStats(h, map) {
    const today = todayKey();
    const list = listOf(map, h.id);
    const start = h.createdAt && h.createdAt < today ? h.createdAt : today;
    const curWeek = weekStart(today);

    let run = 0, best = 0, total = 0, weekExcused = false;
    const usedWeeks = new Set();
    let d = start;

    while (d <= today) {
      const rec = list.get(d);
      let st;
      if (h.type === 'meter') {
        st = dayMet(h, rec) ? 'success' : (d === today ? 'pending' : 'fail');
      } else {
        st = rec ? rec.status : (d === today ? 'pending' : 'fail');
      }

      if (st === 'success') {
        run++;
        total++;
      } else if (st === 'fail') {
        const wk = weekStart(d);
        if (!settings.strictMode && !usedWeeks.has(wk)) {
          usedWeeks.add(wk);
          if (wk === curWeek) weekExcused = true;
        } else {
          run = 0;
        }
      }
      if (run > best) best = run;
      d = addDays(d, 1);
    }

    const todayRec = list.get(today);
    return {
      current: run,
      best: best,
      total: total,
      todayStatus: h.type === 'meter'
        ? (dayMet(h, todayRec) ? 'success' : 'pending')
        : (todayRec ? todayRec.status : null),
      amount: (h.type === 'meter' && todayRec) ? (todayRec.amount || 0) : 0,
      weekExcused: weekExcused && todayRec && dayMet(h, todayRec)
    };
  }

  // 被动型：默认保持并按天累计，破戒当日归零
  function passiveStats(h, map) {
    const today = todayKey();
    const list = listOf(map, h.id);
    const start = h.createdAt && h.createdAt < today ? h.createdAt : today;

    let run = 0, best = 0, total = 0, lastSlip = null;
    let d = start;

    while (d <= today) {
      const rec = list.get(d);
      if (rec && rec.status === 'slip') {
        run = 0;
        lastSlip = d;
      } else {
        run++;
        total++;
        if (run > best) best = run;
      }
      d = addDays(d, 1);
    }

    return {
      current: run,
      best: best,
      total: total,
      lastSlip: lastSlip,
      todayStatus: list.get(today) ? list.get(today).status : null
    };
  }

  const statsOf = (h, map) => (h.type === 'passive' ? passiveStats(h, map) : activeStats(h, map));

  // 周期型：完成后从当天重新计时，卡片显示距下次的天数
  function periodicInfo(h, map) {
    const today = todayKey();
    const list = listOf(map, h.id);

    let lastDone = null, count = 0;
    list.forEach(function (rec, d) {
      if (rec.status !== 'success') return;
      count++;
      if (!lastDone || d > lastDone) lastDone = d;
    });

    const interval = h.interval || 180;
    const base = lastDone || h.createdAt || today;
    const next = addDays(base, interval);

    return {
      lastDone: lastDone,
      count: count,
      interval: interval,
      next: next,
      left: diffDays(today, next),
      doneToday: !!(list.get(today) && list.get(today).status === 'success')
    };
  }

  function enabledHabits() {
    return habits
      .filter(function (h) { return h.required || h.enabled; })
      .sort(function (a, b) { return (b.required ? 1 : 0) - (a.required ? 1 : 0); });
  }

  function stabilityData() {
    const map = buildMap();
    const list = enabledHabits().filter(function (h) { return h.type !== 'periodic'; });
    const days = [];
    for (let i = 6; i >= 0; i--) days.push(addDays(todayKey(), -i));

    let done = 0, total = 0;
    const bars = days.map(function (d) {
      let dd = 0, tt = 0;
      list.forEach(function (h) {
        if (h.createdAt && d < h.createdAt) return;
        tt++;
        const rec = listOf(map, h.id).get(d);
        if (dayMet(h, rec)) dd++;
      });
      done += dd;
      total += tt;
      return { date: d, ratio: tt ? dd / tt : 0 };
    });

    const pct = total ? done / total : 0;
    const label = pct >= 0.85 ? '稳' : pct >= 0.6 ? '一般' : '起伏';
    return { bars: bars, pct: pct, label: label, done: done, total: total };
  }

  /* =========================================================
   * 渲染：今日
   * ======================================================= */

  function greeting() {
    const h = new Date().getHours();
    if (h < 5) return '夜深了';
    if (h < 11) return '早上好';
    if (h < 14) return '中午好';
    if (h < 18) return '下午好';
    return '晚上好';
  }

  function stabilityHTML() {
    const data = stabilityData();
    const lv = data.pct >= 0.85 ? '' : data.pct >= 0.6 ? 'mid' : 'low';
    const bars = data.bars.map(function (b) {
      const hgt = Math.max(8, Math.round(b.ratio * 100));
      return '<div class="st-col"><div class="st-track"><i style="height:' + hgt + '%"></i></div>' +
        '<span>' + weekdayOf(b.date) + '</span></div>';
    }).join('');

    return '<section class="stability">' +
      '<div class="st-head"><span class="st-title">本周稳定度</span>' +
      '<span class="st-level ' + lv + '">' + data.label + '</span></div>' +
      '<div class="st-bars">' + bars + '</div>' +
      '<div class="st-foot">' + stabilityCheer(data.pct) + '</div>' +
      '</section>';
  }

  // 稳定度用鼓励代替具体数字
  function stabilityCheer(pct) {
    if (pct >= 0.85) return '这周很稳，保持这个节奏';
    if (pct >= 0.6) return '做得不错，允许自己偶尔松一松';
    if (pct >= 0.3) return '有在坚持，慢一点也没关系';
    return '这周辛苦了，先照顾好自己';
  }

  // 月度小结：不用数字，按完成情况给不同语气
  function monthCheer(ratio) {
    if (ratio >= 0.85) {
      return {
        title: '这个月状态很好',
        desc: '大部分日子都守住了，值得给自己一点肯定。'
      };
    }
    if (ratio >= 0.6) {
      return {
        title: '这个月走得挺稳',
        desc: '有做到的日子，也有放松的日子，都算数。'
      };
    }
    if (ratio >= 0.3) {
      return {
        title: '这个月在慢慢积累',
        desc: '不用每天都完美，愿意继续就很好。'
      };
    }
    if (ratio > 0) {
      return {
        title: '这个月有些辛苦',
        desc: '偶尔停下来也没关系，想继续的时候随时可以。'
      };
    }
    return {
      title: '新的一段路',
      desc: '从今天开始，先完成一件小事就好。'
    };
  }

  // 卡片只显示天数与名称；计量型主显当天数量，天数作为次要信息
  function cardBgStyle(h) {
    if (!h.bg) return '';
    return ' style="background-image:linear-gradient(rgba(255,255,255,.32),rgba(255,255,255,.6)),url(' +
      h.bg + ')"';
  }

  function gridCardHTML(h, map) {
    if (h.type === 'periodic') {
      const p = periodicInfo(h, map);

      let cls = 'day-card is-periodic';
      if (p.doneToday) cls += ' is-done';
      else if (p.left <= 0) cls += ' is-due';
      if (h.bg) cls += ' has-bg';

      const big = p.left > 0
        ? '<b>' + p.left + '</b><i>天后</i>'
        : (p.left === 0 ? '<b class="due-word">今天</b>' : '<b class="due-word">逾期</b>');

      return '<div class="' + cls + '"' + cardBgStyle(h) + ' data-action="open-detail" data-id="' + h.id + '">' +
        '<span class="day-days">' + big + '</span>' +
        '<span class="day-foot">' +
          '<span class="day-name">' + habitName(h) + '</span>' +
          '<button class="card-check' + (p.doneToday ? ' done' : '') + '" data-action="check" data-id="' +
            h.id + '" aria-label="今天完成了">✓</button>' +
        '</span>' +
        '</div>';
    }

    const st = statsOf(h, map);

    let cls = 'day-card';
    if (h.type === 'passive') cls += ' is-passive';
    if (st.todayStatus === 'success') cls += ' is-done';
    if (h.bg) cls += ' has-bg';

    if (h.type === 'meter') {
      const amt = st.amount || 0;
      const goal = h.goal || 1;
      return '<div class="' + cls + '"' + cardBgStyle(h) + ' data-action="open-detail" data-id="' + h.id + '">' +
        '<span class="day-amount"><b>' + amt + '</b><i>/ ' + goal + ' ' + h.unit + '</i></span>' +
        '<span class="day-foot">' +
          '<span class="day-name">' + habitName(h) + '</span>' +
          '<span class="day-meta">' +
            '<span class="day-sub">' + st.current + ' 天</span>' +
            '<button class="card-add" data-action="add-amount" data-id="' + h.id +
              '" aria-label="记录 ' + (h.step || 1) + ' ' + h.unit + '">+1</button>' +
          '</span>' +
        '</span>' +
        '</div>';
    }

    if (h.type === 'active') {
      const done = st.todayStatus === 'success';
      return '<div class="' + cls + '"' + cardBgStyle(h) + ' data-action="open-detail" data-id="' + h.id + '">' +
        '<span class="day-days"><b>' + st.current + '</b><i>天</i></span>' +
        '<span class="day-foot">' +
          '<span class="day-name">' + habitName(h) + '</span>' +
          '<button class="card-check' + (done ? ' done' : '') + '" data-action="check" data-id="' +
            h.id + '" aria-label="' + checkLabel(h) + '">✓</button>' +
        '</span>' +
        '</div>';
    }

    return '<button class="' + cls + '"' + cardBgStyle(h) + ' data-action="open-detail" data-id="' + h.id + '">' +
      '<span class="day-days"><b>' + st.current + '</b><i>天</i></span>' +
      '<span class="day-name">' + habitName(h) + '</span>' +
      '</button>';
  }

  function cycleInfo() {
    if (!settings.periodEnabled || !settings.periodStart) return null;

    const today = todayKey();
    const since = diffDays(settings.periodStart, today);
    const len = settings.cycleLength || 28;
    const plen = settings.periodLength || 5;

    if (since < 0) return { onPeriod: false, daysLeft: -since };

    const dayInCycle = since % len;
    if (dayInCycle < plen) return { onPeriod: true, day: dayInCycle + 1 };
    return { onPeriod: false, daysLeft: len - dayInCycle };
  }

  function cycleCardHTML() {
    const info = cycleInfo();
    if (!info) return '';

    return '<button class="cycle-card' + (info.onPeriod ? ' on' : '') +
      '" data-action="open-period">' +
      '<span class="cycle-dot"></span>' +
      '<span class="cycle-main">' +
        (info.onPeriod
          ? '经期第 ' + info.day + ' 天'
          : '距离下次经期 ' + info.daysLeft + ' 天') +
        '<i>' + (info.onPeriod
          ? '记得多休息，少碰冰饮'
          : '按 ' + settings.cycleLength + ' 天周期推算') + '</i>' +
      '</span>' +
      '<span class="cycle-arrow">›</span>' +
      '</button>';
  }

  function renderToday() {
    const map = buildMap();
    const today = todayKey();
    const sleep = habits.find(function (h) { return h.id === 'sleep_early'; });
    const sleepRec = sleep ? listOf(map, sleep.id).get(today) : null;
    const mins = nowMinutes();

    let sub = '';
    if (!sleep) {
      sub = '';
    } else if (sleepRec && sleepRec.status === 'success') {
      sub = '今天已完成，保持住';
    } else if (sleepRec && sleepRec.status === 'fail') {
      sub = '今天未达成，明天重新开始';
    } else if (mins < 240) {
      sub = '夜深了，记录完就去休息吧';
    } else {
      const left = minutesOf(sleep.targetTime) - mins;
      sub = left > 0
        ? '距离 ' + sleep.targetTime + ' 还有 ' + fmtLeft(left)
        : '目标时间已过，明天重新开始';
    }

    const list = enabledHabits();
    const pending = list.filter(function (h) {
      return h.type === 'active' && !listOf(map, h.id).get(today);
    });

    let banner = '';
    if (settings.reminderEnabled && pending.length && mins >= minutesOf(settings.reminderTime)) {
      banner = '<div class="banner"><span>还有 <b>' + pending.length + '</b> 项没完成：' +
        pending.map(habitName).join('、') + '</span></div>';
    }

    const d = new Date();
    return '<div class="page-head">' +
        '<div class="eyebrow">' + d.getFullYear() + '年' + (d.getMonth() + 1) + '月' +
        d.getDate() + '日 · 周' + weekdayOf(today) + '</div>' +
        '<h1 class="page-title">' + greeting() + '</h1>' +
        '<p class="page-sub">' + sub + '</p>' +
      '</div>' +
      banner +
      cycleCardHTML() +
      '<div class="day-grid">' +
        list.map(function (h) { return gridCardHTML(h, map); }).join('') +
      '</div>';
  }

  function renderDetail() {
    const h = habits.find(function (x) { return x.id === detailHabitId; });
    if (!h) {
      detailHabitId = null;
      return renderToday();
    }

    const map = buildMap();
    if (h.type === 'periodic') return renderPeriodicDetail(h, map);
    const st = statsOf(h, map);
    const today = todayKey();
    const anchor = st.todayStatus === 'success' ? today : addDays(today, -1);
    const start = st.current > 0 ? addDays(anchor, -(st.current - 1)) : today;

    let meta;
    if (h.type === 'meter') {
      meta = '目标 ' + h.goal + ' ' + h.unit + ' / 天 · 每次 ' + (h.step || 1) + ' ' + h.unit;
    } else if (h.type === 'active') {
      meta = h.id === 'sleep_early'
        ? '每天 ' + h.targetTime + ' 前记录 · 必选'
        : '每天完成一次 · 可选';
    } else {
      meta = '默认保持 · 破戒后重新计数';
    }

    let rule;
    if (h.type === 'meter') {
      rule = '计量打卡：每次点按累加，达到目标即算当天坚持；未达标即未完成。';
    } else if (h.type === 'passive') {
      rule = '被动打卡：默认保持，破戒当天重新计数；最长纪录与累计天数会保留。';
    } else if (h.id === 'sleep_early') {
      rule = '主动打卡：每天 ' + h.targetTime + ' 前记录，漏打即未达成；温和模式下每周 1 次豁免。';
    } else {
      rule = '主动打卡：每天完成一次训练即记录，漏打即未达成。';
    }

    let action;
    if (h.type === 'meter') {
      action = '<button class="btn-primary" data-action="add-amount" data-id="' + h.id + '">' +
        '＋ 记录 ' + (h.step || 1) + ' ' + h.unit + '</button>';
    } else if (h.type === 'active') {
      if (st.todayStatus === 'success') {
        action = '<div class="status-line"><span class="done-flag">今日已完成</span>' +
          '<button class="link" data-action="undo" data-id="' + h.id + '">撤销</button></div>';
      } else if (st.todayStatus === 'fail') {
        action = '<div class="status-line"><span class="miss-flag">今日未达成</span>' +
          '<button class="link" data-action="undo" data-id="' + h.id + '">撤销</button></div>';
      } else {
        action = '<button class="btn-primary" data-action="check" data-id="' + h.id + '">' +
          checkLabel(h) + '</button>';
      }
    } else if (st.todayStatus === 'slip') {
      action = '<div class="status-line"><span class="miss-flag soft">今天重新开始</span>' +
        '<button class="link" data-action="undo" data-id="' + h.id + '">撤销</button></div>';
    } else {
      action = '<button class="btn-outline-danger" data-action="slip" data-id="' + h.id + '">今天没做到</button>';
    }

    const amt = st.amount || 0;
    const goal = h.goal || 1;
    const pct = Math.min(100, Math.round(amt / goal * 100));
    const meterPanel = h.type === 'meter'
      ? '<div class="meter">' +
          '<div class="meter-top"><span>今日累计</span>' +
          '<b>' + amt + '<i>' + h.unit + '</i></b></div>' +
          '<div class="meter-bar"><i style="width:' + pct + '%"></i></div>' +
          '<div class="meter-foot">目标 ' + goal + ' ' + h.unit +
            (amt >= goal ? ' · 已达标' : ' · 还差 ' + (goal - amt) + ' ' + h.unit) +
          '</div>' +
        '</div>'
      : '';
    const meterUndo = h.type === 'meter' && amt > 0
      ? '<div class="action-sub"><button class="link" data-action="undo-amount" data-id="' +
        h.id + '">撤销一次</button></div>'
      : '';

    return '<div class="detail-head">' +
        '<button class="back-btn" data-action="back">‹ 今日</button>' +
        '<button class="gear-btn" data-action="open-card-settings" data-id="' + h.id + '">设置</button>' +
      '</div>' +
      '<div class="detail-hero">' +
        '<div class="detail-date">' + start.replace(/-/g, '.') + ' 起</div>' +
        '<h1 class="detail-name">' + habitName(h) + '</h1>' +
        '<div class="detail-days"><b>' + st.current + '</b><i>天</i></div>' +
        '<div class="detail-sub">' + meta + (st.weekExcused ? ' · 本周已用 1 次豁免' : '') + '</div>' +
      '</div>' +
      meterPanel +
      '<div class="detail-grid">' +
        '<div><b>' + st.current + '</b><span>当前连续</span></div>' +
        '<div><b>' + st.best + '</b><span>最长纪录</span></div>' +
        '<div><b>' + st.total + '</b><span>' + (h.type === 'meter' ? '累计达标' : '累计天数') + '</span></div>' +
      '</div>' +
      '<div class="detail-action">' + action + '</div>' +
      meterUndo +
      '<p class="hint" style="margin-top:16px">' + rule + '</p>';
  }

  function renderPeriodicDetail(h, map) {
    const p = periodicInfo(h, map);

    const big = p.left > 0
      ? '<b>' + p.left + '</b><i>天后</i>'
      : (p.left === 0
        ? '<b class="due-word">今天</b><i>该做了</i>'
        : '<b class="due-word">逾期</b><i>' + (-p.left) + ' 天</i>');

    const meta = '每 ' + p.interval + ' 天一次';
    const dateLine = p.lastDone
      ? '上次完成 ' + p.lastDone.replace(/-/g, '.')
      : (h.createdAt || todayKey()).replace(/-/g, '.') + ' 起';

    const action = p.doneToday
      ? '<div class="status-line"><span class="done-flag">今天已完成</span>' +
        '<button class="link" data-action="undo" data-id="' + h.id + '">撤销</button></div>'
      : '<button class="btn-primary" data-action="check" data-id="' + h.id + '">今天完成了</button>';

    return '<div class="detail-head">' +
        '<button class="back-btn" data-action="back">‹ 今日</button>' +
        '<button class="gear-btn" data-action="open-card-settings" data-id="' + h.id + '">设置</button>' +
      '</div>' +
      '<div class="detail-hero">' +
        '<div class="detail-date">' + dateLine + '</div>' +
        '<h1 class="detail-name">' + habitName(h) + '</h1>' +
        '<div class="detail-days">' + big + '</div>' +
        '<div class="detail-sub">' + meta + '</div>' +
      '</div>' +
      '<div class="detail-grid">' +
        '<div><b>' + p.next.slice(5).replace('-', '.') + '</b><span>下次日期</span></div>' +
        '<div><b>' + p.count + '</b><span>累计次数</span></div>' +
        '<div><b>' + p.interval + '</b><span>间隔天数</span></div>' +
      '</div>' +
      '<div class="detail-action">' + action + '</div>' +
      '<p class="hint" style="margin-top:16px">周期打卡：完成后从当天重新计时，卡片上显示距下次的天数。</p>';
  }

  /* =========================================================
   * 渲染：记录
   * ======================================================= */

  function renderRecords() {
    const list = enabledHabits().filter(function (h) { return h.type !== 'periodic'; });
    const map = buildMap();
    const today = todayKey();
    const now = new Date();

    const y = calCursor.getFullYear();
    const m = calCursor.getMonth();
    const offset = (new Date(y, m, 1).getDay() + 6) % 7;
    const daysInMonth = new Date(y, m + 1, 0).getDate();
    const nextDisabled = y > now.getFullYear() || (y === now.getFullYear() && m >= now.getMonth());

    let cells = '';
    let monthDone = 0, monthTotal = 0;

    for (let i = 0; i < offset; i++) cells += '<div class="cal-day empty"></div>';
    for (let day = 1; day <= daysInMonth; day++) {
      const ds = dkey(new Date(y, m, day));
      let cls = 'future';
      let count = 0, total = 0;

      if (ds <= today) {
        list.forEach(function (h) {
          if (h.createdAt && ds < h.createdAt) return;
          total++;
          const rec = listOf(map, h.id).get(ds);
          if (dayMet(h, rec)) count++;
        });
        if (!total) cls = '';
        else cls = 'lv' + Math.min(4, count);
        monthDone += count;
        monthTotal += total;
      }

      if (ds === today) cls += ' today';
      cells += '<div class="cal-day ' + cls + '">' + day + '</div>';
    }

    const swatches = '<i class="sw lv1"></i><i class="sw lv2"></i><i class="sw lv3"></i><i class="sw lv4"></i>';
    const cheer = monthCheer(monthTotal ? monthDone / monthTotal : 0);

    return '<div class="page-head">' +
        '<div class="eyebrow">回顾</div>' +
        '<h1 class="page-title">记录</h1>' +
        '<p class="page-sub">颜色越深，当天坚持的项目越多</p>' +
      '</div>' +
      stabilityHTML() +
      '<section class="cal">' +
        '<div class="cal-head">' +
          '<button class="cal-nav" data-action="cal-prev"' + ' aria-label="上个月">‹</button>' +
          '<div class="cal-month">' + y + '年' + (m + 1) + '月</div>' +
          '<button class="cal-nav" data-action="cal-next"' + (nextDisabled ? ' disabled' : '') +
            ' aria-label="下个月">›</button>' +
        '</div>' +
        '<div class="cal-grid">' +
          WEEKDAYS.map(function (w) { return '<div class="cal-wd">' + w + '</div>'; }).join('') +
          cells +
        '</div>' +
        '<div class="legend legend-scale">' +
          '<span>少</span>' + swatches + '<span>多</span>' +
        '</div>' +
      '</section>' +
      '<div class="panel cheer">' +
        '<div class="cheer-title">' + cheer.title + '</div>' +
        '<p class="cheer-desc">' + cheer.desc + '</p>' +
      '</div>' +
      '<p class="hint">格子颜色表示当天坚持成功的打卡项数量：主动项漏打、被动项破戒都会让当天变浅。</p>';
  }

  /* =========================================================
   * 渲染：我的
   * ======================================================= */

  function switchRow(key, title, desc) {
    return '<div class="row" data-action="toggle-setting" data-key="' + key + '">' +
      '<div class="row-main"><div class="row-title">' + title + '</div>' +
      '<div class="row-desc">' + desc + '</div></div>' +
      '<button class="switch' + (settings[key] ? ' on' : '') + '" aria-label="' + title + '"></button>' +
      '</div>';
  }

  function habitRowHTML(h) {
    const control = h.required
      ? '<span class="tag-required">必选</span>'
      : '<button class="switch' + (h.enabled ? ' on' : '') + '" aria-label="' + h.name + '"></button>';

    let rows = '<div class="row' + (h.required ? '' : ' tappable') + '"' +
      (h.required ? '' : ' data-action="toggle-habit" data-id="' + h.id + '"') + '>' +
      '<div class="row-main"><div class="row-title">' + habitName(h) + '</div>' +
      '<div class="row-desc">' +
      (h.type === 'active' ? '主动打卡'
        : h.type === 'meter' ? ('累计记录 · 目标 ' + h.goal + ' ' + h.unit)
        : h.type === 'periodic' ? ('周期记录 · 每 ' + (h.interval || 180) + ' 天')
        : '被动保持') +
      (h.required ? ' · 核心项不可关闭' : '') + '</div></div>' +
      control + '</div>';

    if (h.id === 'sleep_early') {
      rows += '<div class="row tappable" data-action="open-target" data-id="' + h.id + '">' +
        '<div class="row-main"><div class="row-title">目标时间</div>' +
        '<div class="row-desc">可调范围 21:30 – 24:00，24:00 为上限</div></div>' +
        '<span class="row-value">' + h.targetTime + '</span></div>';
    }
    return rows;
  }

  function renderMine() {
    const basicHabits = habits.filter(function (h) { return BASIC_HABIT_IDS.indexOf(h.id) >= 0; });
    const myHabits = habits.filter(function (h) { return BASIC_HABIT_IDS.indexOf(h.id) < 0; });

    const basicRows = basicHabits.map(habitRowHTML).join('');
    const myRows = myHabits.length
      ? myHabits.map(habitRowHTML).join('')
      : '<div class="row"><div class="row-main">' +
        '<div class="row-desc">还没有自定义项目，从下方选择常用项快速添加</div></div></div>';

    return '<div class="page-head">' +
        '<div class="eyebrow">设置</div>' +
        '<h1 class="page-title">我的</h1>' +
        '<p class="page-sub">少一点规则，多一点坚持</p>' +
      '</div>' +

      '<section class="section">' +
        '<h2 class="section-title">个人信息</h2>' +
        '<div class="panel">' +
          '<div class="row">' +
            '<div class="row-main"><div class="row-title">性别</div>' +
            '<div class="row-desc">男性默认关闭经期功能，可手动开启</div></div>' +
            '<div class="gender-pick">' +
              '<button class="gender' + (settings.gender !== 'male' ? ' on' : '') +
                '" data-action="set-gender" data-gender="female">女</button>' +
              '<button class="gender' + (settings.gender === 'male' ? ' on' : '') +
                '" data-action="set-gender" data-gender="male">男</button>' +
            '</div>' +
          '</div>' +
        '</div>' +
      '</section>' +

      '<section class="section">' +
        '<h2 class="section-title">基础健康</h2>' +
        '<div class="panel">' + basicRows + '</div>' +
      '</section>' +

      '<section class="section">' +
        '<h2 class="section-title">我的打卡项</h2>' +
        '<div class="panel">' + myRows + '</div>' +
        '<button class="add-bar" data-action="add-habit">' +
          '<span class="add-plus">＋</span><span>添加打卡项</span>' +
        '</button>' +
      '</section>' +

      '<section class="section">' +
        '<h2 class="section-title">经期管理</h2>' +
        '<div class="panel">' +
          switchRow('periodEnabled', '经期提醒',
            settings.gender === 'male' ? '男性默认关闭，可手动开启' : '开启后在首页显示周期进度') +
          '<div class="row tappable" data-action="open-period">' +
            '<div class="row-main"><div class="row-title">周期设置</div>' +
            '<div class="row-desc">' +
              (settings.periodStart
                ? '上次开始 ' + settings.periodStart + ' · 周期 ' + settings.cycleLength + ' 天'
                : '记录最近一次开始日期，用于推算当前阶段') +
            '</div></div>' +
            '<span class="row-value">›</span>' +
          '</div>' +
        '</div>' +
      '</section>' +

      '<section class="section">' +
        '<h2 class="section-title">外观</h2>' +
        '<div class="panel">' +
          '<div class="row">' +
            '<div class="row-main"><div class="row-title">主题色</div>' +
            '<div class="row-desc">改变强调色与背景色调</div></div>' +
          '</div>' +
          '<div class="theme-row">' +
            THEMES.map(function (t) {
              return '<button class="swatch' + (settings.theme === t.key ? ' on' : '') +
                '" style="background:' + t.color + '" data-action="set-theme" data-theme="' +
                t.key + '" aria-label="' + t.name + '"></button>';
            }).join('') +
          '</div>' +
        '</div>' +
      '</section>' +

      '<section class="section">' +
        '<h2 class="section-title">习惯模式</h2>' +
        '<div class="panel">' +
          '<div class="row tappable" data-action="set-mode" data-mode="mild">' +
            '<div class="row-main"><div class="row-title">温和模式</div>' +
            '<div class="row-desc">每周 1 次豁免，断签不中断连续天数</div></div>' +
            '<span class="radio' + (settings.strictMode ? '' : ' on') + '"></span>' +
          '</div>' +
          '<div class="row tappable" data-action="set-mode" data-mode="strict">' +
            '<div class="row-main"><div class="row-title">严格模式</div>' +
            '<div class="row-desc">没有豁免，断签即从头开始</div></div>' +
            '<span class="radio' + (settings.strictMode ? ' on' : '') + '"></span>' +
          '</div>' +
        '</div>' +
      '</section>' +

      '<section class="section">' +
        '<h2 class="section-title">提醒</h2>' +
        '<div class="panel">' +
          switchRow('reminderEnabled', '打卡提醒', '到点后仅在首页显示一条中性提示') +
          '<div class="row">' +
            '<div class="row-main"><div class="row-title">提醒时间</div>' +
            '<div class="row-desc">睡前留出一点缓冲</div></div>' +
            '<input class="time-input" type="time" value="' + settings.reminderTime + '" data-action="reminder-time">' +
          '</div>' +
        '</div>' +
      '</section>' +

      '<section class="section">' +
        '<h2 class="section-title">隐私</h2>' +
        '<div class="panel">' +
          switchRow('hideSensitiveNames', '隐藏敏感项名称', '敏感打卡项显示为中性代号') +
          switchRow('appLockEnabled', '应用锁', '下次打开时需要输入 4 位密码') +
        '</div>' +
      '</section>' +

      '<section class="section">' +
        '<h2 class="section-title">数据</h2>' +
        '<div class="panel">' +
          '<div class="row tappable action danger" data-action="clear">' +
            '<div class="row-main"><div class="row-title">清除全部数据</div>' +
            '<div class="row-desc">所有记录仅保存在本机，清除后不可恢复</div></div>' +
          '</div>' +
        '</div>' +
      '</section>' +

      '<p class="foot-note">LiveBetter v1.0<br>数据仅保存在本机浏览器</p>';
  }

  /* =========================================================
   * 主渲染
   * ======================================================= */

  function render() {
    const view = document.getElementById('view');
    const keep = view.scrollTop;
    let html = '';

    if (activeTab === 'today') html = detailHabitId ? renderDetail() : renderToday();
    else if (activeTab === 'records') html = renderRecords();
    else html = renderMine();

    view.innerHTML = html;
    view.scrollTop = keep;

    document.querySelectorAll('.tab').forEach(function (btn) {
      btn.classList.toggle('active', btn.dataset.tab === activeTab);
    });
    syncLock();
  }

  /* =========================================================
   * 交互动作
   * ======================================================= */

  function toast(msg) {
    const el = document.getElementById('toast');
    el.textContent = msg;
    el.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () { el.classList.remove('show'); }, 1900);
  }

  function checkIn(id) {
    const h = habits.find(function (x) { return x.id === id; });
    if (!h) return;
    const today = todayKey();
    if (listOf(buildMap(), h.id).get(today)) {
      toast('今天已经记录过了');
      return;
    }

    const now = new Date();
    const mins = now.getHours() * 60 + now.getMinutes();

    if (h.id === 'sleep_early') {
      const ok = mins <= minutesOf(h.targetTime);
      records.push({
        habitId: h.id, date: today,
        status: ok ? 'success' : 'fail',
        recordedAt: now.toISOString()
      });
      saveRecords();
      render();
      toast(ok ? '已记录，今晚早点休息' : '已记录 · 已过目标时间，明天继续');
    } else {
      records.push({
        habitId: h.id, date: today, status: 'success',
        recordedAt: now.toISOString()
      });
      saveRecords();
      render();
      toast(h.id === 'lean_body' ? '训练完成，已记录' : '已记录');
    }
  }

  function undoToday(id) {
    const today = todayKey();
    records = records.filter(function (r) {
      return !(r.habitId === id && r.date === today);
    });
    saveRecords();
    render();
    toast('已撤销今日记录');
  }

  function addAmount(id) {
    const h = habits.find(function (x) { return x.id === id; });
    if (!h) return;
    const today = todayKey();
    const rec = listOf(buildMap(), h.id).get(today);
    const step = h.step || 1;

    if (rec) {
      rec.amount = (rec.amount || 0) + step;
    } else {
      records.push({
        habitId: h.id, date: today, amount: step,
        recordedAt: new Date().toISOString()
      });
    }

    saveRecords();
    render();
    const amt = rec ? rec.amount : step;
    toast(amt >= (h.goal || 1)
      ? '已达标，今天做得不错'
      : '已记录 ' + amt + ' / ' + h.goal + ' ' + h.unit);
  }

  function undoAmount(id) {
    const h = habits.find(function (x) { return x.id === id; });
    if (!h) return;
    const today = todayKey();
    const rec = listOf(buildMap(), h.id).get(today);
    if (!rec) return;

    const next = (rec.amount || 0) - (h.step || 1);
    if (next <= 0) {
      records = records.filter(function (r) {
        return !(r.habitId === h.id && r.date === today);
      });
    } else {
      rec.amount = next;
    }

    saveRecords();
    render();
    toast('已撤销一次');
  }

  function recordSlip(h) {
    const today = todayKey();
    const existing = listOf(buildMap(), h.id).get(today);
    closeSheet();
    if (existing && existing.status === 'slip') {
      toast('今天已经记录过了');
      return;
    }
    records = records.filter(function (r) {
      return !(r.habitId === h.id && r.date === today);
    });
    records.push({
      habitId: h.id, date: today, status: 'slip',
      recordedAt: new Date().toISOString()
    });
    saveRecords();
    render();
    toast('已记录，从今天重新开始');
  }

  /* =========================================================
   * 弹层
   * ======================================================= */

  function openSheet(html) {
    closeSheet();
    const root = document.getElementById('sheet-root');

    const mask = document.createElement('div');
    mask.className = 'sheet-mask';
    mask.addEventListener('click', closeSheet);

    const sheet = document.createElement('div');
    sheet.className = 'sheet';
    sheet.innerHTML = html;
    sheet.addEventListener('click', function (e) {
      if (e.target.closest('[data-close]')) closeSheet();
    });

    root.appendChild(mask);
    root.appendChild(sheet);
  }

  function closeSheet() {
    document.getElementById('sheet-root').innerHTML = '';
  }

  function openSlipSheet(id) {
    const h = habits.find(function (x) { return x.id === id; });
    if (!h) return;

    openSheet(
      '<div class="sheet-grip"></div>' +
      '<h3 class="sheet-title">记录今天没做到</h3>' +
      '<p class="sheet-desc">「' + habitName(h) + '」将从今天重新开始计数。最长纪录与累计天数会保留，不用太苛责自己。</p>' +
      '<button class="btn-primary btn-danger" id="slipOk">确认记录</button>' +
      '<button class="btn-text" data-close>再想想</button>'
    );

    document.getElementById('slipOk').addEventListener('click', function () {
      recordSlip(h);
    });
  }

  function openTargetSheet(id) {
    const h = habits.find(function (x) { return x.id === id; });
    if (!h) return;

    const val = Math.min(1440, Math.max(1290, minutesOf(h.targetTime)));
    openSheet(
      '<div class="sheet-grip"></div>' +
      '<h3 class="sheet-title">早睡目标时间</h3>' +
      '<p class="sheet-desc">可在 21:30 – 24:00 之间调整。24:00 是不可突破的上限，跨过零点就进入熬夜区间。</p>' +
      '<div class="time-value" id="tv">' + fmtTime(val) + '</div>' +
      '<input class="range" id="tr" type="range" min="1290" max="1440" step="10" value="' + val + '">' +
      '<div class="range-scale"><span>21:30</span><span>24:00</span></div>' +
      '<button class="btn-primary" id="saveTarget">保存</button>' +
      '<p class="sheet-note">新的目标时间从明天开始生效</p>'
    );

    const tr = document.getElementById('tr');
    const tv = document.getElementById('tv');
    tr.addEventListener('input', function () {
      tv.textContent = fmtTime(+tr.value);
    });
    document.getElementById('saveTarget').addEventListener('click', function () {
      h.targetTime = fmtTime(+tr.value);
      saveHabits();
      closeSheet();
      render();
      toast('目标时间已更新，明天起生效');
    });
  }

  function openCardSettings(id) {
    const h = habits.find(function (x) { return x.id === id; });
    if (!h) return;

    const targetRow = h.id === 'sleep_early'
      ? '<button class="set-row" id="setTarget"><span>目标时间</span><b>' + h.targetTime + '</b></button>'
      : '';

    openSheet(
      '<div class="sheet-grip"></div>' +
      '<h3 class="sheet-title">卡片设置</h3>' +
      '<p class="sheet-desc">' + habitName(h) + ' · 只影响这张卡片的展示</p>' +
      '<div class="set-list">' +
        targetRow +
        '<button class="set-row" id="setBg"><span>卡片背景</span><b>' +
          (h.bg ? '更换图片' : '选择图片') + '</b></button>' +
        (h.bg ? '<button class="set-row" id="clearBg"><span>移除背景</span><b>移除</b></button>' : '') +
      '</div>' +
      '<button class="btn-text" data-close>完成</button>'
    );

    if (h.id === 'sleep_early') {
      document.getElementById('setTarget').addEventListener('click', function () {
        closeSheet();
        openTargetSheet(h.id);
      });
    }
    document.getElementById('setBg').addEventListener('click', function () {
      pickBackground(h.id);
    });
    const clearBtn = document.getElementById('clearBg');
    if (clearBtn) {
      clearBtn.addEventListener('click', function () {
        clearBackground(h.id);
      });
    }
  }

  function openPeriodSheet() {
    const startVal = settings.periodStart || todayKey();
    openSheet(
      '<div class="sheet-grip"></div>' +
      '<h3 class="sheet-title">经期管理</h3>' +
      '<p class="sheet-desc">用于推算当前阶段。数据只保存在本机，不会上传。</p>' +
      '<button class="btn-soft" id="periodToday">今天来了</button>' +
      '<div class="field"><label class="field-label">上次开始日期</label>' +
        '<input class="text-input" id="periodStart" type="date" max="' + todayKey() +
        '" value="' + startVal + '"></div>' +
      '<div class="field-row">' +
        '<div class="field"><label class="field-label">周期长度（天）</label>' +
          '<input class="text-input" id="cycleLen" type="number" min="15" max="60" value="' +
          settings.cycleLength + '"></div>' +
        '<div class="field"><label class="field-label">经期天数</label>' +
          '<input class="text-input" id="periodLen" type="number" min="1" max="14" value="' +
          settings.periodLength + '"></div>' +
      '</div>' +
      '<button class="btn-primary" id="savePeriod">保存</button>' +
      '<button class="btn-text" data-close>取消</button>'
    );

    function save(start) {
      settings.periodStart = start;
      settings.cycleLength = Math.min(60, Math.max(15,
        parseInt(document.getElementById('cycleLen').value, 10) || 28));
      settings.periodLength = Math.min(14, Math.max(1,
        parseInt(document.getElementById('periodLen').value, 10) || 5));
      settings.periodEnabled = true;
      saveSettings();
      closeSheet();
      render();
      toast('经期设置已保存');
    }

    document.getElementById('periodToday').addEventListener('click', function () {
      document.getElementById('periodStart').value = todayKey();
      save(todayKey());
    });
    document.getElementById('savePeriod').addEventListener('click', function () {
      save(document.getElementById('periodStart').value || todayKey());
    });
  }

  function presetGroupsHTML() {
    const groups = [];
    HABIT_PRESETS.forEach(function (p, i) {
      let g = groups[groups.length - 1];
      if (!g || g.label !== p.group) {
        g = { label: p.group, items: [] };
        groups.push(g);
      }
      g.items.push({ p: p, i: i });
    });

    return groups.map(function (g) {
      return '<div class="preset-group">' +
        '<span class="preset-label">' + g.label + '</span>' +
        '<div class="preset-chips">' +
          g.items.map(function (it) {
            return '<button class="preset" data-preset="' + it.i + '">' + it.p.name + '</button>';
          }).join('') +
        '</div></div>';
    }).join('');
  }

  function openAddSheet() {
    openSheet(
      '<div class="sheet-grip"></div>' +
      '<h3 class="sheet-title">新建项目</h3>' +
      '<p class="sheet-desc">新项目从今天开始计算，之后可以随时在「我的」里调整。</p>' +
      '<div class="field">' +
        '<label class="field-label">项目名称</label>' +
        '<input class="text-input" id="newName" maxlength="8" placeholder="如：每天喝 8 杯水">' +
      '</div>' +
      '<div class="field">' +
        '<label class="field-label">健康推荐</label>' +
        presetGroupsHTML() +
      '</div>' +
      '<div class="field">' +
        '<label class="field-label">打卡方式</label>' +
        '<div class="segmented">' +
          '<button class="seg on" data-type="active">主动打卡</button>' +
          '<button class="seg" data-type="passive">被动保持</button>' +
          '<button class="seg" data-type="meter">累计记录</button>' +
          '<button class="seg" data-type="periodic">周期记录</button>' +
        '</div>' +
        '<p class="field-hint">主动：每天完成一次；被动：默认保持，破戒时才记录；累计：点击累加数量，达到目标算坚持；周期：每隔一段时间完成一次</p>' +
      '</div>' +
      '<div class="field-row" id="meterFields" hidden>' +
        '<div class="field"><label class="field-label">每日目标</label>' +
          '<input class="text-input" id="newGoal" type="number" min="1" max="9999" value="8"></div>' +
        '<div class="field"><label class="field-label">单位</label>' +
          '<input class="text-input" id="newUnit" maxlength="2" value="杯"></div>' +
      '</div>' +
      '<div class="field" id="periodicFields" hidden>' +
        '<label class="field-label">间隔天数</label>' +
        '<input class="text-input" id="newInterval" type="number" min="1" max="3650" value="180">' +
      '</div>' +
      '<button class="btn-primary" id="createHabit">创建</button>' +
      '<button class="btn-text" data-close>取消</button>'
    );

    let type = 'active';
    const opts = Array.prototype.slice.call(document.querySelectorAll('.seg'));
    opts.forEach(function (btn) {
      btn.addEventListener('click', function () {
        type = btn.dataset.type;
        opts.forEach(function (b) { b.classList.toggle('on', b === btn); });
        document.getElementById('meterFields').hidden = type !== 'meter';
        document.getElementById('periodicFields').hidden = type !== 'periodic';
      });
    });

    const presetBtns = Array.prototype.slice.call(document.querySelectorAll('.preset'));
    presetBtns.forEach(function (btn) {
      btn.addEventListener('click', function () {
        const p = HABIT_PRESETS[+btn.dataset.preset];
        document.getElementById('newName').value = p.name;
        type = p.type;
        opts.forEach(function (b) { b.classList.toggle('on', b.dataset.type === type); });
        document.getElementById('meterFields').hidden = type !== 'meter';
        document.getElementById('periodicFields').hidden = type !== 'periodic';
        if (type === 'meter') {
          document.getElementById('newGoal').value = p.goal || 8;
          document.getElementById('newUnit').value = p.unit || '次';
        }
        if (type === 'periodic') {
          document.getElementById('newInterval').value = p.interval || 180;
        }
        presetBtns.forEach(function (b) { b.classList.toggle('on', b === btn); });
      });
    });

    const input = document.getElementById('newName');
    document.getElementById('createHabit').addEventListener('click', function () {
      const name = input.value.trim();
      if (!name) {
        toast('先给项目起个名字');
        input.focus();
        return;
      }
      if (habits.some(function (h) { return h.name === name; })) {
        toast('已经有同名项目了');
        return;
      }

      const habit = {
        id: 'custom_' + Date.now(),
        name: name,
        type: type,
        required: false,
        enabled: true,
        createdAt: todayKey(),
        sensitive: false
      };
      if (type === 'meter') {
        habit.goal = Math.max(1, parseInt(document.getElementById('newGoal').value, 10) || 8);
        habit.unit = (document.getElementById('newUnit').value.trim() || '次').slice(0, 2);
        habit.step = 1;
      }
      if (type === 'periodic') {
        habit.interval = Math.min(3650, Math.max(1,
          parseInt(document.getElementById('newInterval').value, 10) || 180));
      }
      habits.push(habit);
      saveHabits();
      closeSheet();
      render();
      toast('已添加「' + name + '」');
    });
  }

  function openClearSheet() {
    openSheet(
      '<div class="sheet-grip"></div>' +
      '<h3 class="sheet-title">清除全部数据</h3>' +
      '<p class="sheet-desc">将删除所有打卡记录与设置，且不可恢复。确定要继续吗？</p>' +
      '<button class="btn-primary btn-danger" id="clearOk">确认清除</button>' +
      '<button class="btn-text" data-close>取消</button>'
    );
    document.getElementById('clearOk').addEventListener('click', clearAll);
  }

  /* =========================================================
   * 设置与数据
   * ======================================================= */

  function applyTheme() {
    const valid = THEMES.filter(function (t) { return t.key === settings.theme; })[0];
    const info = valid || THEMES[0];

    // 旧主题（如森绿）已移除，回落到默认色并写回设置
    if (!valid) {
      settings.theme = info.key;
      saveSettings();
    }

    document.documentElement.setAttribute('data-theme', info.key);

    const meta = document.querySelector('meta[name="theme-color"]');
    if (meta) meta.setAttribute('content', info.bg);
  }

  function toggleSetting(key) {
    if (key === 'appLockEnabled') {
      if (settings.appLockEnabled) {
        settings.appLockEnabled = false;
        settings.pin = '';
        saveSettings();
        render();
        toast('应用锁已关闭');
      } else {
        openPinSetupSheet();
      }
      return;
    }

    settings[key] = !settings[key];
    saveSettings();
    render();

    if (key === 'periodEnabled' && settings[key] && !settings.periodStart) {
      openPeriodSheet();
    }
  }

  function toggleHabit(id) {
    const h = habits.find(function (x) { return x.id === id; });
    if (!h || h.required) return;
    h.enabled = !h.enabled;
    saveHabits();
    render();
  }

  function clearAll() {
    localStorage.removeItem(HABITS_KEY);
    localStorage.removeItem(RECORDS_KEY);
    localStorage.removeItem(SETTINGS_KEY);
    loadState();
    activeTab = 'today';
    detailHabitId = null;
    calCursor = startOfMonth(todayKey());
    saveAll();
    closeSheet();
    render();
    toast('已清除全部数据');
  }

  function openPinSetupSheet() {
    openSheet(
      '<div class="sheet-grip"></div>' +
      '<h3 class="sheet-title">设置应用锁密码</h3>' +
      '<p class="sheet-desc">4 位数字，仅保存在本机，每次打开应用时验证</p>' +
      '<div class="field"><label class="field-label">输入密码</label>' +
        '<input class="text-input" id="pin1" type="password" inputmode="numeric" maxlength="4" placeholder="4 位数字">' +
      '</div>' +
      '<div class="field"><label class="field-label">再次输入</label>' +
        '<input class="text-input" id="pin2" type="password" inputmode="numeric" maxlength="4" placeholder="4 位数字">' +
      '</div>' +
      '<button class="btn-primary" id="savePin">开启应用锁</button>' +
      '<button class="btn-text" data-close>取消</button>'
    );

    document.getElementById('savePin').addEventListener('click', function () {
      const a = document.getElementById('pin1').value.trim();
      const b = document.getElementById('pin2').value.trim();

      if (!/^\d{4}$/.test(a)) {
        toast('请输入 4 位数字密码');
        return;
      }
      if (a !== b) {
        toast('两次输入的密码不一致');
        return;
      }

      settings.pin = a;
      settings.appLockEnabled = true;
      saveSettings();
      closeSheet();
      render();
      toast('应用锁已开启，下次打开时生效');
    });
  }

  let lockEntry = '';

  function paintLockDots() {
    const dots = document.querySelectorAll('#lockDots i');
    dots.forEach(function (dot, i) {
      dot.classList.toggle('on', i < lockEntry.length);
    });
  }

  function lockInput(key) {
    if (key === 'del') {
      lockEntry = lockEntry.slice(0, -1);
    } else if (lockEntry.length < 4) {
      lockEntry += key;
    }
    paintLockDots();

    if (lockEntry.length !== 4) return;

    if (lockEntry === settings.pin) {
      unlocked = true;
      lockEntry = '';
      paintLockDots();
      syncLock();
      return;
    }

    const dots = document.getElementById('lockDots');
    dots.classList.add('shake');
    setTimeout(function () { dots.classList.remove('shake'); }, 420);

    lockEntry = '';
    paintLockDots();
    document.getElementById('lockDesc').textContent = '密码不对，再试一次';
  }

  function syncLock() {
    const show = !!settings.appLockEnabled && !unlocked;
    if (show) {
      lockEntry = '';
      paintLockDots();
      document.getElementById('lockDesc').textContent = '输入 4 位密码解锁';
    }
    document.getElementById('lockScreen').classList.toggle('show', show);
  }

  /* =========================================================
   * 卡片背景
   * ======================================================= */

  let bgInput = null;

  function pickBackground(id) {
    if (!bgInput) {
      bgInput = document.createElement('input');
      bgInput.type = 'file';
      bgInput.accept = 'image/*';
      bgInput.style.display = 'none';
      document.body.appendChild(bgInput);
    }

    bgInput.value = '';
    bgInput.onchange = function () {
      const file = bgInput.files && bgInput.files[0];
      if (!file) return;
      if (file.size > 8 * 1024 * 1024) {
        toast('图片太大了，换一张试试');
        return;
      }

      compressImage(file, function (dataUrl) {
        const h = habits.find(function (x) { return x.id === id; });
        if (!h) return;
        h.bg = dataUrl;
        saveHabits();
        renderDetail();
        if (detailHabitId === id) openCardSettings(id);
        toast('卡片背景已更新');
      });
    };

    bgInput.click();
  }

  function clearBackground(id) {
    const h = habits.find(function (x) { return x.id === id; });
    if (!h) return;
    delete h.bg;
    saveHabits();
    renderDetail();
    if (detailHabitId === id) openCardSettings(id);
    toast('已移除背景');
  }

  // 压缩后再存，避免占满 localStorage
  function compressImage(file, cb) {
    const reader = new FileReader();
    reader.onload = function () {
      const img = new Image();
      img.onload = function () {
        const maxW = 640;
        const scale = Math.min(1, maxW / img.width);
        const w = Math.round(img.width * scale);
        const hgt = Math.round(img.height * scale);
        const cv = document.createElement('canvas');
        cv.width = w;
        cv.height = hgt;
        cv.getContext('2d').drawImage(img, 0, 0, w, hgt);
        cb(cv.toDataURL('image/jpeg', 0.72));
      };
      img.src = reader.result;
    };
    reader.readAsDataURL(file);
  }

  /* =========================================================
   * 事件绑定
   * ======================================================= */

  function bindEvents() {
    document.getElementById('view').addEventListener('click', function (e) {
      const el = e.target.closest('[data-action]');
      if (!el) return;
      const action = el.dataset.action;
      const id = el.dataset.id;

      if (action === 'check') checkIn(id);
      else if (action === 'undo') undoToday(id);
      else if (action === 'add-amount') addAmount(id);
      else if (action === 'undo-amount') undoAmount(id);
      else if (action === 'slip') openSlipSheet(id);
      else if (action === 'open-card-settings') openCardSettings(id);
      else if (action === 'open-period') openPeriodSheet();
      else if (action === 'add-habit') openAddSheet();
      else if (action === 'open-detail') {
        detailHabitId = id;
        render();
        document.getElementById('view').scrollTop = 0;
      } else if (action === 'back') {
        detailHabitId = null;
        render();
        document.getElementById('view').scrollTop = 0;
      }
      else if (action === 'cal-prev') {
        calCursor = new Date(calCursor.getFullYear(), calCursor.getMonth() - 1, 1);
        render();
      } else if (action === 'cal-next') {
        calCursor = new Date(calCursor.getFullYear(), calCursor.getMonth() + 1, 1);
        render();
      } else if (action === 'toggle-habit') toggleHabit(id);
      else if (action === 'set-mode') {
        settings.strictMode = el.dataset.mode === 'strict';
        saveSettings();
        render();
      } else if (action === 'toggle-setting') toggleSetting(el.dataset.key);
      else if (action === 'set-gender') {
        settings.gender = el.dataset.gender;
        if (settings.gender === 'male') settings.periodEnabled = false;
        saveSettings();
        render();
        toast(settings.gender === 'male' ? '已切换为男性，经期功能已关闭' : '已切换为女性');
      } else if (action === 'set-theme') {
        settings.theme = el.dataset.theme;
        saveSettings();
        applyTheme();
        render();
      }
      else if (action === 'clear') openClearSheet();
    });

    document.getElementById('view').addEventListener('change', function (e) {
      if (e.target.dataset.action !== 'reminder-time') return;
      settings.reminderTime = e.target.value || '22:45';
      saveSettings();
      toast('提醒时间已更新');
    });

    document.getElementById('tabbar').addEventListener('click', function (e) {
      const btn = e.target.closest('[data-tab]');
      if (!btn) return;
      if (btn.dataset.tab === activeTab) {
        if (activeTab === 'today' && detailHabitId) {
          detailHabitId = null;
          render();
          document.getElementById('view').scrollTop = 0;
        }
        return;
      }
      activeTab = btn.dataset.tab;
      detailHabitId = null;
      render();
      document.getElementById('view').scrollTop = 0;
    });

    document.getElementById('lockKeys').addEventListener('click', function (e) {
      const btn = e.target.closest('[data-digit]');
      if (!btn) return;
      lockInput(btn.dataset.digit);
    });
  }

  /* =========================================================
   * 启动
   * ======================================================= */

  loadState();
  applyTheme();
  bindEvents();
  render();

})();
