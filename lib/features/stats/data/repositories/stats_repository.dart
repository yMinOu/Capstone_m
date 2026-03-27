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
    final todayKey = _buildTodayKey();

    final userDoc = await _firestore.collection('users').doc(uid).get();

    final dailyDoc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('daily_stats')
        .doc(todayKey)
        .get();

    final userData = userDoc.data() ?? {};
    final dailyData = dailyDoc.data() ?? {};

    // 전체 학습 시간
    final totalStudySeconds =
        (userData['totalStudySeconds'] as num?)?.toInt() ?? 0;

    // 전체 학습 카드
    final totalStudyCount =
        (userData['totalStudyCount'] as num?)?.toInt() ?? 0;

    // 오늘 학습 시간
    final todayStudyCount = dailyData['learnedCount'] is num
        ? (dailyData['learnedCount'] as num).toInt()
        : 0;

    // 연속 학습일
    final streakDays =
        (userData['streakDays'] as num?)?.toInt() ?? 0;


    return StatsModel(
      totalStudySeconds: totalStudySeconds,
      totalStudyCount: totalStudyCount,
      learnedCount: todayStudyCount,
      streakDays: streakDays,
    );
  }

  // 오늘 날짜 문서 찾는 키 생성기
  String _buildTodayKey() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}