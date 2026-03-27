/// 통계 화면에서 사용할 학습 통계 모델.
class StatsModel {
  final int totalStudySeconds;
  final int totalStudyCount;
  final int learnedCount;
  final int streakDays;

  const StatsModel({
    required this.totalStudySeconds,
    required this.totalStudyCount,
    required this.learnedCount,
    required this.streakDays,
  });

  factory StatsModel.empty() {
    return const StatsModel(
      totalStudySeconds: 0,
      totalStudyCount: 0,
      learnedCount: 0,
      streakDays: 0,
    );
  }
}