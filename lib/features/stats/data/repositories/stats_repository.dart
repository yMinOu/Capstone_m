/// Firestore에서 사용자 통계 데이터를 불러오는 Repository.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nihongo/features/stats/data/models/stats_model.dart';

class StatsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StatsRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  Future<StatsModel> fetchStats() async {
    final user = _auth.currentUser;

    if (user == null) {
      return StatsModel.empty();
    }

    final uid = user.uid;
    final now = DateTime.now();
    final todayKey = _formatDateKey(now);

    final userDoc = await _firestore.collection('users').doc(uid).get();

    final dailyDoc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('daily_stats')
        .doc(todayKey)
        .get();

    final chartStartDate = DateTime(now.year, now.month - 5, 1);
    final dailyStatsMap = await _fetchDailyStatsMap(
      uid: uid,
      startDate: chartStartDate,
      endDate: now,
    );

    final userData = userDoc.data() ?? {};
    final dailyData = dailyDoc.data() ?? {};

    final totalStudySeconds =
        (userData['totalStudySeconds'] as num?)?.toInt() ?? 0;

    final totalStudyCount =
        (userData['totalStudyCount'] as num?)?.toInt() ?? 0;

    final todayLearnedCount =
        (dailyData['learnedCount'] as num?)?.toInt() ?? 0;

    final streakDays =
        (userData['streakDays'] as num?)?.toInt() ?? 0;

    return StatsModel(
      totalStudySeconds: totalStudySeconds,
      totalStudyCount: totalStudyCount,
      learnedCount: todayLearnedCount,
      streakDays: streakDays,
      dailyChart: _buildDailyChart(now, dailyStatsMap),
      weeklyChart: _buildWeeklyChart(now, dailyStatsMap),
      monthlyChart: _buildMonthlyChart(now, dailyStatsMap),
    );
  }

  Future<Map<String, int>> _fetchDailyStatsMap({
    required String uid,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final startKey = _formatDateKey(startDate);
    final endKey = _formatDateKey(endDate);

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('daily_stats')
        .orderBy(FieldPath.documentId)
        .startAt([startKey])
        .endAt([endKey])
        .get();

    final Map<String, int> result = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final seconds = (data['studySeconds'] as num?)?.toInt() ?? 0;
      result[doc.id] = seconds;
    }

    return result;
  }

  List<StatsChartItem> _buildDailyChart(
      DateTime now,
      Map<String, int> dailyStatsMap,
      ) {
    final List<StatsChartItem> items = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day).subtract(
        Duration(days: i),
      );
      final key = _formatDateKey(date);
      final seconds = dailyStatsMap[key] ?? 0;

      items.add(
        StatsChartItem(
          label: _weekdayLabel(date.weekday),
          value: (seconds / 60).round(),
        ),
      );
    }

    return items;
  }

  List<StatsChartItem> _buildWeeklyChart(
      DateTime now,
      Map<String, int> dailyStatsMap,
      ) {
    final List<StatsChartItem> items = [];
    final currentWeekMonday = _startOfWeek(now);

    for (int i = 4; i >= 0; i--) {
      final weekStart = currentWeekMonday.subtract(Duration(days: i * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));

      int totalSeconds = 0;

      for (int d = 0; d < 7; d++) {
        final date = weekStart.add(Duration(days: d));
        final key = _formatDateKey(date);
        totalSeconds += dailyStatsMap[key] ?? 0;
      }

      final label = i == 0 ? '이번주' : '${i}주전';

      items.add(
        StatsChartItem(
          label: label,
          value: (totalSeconds / 60).round(),
        ),
      );
    }

    return items;
  }

  List<StatsChartItem> _buildMonthlyChart(
      DateTime now,
      Map<String, int> dailyStatsMap,
      ) {
    final List<StatsChartItem> items = [];

    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final year = monthDate.year;
      final month = monthDate.month;

      int totalSeconds = 0;

      dailyStatsMap.forEach((key, seconds) {
        final date = DateTime.parse(key);
        if (date.year == year && date.month == month) {
          totalSeconds += seconds;
        }
      });

      items.add(
        StatsChartItem(
          label: '$month월',
          value: (totalSeconds / 60).round(),
        ),
      );
    }

    return items;
  }

  DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  String _formatDateKey(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return '월';
      case DateTime.tuesday:
        return '화';
      case DateTime.wednesday:
        return '수';
      case DateTime.thursday:
        return '목';
      case DateTime.friday:
        return '금';
      case DateTime.saturday:
        return '토';
      case DateTime.sunday:
        return '일';
      default:
        return '';
    }
  }
}