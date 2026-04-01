/// 역할: 단어 필터 적용, 라벨 생성, 라벨 제거용 상태 계산 로직을 제공합니다.
import 'package:nihongo/features/vocabulary/data/models/learning_progress_model.dart';
import 'package:nihongo/features/vocabulary/data/models/word_filter_model.dart';

List<LearningProgressModel> applyWordFilters({
  required List<LearningProgressModel> words,
  required WordFilterState filterState,
}) {
  return words.where((word) {
    if (!_matchesGroup(word, filterState.selectedGroups)) {
      return false;
    }
    if (!_matchesType(word, filterState)) {
      return false;
    }
    if (!_matchesStatus(word, filterState.selectedStatuses)) {
      return false;
    }
    if (!_matchesDate(word, filterState.selectedDateRange)) {
      return false;
    }
    return true;
  }).toList();
}

List<String> buildSelectedFilterLabels(WordFilterState filterState) {
  final labels = <String>[];

  for (final group in filterState.selectedGroups) {
    labels.add(group.label);
  }

  for (final type in filterState.selectedTypes) {
    labels.add(type.label);
  }

  for (final status in filterState.selectedStatuses) {
    labels.add(status.label);
  }

  if (filterState.selectedDateRange != WordFilterDateRange.all) {
    labels.add(filterState.selectedDateRange.label);
  }

  return labels;
}

WordFilterState removeFilterByLabel({
  required WordFilterState filterState,
  required String label,
}) {
  final nextGroups = {...filterState.selectedGroups}
    ..removeWhere((group) => group.label == label);

  final nextTypes = {...filterState.selectedTypes}
    ..removeWhere((type) => type.label == label);

  final nextStatuses = {...filterState.selectedStatuses}
    ..removeWhere((status) => status.label == label);

  var nextDateRange = filterState.selectedDateRange;
  if (nextDateRange.label == label) {
    nextDateRange = WordFilterDateRange.all;
  }

  return filterState.copyWith(
    selectedGroups: nextGroups,
    selectedTypes: nextTypes,
    selectedStatuses: nextStatuses,
    selectedDateRange: nextDateRange,
  );
}

bool _matchesGroup(
    LearningProgressModel word,
    Set<WordFilterGroup> selectedGroups,
    ) {
  if (selectedGroups.isEmpty) {
    return true;
  }

  for (final group in selectedGroups) {
    switch (group) {
      case WordFilterGroup.jlptN5:
        if (word.subCategory == 'N5') return true;
        break;
      case WordFilterGroup.jlptN4:
        if (word.subCategory == 'N4') return true;
        break;
      case WordFilterGroup.jlptN3:
        if (word.subCategory == 'N3') return true;
        break;
      case WordFilterGroup.jlptN2:
        if (word.subCategory == 'N2') return true;
        break;
      case WordFilterGroup.jlptN1:
        if (word.subCategory == 'N1') return true;
        break;
      case WordFilterGroup.hiragana:
        if (word.category == 'hiragana') return true;
        break;
      case WordFilterGroup.katakana:
        if (word.category == 'katakana') return true;
        break;
    }
  }

  return false;
}

bool _matchesType(
    LearningProgressModel word,
    WordFilterState filterState,
    ) {
  final effectiveTypes = _effectiveContentTypes(filterState);

  if (effectiveTypes.isEmpty) {
    return true;
  }

  return effectiveTypes.contains(word.contentType);
}

Set<String> _effectiveContentTypes(WordFilterState filterState) {
  final result = <String>{};

  for (final type in filterState.selectedTypes) {
    switch (type) {
      case WordFilterType.word:
        result.add('word');
        break;
      case WordFilterType.kanji:
        result.add('kanji');
        break;
      case WordFilterType.sentence:
        result.add('sentence');
        break;
    }
  }

  if (filterState.hasCharacterCategorySelected) {
    result.add('character');
  }

  return result;
}

bool _matchesStatus(
    LearningProgressModel word,
    Set<WordFilterStatus> selectedStatuses,
    ) {
  if (selectedStatuses.isEmpty) {
    return true;
  }

  final allowedStatuses = <String>{};

  for (final status in selectedStatuses) {
    switch (status) {
      case WordFilterStatus.know:
        allowedStatuses.add('know');
        break;
      case WordFilterStatus.dontKnow:
        allowedStatuses.add('dontKnow');
        break;
    }
  }

  return allowedStatuses.contains(word.status);
}

bool _matchesDate(
    LearningProgressModel word,
    WordFilterDateRange selectedDateRange,
    ) {
  if (selectedDateRange == WordFilterDateRange.all) {
    return true;
  }

  final date = word.updatedAt ?? word.lastStudiedAt;
  if (date == null) {
    return false;
  }

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);

  switch (selectedDateRange) {
    case WordFilterDateRange.all:
      return true;
    case WordFilterDateRange.today:
      return !date.isBefore(todayStart);
    case WordFilterDateRange.week:
      return !date.isBefore(now.subtract(const Duration(days: 7)));
    case WordFilterDateRange.month:
      return !date.isBefore(now.subtract(const Duration(days: 30)));
  }
}