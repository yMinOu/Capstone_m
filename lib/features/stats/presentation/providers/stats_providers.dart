/// 통계 화면에서 사용할 Riverpod Provider 모음.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/stats/data/repositories/stats_repository.dart';
import 'package:nihongo/features/stats/data/models/stats_model.dart';

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

final statsProvider = FutureProvider<StatsModel>((ref) async {
  final repository = ref.read(statsRepositoryProvider);
  return repository.fetchStats();
});