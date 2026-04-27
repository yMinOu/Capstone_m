/// 역할: 단어장 화면의 탭 전환, 목록 표시, 필터 헤더 및 화면 조립을 담당합니다.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/vocabulary/data/models/learning_progress_model.dart';
import 'package:nihongo/features/vocabulary/data/models/word_filter_model.dart';
import 'package:nihongo/features/vocabulary/presentation/providers/vocabulary_provider.dart';
import 'package:nihongo/features/vocabulary/presentation/screens/vocabulary_detail_screen.dart';
import 'package:nihongo/features/vocabulary/presentation/screens/word_detail_screen.dart';
import 'package:nihongo/features/vocabulary/presentation/utils/word_filter_utils.dart';
import 'package:nihongo/features/vocabulary/presentation/widgets/vocabulary_card_widget.dart';
import 'package:nihongo/features/vocabulary/presentation/widgets/vocabulary_create_dialog.dart';
import 'package:nihongo/features/vocabulary/presentation/widgets/word_filter_bottom_sheet_widget.dart';
import 'package:nihongo/features/vocabulary/presentation/widgets/word_list_item_widget.dart';

class VocabularyScreen extends ConsumerStatefulWidget {
  const VocabularyScreen({super.key});

  @override
  ConsumerState<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends ConsumerState<VocabularyScreen> {
  bool _isVocabularyTab = true;
  WordFilterState _filterState = const WordFilterState();
  late final ScrollController _wordScrollController;

  @override
  void initState() {
    super.initState();
    _wordScrollController = ScrollController()..addListener(_onWordScroll);
  }

  @override
  void dispose() {
    _wordScrollController
      ..removeListener(_onWordScroll)
      ..dispose();
    super.dispose();
  }

  void _onWordScroll() {
    if (_isVocabularyTab || !_wordScrollController.hasClients) {
      return;
    }

    final position = _wordScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 250) {
      ref.read(learningProgressPagingProvider.notifier).loadMore();
    }
  }

  void _openLearningProgressTab() {
    setState(() {
      _isVocabularyTab = false;
    });

    Future.microtask(() {
      ref.read(learningProgressPagingProvider.notifier).refreshOnTabOpen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vocabularyListAsync = ref.watch(vocabularyListProvider);

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
                    title: '학습한 단어',
                    isSelected: !_isVocabularyTab,
                    onTap: _openLearningProgressTab,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isVocabularyTab
                  ? vocabularyListAsync.when(
                data: (list) {
                  final sortedList = [...list]
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  return sortedList.isEmpty
                      ? const _VocabularyEmptyView()
                      : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    itemCount: sortedList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) => VocabularyCardWidget(
                      vocabulary: sortedList[index],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VocabularyDetailScreen(
                            vocabulary: sortedList[index],
                          ),
                        ),
                      ),
                      onDelete: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              surfaceTintColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text(
                                '단어장 삭제',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              content: const Text(
                                '단어장을 지우겠습니까?',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF555555),
                                ),
                              ),
                              actions: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext, false),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          side: const BorderSide(
                                            color: Color(0xFFD9D9D9),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('취소'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('삭제'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldDelete == true) {
                          ref
                              .read(vocabularyActionProvider.notifier)
                              .deleteVocabulary(
                            vocabularyId: sortedList[index].id,
                          );
                        }
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('에러가 발생했습니다: $err')),
              )
                  : _buildLearningProgressTab(),
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
          icon: Image.asset(
            'assets/images/common/word.png',
            width: 35,
            height: 35,
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
              color: Color(0xFFFFCCCC),
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

  Widget _buildLearningProgressTab() {
    final pagingState = ref.watch(learningProgressPagingProvider);

    if (!pagingState.initialized || pagingState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final filteredWords = applyWordFilters(
      words: pagingState.items,
      filterState: _filterState,
    );

    return Column(
      children: [
        _WordFilterHeader(
          hasActiveFilters: _filterState.hasActiveFilters,
          filterLabels: buildSelectedFilterLabels(_filterState),
          onTapFilter: _openWordFilterSheet,
          onRemoveLabel: _removeFilterByLabel,
          onClearAll: _resetFilters,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () {
              return ref
                  .read(learningProgressPagingProvider.notifier)
                  .refreshOnlyNew();
            },
            child: filteredWords.isEmpty
                ? ListView(
              controller: _wordScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(
                  child: Text('조건에 맞는 단어가 없습니다.'),
                ),
              ],
            )
                : ListView.builder(
              controller: _wordScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount:
              filteredWords.length + (pagingState.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= filteredWords.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final word = filteredWords[index];
                return WordListItemWidget(
                  word: word,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyWordDetailScreen(
                        progress: word,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _resetFilters() {
    setState(() {
      _filterState = const WordFilterState();
    });
  }

  void _removeFilterByLabel(String label) {
    setState(() {
      _filterState = removeFilterByLabel(
        filterState: _filterState,
        label: label,
      );
    });
  }

  void _openWordFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return WordFilterBottomSheetWidget(
          initialState: _filterState,
          onApply: (nextState) {
            setState(() {
              _filterState = nextState;
            });
          },
        );
      },
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
              color: isSelected ? const Color(0xFFFFCCCC) : Colors.transparent,              width: 2,
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
    return const Center(
      child: Text('아직 만든 단어장이 없습니다.'),
    );
  }
}

class _WordFilterHeader extends StatelessWidget {
  const _WordFilterHeader({
    required this.hasActiveFilters,
    required this.filterLabels,
    required this.onTapFilter,
    required this.onRemoveLabel,
    required this.onClearAll,
  });

  final bool hasActiveFilters;
  final List<String> filterLabels;
  final VoidCallback onTapFilter;
  final void Function(String label) onRemoveLabel;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: onTapFilter,
            icon: const Icon(Icons.tune, size: 16, color: Color(0xFFD37B7B),),
            label: const Text(
              '필터',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF222222),
              backgroundColor: Colors.white,
              side: const BorderSide(
                color: Color(0xFFFFCCCC),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          if (hasActiveFilters) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onClearAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '초기화',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (filterLabels.isNotEmpty) ...[
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filterLabels
                      .map(
                        (label) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _SelectedFilterChip(
                        label: label,
                        onRemove: () => onRemoveLabel(label),
                      ),
                    ),
                  )
                      .toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SelectedFilterChip extends StatelessWidget {
  const _SelectedFilterChip({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD8D8D8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}