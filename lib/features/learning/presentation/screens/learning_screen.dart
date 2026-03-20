import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/learning/presentation/providers/learning_provider.dart';

class LearningScreen extends ConsumerWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(learningProvider);

    return Scaffold(
      body: Center(
        child: Text(
          text,
        ),
      ),
    );
  }
}