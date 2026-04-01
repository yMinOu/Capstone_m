/// 역할: 단어 필터 선택용 바텀시트 UI를 제공합니다.
import 'package:flutter/material.dart';
import 'package:nihongo/features/vocabulary/data/models/word_filter_model.dart';

class WordFilterBottomSheetWidget extends StatefulWidget {
  const WordFilterBottomSheetWidget({
    super.key,
    required this.initialState,
    required this.onApply,
  });

  final WordFilterState initialState;
  final ValueChanged<WordFilterState> onApply;

  @override
  State<WordFilterBottomSheetWidget> createState() =>
      _WordFilterBottomSheetWidgetState();
}

class _WordFilterBottomSheetWidgetState
    extends State<WordFilterBottomSheetWidget> {
  late Set<WordFilterGroup> _tempGroups;
  late Set<WordFilterType> _tempTypes;
  late Set<WordFilterStatus> _tempStatuses;
  late WordFilterDateRange _tempDateRange;

  @override
  void initState() {
    super.initState();
    _tempGroups = {...widget.initialState.selectedGroups};
    _tempTypes = {...widget.initialState.selectedTypes};
    _tempStatuses = {...widget.initialState.selectedStatuses};
    _tempDateRange = widget.initialState.selectedDateRange;
  }

  void _toggleGroup(WordFilterGroup group) {
    setState(() {
      if (_tempGroups.contains(group)) {
        _tempGroups.remove(group);
      } else {
        _tempGroups.add(group);
      }
    });
  }

  void _toggleType(WordFilterType type) {
    setState(() {
      if (_tempTypes.contains(type)) {
        _tempTypes.remove(type);
      } else {
        _tempTypes.add(type);
      }
    });
  }

  void _toggleStatus(WordFilterStatus status) {
    setState(() {
      if (_tempStatuses.contains(status)) {
        _tempStatuses.remove(status);
      } else {
        _tempStatuses.add(status);
      }
    });
  }

  void _resetAll() {
    setState(() {
      _tempGroups.clear();
      _tempTypes.clear();
      _tempStatuses.clear();
      _tempDateRange = WordFilterDateRange.all;
    });
  }

  void _apply() {
    widget.onApply(
      WordFilterState(
        selectedGroups: _tempGroups,
        selectedTypes: _tempTypes,
        selectedStatuses: _tempStatuses,
        selectedDateRange: _tempDateRange,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.5,
        maxChildSize: 0.85,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '단어 필터',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '카테고리',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChipButton(
                      label: '전체',
                      selected: _tempGroups.isEmpty,
                      onTap: () {
                        setState(() {
                          _tempGroups.clear();
                        });
                      },
                    ),
                    _FilterChipButton(
                      label: WordFilterGroup.jlptN5.label,
                      selected: _tempGroups.contains(WordFilterGroup.jlptN5),
                      onTap: () => _toggleGroup(WordFilterGroup.jlptN5),
                    ),
                    _FilterChipButton(
                      label: WordFilterGroup.jlptN4.label,
                      selected: _tempGroups.contains(WordFilterGroup.jlptN4),
                      onTap: () => _toggleGroup(WordFilterGroup.jlptN4),
                    ),
                    _FilterChipButton(
                      label: WordFilterGroup.jlptN3.label,
                      selected: _tempGroups.contains(WordFilterGroup.jlptN3),
                      onTap: () => _toggleGroup(WordFilterGroup.jlptN3),
                    ),
                    _FilterChipButton(
                      label: WordFilterGroup.jlptN2.label,
                      selected: _tempGroups.contains(WordFilterGroup.jlptN2),
                      onTap: () => _toggleGroup(WordFilterGroup.jlptN2),
                    ),
                    _FilterChipButton(
                      label: WordFilterGroup.jlptN1.label,
                      selected: _tempGroups.contains(WordFilterGroup.jlptN1),
                      onTap: () => _toggleGroup(WordFilterGroup.jlptN1),
                    ),
                    _FilterChipButton(
                      label: WordFilterGroup.hiragana.label,
                      selected: _tempGroups.contains(WordFilterGroup.hiragana),
                      onTap: () => _toggleGroup(WordFilterGroup.hiragana),
                    ),
                    _FilterChipButton(
                      label: WordFilterGroup.katakana.label,
                      selected: _tempGroups.contains(WordFilterGroup.katakana),
                      onTap: () => _toggleGroup(WordFilterGroup.katakana),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '유형',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChipButton(
                      label: '전체',
                      selected: _tempTypes.isEmpty,
                      onTap: () {
                        setState(() {
                          _tempTypes.clear();
                        });
                      },
                    ),
                    _FilterChipButton(
                      label: WordFilterType.word.label,
                      selected: _tempTypes.contains(WordFilterType.word),
                      onTap: () => _toggleType(WordFilterType.word),
                    ),
                    _FilterChipButton(
                      label: WordFilterType.kanji.label,
                      selected: _tempTypes.contains(WordFilterType.kanji),
                      onTap: () => _toggleType(WordFilterType.kanji),
                    ),
                    _FilterChipButton(
                      label: WordFilterType.sentence.label,
                      selected: _tempTypes.contains(WordFilterType.sentence),
                      onTap: () => _toggleType(WordFilterType.sentence),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '상태',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChipButton(
                      label: '전체',
                      selected: _tempStatuses.isEmpty,
                      onTap: () {
                        setState(() {
                          _tempStatuses.clear();
                        });
                      },
                    ),
                    _FilterChipButton(
                      label: WordFilterStatus.know.label,
                      selected: _tempStatuses.contains(WordFilterStatus.know),
                      onTap: () => _toggleStatus(WordFilterStatus.know),
                    ),
                    _FilterChipButton(
                      label: WordFilterStatus.dontKnow.label,
                      selected: _tempStatuses.contains(
                        WordFilterStatus.dontKnow,
                      ),
                      onTap: () => _toggleStatus(WordFilterStatus.dontKnow),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '날짜',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChipButton(
                      label: WordFilterDateRange.all.label,
                      selected: _tempDateRange == WordFilterDateRange.all,
                      onTap: () {
                        setState(() {
                          _tempDateRange = WordFilterDateRange.all;
                        });
                      },
                    ),
                    _FilterChipButton(
                      label: WordFilterDateRange.today.label,
                      selected: _tempDateRange == WordFilterDateRange.today,
                      onTap: () {
                        setState(() {
                          _tempDateRange = WordFilterDateRange.today;
                        });
                      },
                    ),
                    _FilterChipButton(
                      label: WordFilterDateRange.week.label,
                      selected: _tempDateRange == WordFilterDateRange.week,
                      onTap: () {
                        setState(() {
                          _tempDateRange = WordFilterDateRange.week;
                        });
                      },
                    ),
                    _FilterChipButton(
                      label: WordFilterDateRange.month.label,
                      selected: _tempDateRange == WordFilterDateRange.month,
                      onTap: () {
                        setState(() {
                          _tempDateRange = WordFilterDateRange.month;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetAll,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(
                            color: Color(0xFFBEBEBE),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          '초기화',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _apply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          '적용하기',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = selected ? Colors.black : Colors.white;
    final foregroundColor = selected ? Colors.white : Colors.black87;
    final borderColor = selected ? Colors.black : const Color(0xFFBEBEBE);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: foregroundColor,
          ),
        ),
      ),
    );
  }
}