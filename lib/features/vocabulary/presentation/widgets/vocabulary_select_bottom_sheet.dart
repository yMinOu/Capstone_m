import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/vocabulary/data/models/learning_content_model.dart';
import 'package:nihongo/features/vocabulary/presentation/providers/vocabulary_provider.dart';
import 'package:nihongo/features/vocabulary/presentation/widgets/vocabulary_create_dialog.dart';

class VocabularySelectBottomSheet extends ConsumerWidget {
  const VocabularySelectBottomSheet({
    super.key,
    required this.content,
  });

  final LearningContentModel content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabularyListAsync = ref.watch(vocabularyListProvider);
    final isLoading = ref.watch(wordLoadingProvider);
    final rootMessenger = ScaffoldMessenger.of(
      Navigator.of(context, rootNavigator: true).context,
    );

    return SafeArea(
      child: vocabularyListAsync.when(
        loading: () => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, _) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Center(
            child: Text('단어장 목록을 불러오지 못했습니다.\n$err'),
          ),
        ),
        data: (vocabularies) {
          final screenHeight = MediaQuery.of(context).size.height;

          // 대충 헤더/여백 높이
          const headerHeight = 130.0;

          // 리스트 한 줄 높이 + 간격
          const itemHeight = 72.0;
          const itemSpacing = 10.0;
          const bottomPadding = 24.0;

          final listHeight = vocabularies.isEmpty
              ? 140.0
              : (vocabularies.length * itemHeight) +
              ((vocabularies.length - 1) * itemSpacing) +
              bottomPadding;

          final desiredHeight = headerHeight + listHeight + 20;

          final maxHeight = screenHeight * 0.85;
          final minHeight = screenHeight * 0.28;

          final sheetHeight = desiredHeight.clamp(minHeight, maxHeight);

          return Container(
            height: sheetHeight,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '저장할 단어장 선택',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      content.content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: vocabularies.isEmpty
                      ? ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      const SizedBox(height: 24),
                      const Center(
                        child: Text(
                          '아직 만든 단어장이 없습니다.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) =>
                              const VocabularyCreateDialog(),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('단어장 만들기'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: Color(0xFFBEBEBE),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: vocabularies.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final vocabulary = vocabularies[index];

                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: isLoading
                              ? null
                              : () async {
                            final success = await ref
                                .read(wordActionProvider.notifier)
                                .addLearningContentToVocabulary(
                              vocabularyId: vocabulary.id,
                              content: content,
                            );

                            if (!context.mounted) {
                              return;
                            }

                            final actionState =
                            ref.read(wordActionProvider);

                            if (success) {
                              Navigator.of(context).pop();
                              rootMessenger
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${vocabulary.title}에 저장되었습니다.',
                                    ),
                                  ),
                                );
                              return;
                            }

                            final rawErrorMessage = actionState.whenOrNull(
                              error: (error, _) => error.toString(),
                            );

                            final errorMessage = rawErrorMessage == null
                                ? '단어 저장에 실패했습니다.'
                                : rawErrorMessage.replaceFirst('Exception: ', '');

                            Navigator.of(context).pop();

                            rootMessenger
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage),
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                ),
                              );
                          },
                          child: Container(
                            height: itemHeight,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFD9D9D9),
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/common/word.png',
                                  width: 80,
                                  height: 80,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        vocabulary.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${vocabulary.wordCount}개 단어',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF888888),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF9A9A9A),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}