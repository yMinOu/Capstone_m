/// 역할: 단어 필터 관련 enum, 상태 모델, 라벨 변환을 정의합니다.
import 'package:flutter/foundation.dart';

enum WordFilterGroup {
  jlptN5,
  jlptN4,
  jlptN3,
  jlptN2,
  jlptN1,
  hiragana,
  katakana,
}

enum WordFilterType {
  word,
  kanji,
  sentence,
}

enum WordFilterStatus {
  know,
  dontKnow,
}

enum WordFilterDateRange {
  all,
  today,
  week,
  month,
}

@immutable
class WordFilterState {
  const WordFilterState({
    this.selectedGroups = const <WordFilterGroup>{},
    this.selectedTypes = const <WordFilterType>{},
    this.selectedStatuses = const <WordFilterStatus>{},
    this.selectedDateRange = WordFilterDateRange.all,
  });

  final Set<WordFilterGroup> selectedGroups;
  final Set<WordFilterType> selectedTypes;
  final Set<WordFilterStatus> selectedStatuses;
  final WordFilterDateRange selectedDateRange;

  bool get hasActiveFilters =>
      selectedGroups.isNotEmpty ||
          selectedTypes.isNotEmpty ||
          selectedStatuses.isNotEmpty ||
          selectedDateRange != WordFilterDateRange.all;

  bool get hasCharacterCategorySelected =>
      selectedGroups.contains(WordFilterGroup.hiragana) ||
          selectedGroups.contains(WordFilterGroup.katakana);

  WordFilterState copyWith({
    Set<WordFilterGroup>? selectedGroups,
    Set<WordFilterType>? selectedTypes,
    Set<WordFilterStatus>? selectedStatuses,
    WordFilterDateRange? selectedDateRange,
  }) {
    return WordFilterState(
      selectedGroups: selectedGroups ?? this.selectedGroups,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      selectedStatuses: selectedStatuses ?? this.selectedStatuses,
      selectedDateRange: selectedDateRange ?? this.selectedDateRange,
    );
  }
}

extension WordFilterGroupLabelX on WordFilterGroup {
  String get label {
    switch (this) {
      case WordFilterGroup.jlptN5:
        return 'JLPT N5';
      case WordFilterGroup.jlptN4:
        return 'JLPT N4';
      case WordFilterGroup.jlptN3:
        return 'JLPT N3';
      case WordFilterGroup.jlptN2:
        return 'JLPT N2';
      case WordFilterGroup.jlptN1:
        return 'JLPT N1';
      case WordFilterGroup.hiragana:
        return '히라가나';
      case WordFilterGroup.katakana:
        return '가타카나';
    }
  }
}

extension WordFilterTypeLabelX on WordFilterType {
  String get label {
    switch (this) {
      case WordFilterType.word:
        return '단어';
      case WordFilterType.kanji:
        return '한자';
      case WordFilterType.sentence:
        return '예문';
    }
  }
}

extension WordFilterStatusLabelX on WordFilterStatus {
  String get label {
    switch (this) {
      case WordFilterStatus.know:
        return '알아요';
      case WordFilterStatus.dontKnow:
        return '몰라요';
    }
  }
}

extension WordFilterDateRangeLabelX on WordFilterDateRange {
  String get label {
    switch (this) {
      case WordFilterDateRange.all:
        return '전체';
      case WordFilterDateRange.today:
        return '오늘';
      case WordFilterDateRange.week:
        return '일주일';
      case WordFilterDateRange.month:
        return '한달';
    }
  }
}