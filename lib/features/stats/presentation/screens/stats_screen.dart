import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/stats/presentation/providers/stats_providers.dart';
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(statsProvider);

    return Scaffold(
      body: Center(
        child: Text(
          text,
        ),
      ),
    );
  }
}
