import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/vocabulary/data/models/learning_progress_model.dart';
import 'package:nihongo/features/vocabulary/data/models/vocabulary_model.dart';
import 'package:nihongo/features/vocabulary/presentation/providers/vocabulary_provider.dart';
import 'package:nihongo/features/vocabulary/presentation/screens/word_detail_screen.dart';
import 'package:nihongo/features/vocabulary/presentation/screens/vocabulary_detail_screen.dart';
import 'package:nihongo/features/vocabulary/presentation/widgets/word_list_item_widget.dart';
import 'package:nihongo/features/vocabulary/presentation/widgets/vocabulary_card_widget.dart';
import 'package:nihongo/features/vocabulary/presentation/widgets/vocabulary_create_dialog.dart';

class VocabularyScreen extends ConsumerStatefulWidget {
  const VocabularyScreen({super.key});

  @override
  ConsumerState<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends ConsumerState<VocabularyScreen> {
  bool _isVocabularyTab = true;

  @override
  Widget build(BuildContext context) {
    final vocabularyListAsync = ref.watch(vocabularyListProvider);
    final learningProgressAsync = ref.watch(learningProgressListProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _TopTabButton(
                    title: '단어장',
                    isSelected: _isVocabularyTab,
                    onTap: () => setState(() => _isVocabularyTab = true),
                  ),
                  const SizedBox(width: 20),
                  _TopTabButton(
                    title: '단어',
                    isSelected: !_isVocabularyTab,
                    onTap: () => setState(() => _isVocabularyTab = false),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isVocabularyTab
                  ? vocabularyListAsync.when(
                data: (list) => list.isEmpty
                    ? const _VocabularyEmptyView()
                    : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) => VocabularyCardWidget(
                    vocabulary: list[index],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VocabularyDetailScreen(
                          vocabulary: list[index],
                        ),
                      ),
                    ),
                    onDelete: () {
                      ref.read(vocabularyActionProvider.notifier).deleteVocabulary(
                        vocabularyId: list[index].id,
                      );
                    },
                  ),
                ),
                loading: () =>
                const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('에러가 발생했습니다: $err')),
              )
                  : learningProgressAsync.when(
                data: (words) => words.isEmpty
                    ? const Center(child: Text('학습 중인 단어가 없습니다.'))
                    : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    final word = words[index];
                    return WordListItemWidget(
                      word: word,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MyWordDetailScreen(progress: word),
                        ),
                      ),
                    );
                  },
                ),
                loading: () =>
                const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('에러가 발생했습니다: $err')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isVocabularyTab
          ? SizedBox(
        height: 42,
        child: OutlinedButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const VocabularyCreateDialog(),
          ),
          icon: const Icon(
            Icons.menu_book_outlined,
            size: 18,
          ),
          label: const Text(
            '단어장 생성',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF222222),
            backgroundColor: Colors.white,
            side: const BorderSide(
              color: Color(0xFFBEBEBE),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18),
          ),
        ),
      )
          : null,
    );
  }
}

class _TopTabButton extends StatelessWidget {
  const _TopTabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 14, bottom: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.black : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.black : const Color(0xFF8A8A8A),
          ),
        ),
      ),
    );
  }
}
class _VocabularyEmptyView extends StatelessWidget {
  const _VocabularyEmptyView();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('아직 만든 단어장이 없습니다.'));
  }
}