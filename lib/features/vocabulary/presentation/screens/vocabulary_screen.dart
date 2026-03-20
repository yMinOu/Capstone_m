import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/vocabulary/presentation/providers/vocabulary_providers.dart';
class VocabularyScreen extends ConsumerWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(vocabularyProvider);

    return Scaffold(
      body: Center(
        child: Text(
          text,
        ),
      ),
    );
  }
}
