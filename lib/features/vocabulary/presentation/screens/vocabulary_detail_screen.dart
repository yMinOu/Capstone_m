import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/vocabulary/data/models/vocabulary_model.dart';
import 'package:nihongo/features/vocabulary/presentation/providers/vocabulary_provider.dart';
import 'package:nihongo/features/vocabulary/presentation/widgets/vocabulary_word_list_item_widget.dart';
import 'package:nihongo/features/vocabulary/presentation/widgets/word_add_dialog.dart';
import 'package:nihongo/features/vocabulary/presentation/screens/vocabulary_word_detail_screen.dart';

class VocabularyDetailScreen extends ConsumerWidget {
  const VocabularyDetailScreen({
    super.key,
    required this.vocabulary,
  });

  final VocabularyModel vocabulary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(vocabularyWordsProvider(vocabulary.id));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Text(
          vocabulary.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: wordsAsync.when(
        data: (words) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: [
                    Text(
                      '단어 ${words.length}개',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF444444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    _ActionChip(
                      icon: Icons.shuffle_outlined,
                      label: '섞기',
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _ActionChip(
                      icon: Icons.extension_outlined,
                      label: '퀴즈',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              Expanded(
                child: words.isEmpty
                    ? const Center(
                  child: Text('단어가 없습니다.'),
                )
                    : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    final word = words[index];
                    return VocabularyWordListItemWidget(
                      word: word,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VocabularyWordDetailScreen(word: word),
                          ),
                        );
                      },
                      onDelete: () => ref
                          .read(wordActionProvider.notifier)
                          .deleteWord(
                        vocabularyId: vocabulary.id,
                        wordId: word.id,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, _) => Center(
          child: Text('에러: $err'),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: const BorderSide(color: Color(0xFFBEBEBE)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.black87),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}