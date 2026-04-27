/// 통계 화면 하단의 일간/주간/월간 학습 시간 그래프 위젯.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nihongo/features/stats/data/models/stats_model.dart';

enum StatsChartPeriod {
  daily,
  weekly,
  monthly,
}

class StatsChartWidget extends StatefulWidget {
  final int animationSeed;
  final StatsChartPeriod selectedPeriod;
  final ValueChanged<StatsChartPeriod> onPeriodChanged;
  final List<StatsChartItem> dailyItems;
  final List<StatsChartItem> weeklyItems;
  final List<StatsChartItem> monthlyItems;

  const StatsChartWidget({
    super.key,
    required this.animationSeed,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.dailyItems,
    required this.weeklyItems,
    required this.monthlyItems,
  });

  @override
  State<StatsChartWidget> createState() => _StatsChartWidgetState();
}

class _StatsChartWidgetState extends State<StatsChartWidget> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant StatsChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedPeriod != widget.selectedPeriod) {
      _selectedIndex = null;
    }

    if (oldWidget.animationSeed != widget.animationSeed) {
      _selectedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = switch (widget.selectedPeriod) {
      StatsChartPeriod.daily => widget.dailyItems,
      StatsChartPeriod.weekly => widget.weeklyItems,
      StatsChartPeriod.monthly => widget.monthlyItems,
    };

    final title = switch (widget.selectedPeriod) {
      StatsChartPeriod.daily => '일일 학습 시간',
      StatsChartPeriod.weekly => '주간 학습 시간',
      StatsChartPeriod.monthly => '월간 학습 시간',
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(
          color: const Color(0xFFFFCCCC),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PeriodTabBar(
            selectedPeriod: widget.selectedPeriod,
            onPeriodChanged: widget.onPeriodChanged,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '그래프를 클릭하면 학습 시간을 확인할 수 있어요',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF7A7A7A),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeOut,
            child: _AnimatedBarChart(
              key: ValueKey(
                '${widget.selectedPeriod.name}_${widget.animationSeed}',
              ),
              items: items,
              selectedIndex: _selectedIndex,
              onItemTap: (index) {
                setState(() {
                  if (_selectedIndex == index) {
                    _selectedIndex = null;
                    return;
                  }
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodTabBar extends StatelessWidget {
  final StatsChartPeriod selectedPeriod;
  final ValueChanged<StatsChartPeriod> onPeriodChanged;

  const _PeriodTabBar({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFCCCC),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PeriodTabButton(
              title: '일간',
              isSelected: selectedPeriod == StatsChartPeriod.daily,
              onTap: () => onPeriodChanged(StatsChartPeriod.daily),
            ),
          ),
          Expanded(
            child: _PeriodTabButton(
              title: '주간',
              isSelected: selectedPeriod == StatsChartPeriod.weekly,
              onTap: () => onPeriodChanged(StatsChartPeriod.weekly),
            ),
          ),
          Expanded(
            child: _PeriodTabButton(
              title: '월간',
              isSelected: selectedPeriod == StatsChartPeriod.monthly,
              onTap: () => onPeriodChanged(StatsChartPeriod.monthly),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodTabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodTabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF8989) : Colors.transparent,          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
            const BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFFD37B7B),          ),
        ),
      ),
    );
  }
}

class _AnimatedBarChart extends StatelessWidget {
  final List<StatsChartItem> items;
  final int? selectedIndex;
  final ValueChanged<int> onItemTap;

  const _AnimatedBarChart({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = _resolveMaxValue(items);

    return SizedBox(
      height: 300,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const yAxisWidth = 34.0;
          const gapBetweenAxisAndChart = 8.0;
          const minBarSlotWidth = 44.0; // 막대 1개당 최소 너비
          const chartHorizontalPadding = 4.0;

          final chartAreaWidth =
          math.max(
            constraints.maxWidth - yAxisWidth - gapBetweenAxisAndChart,
            items.length * minBarSlotWidth,
          );

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: yAxisWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    final value = ((maxValue * (4 - index)) / 4).round();
                    return Text(
                      '$value',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7A7A7A),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: gapBetweenAxisAndChart),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: chartAreaWidth,
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            5,
                                (_) => Container(
                              height: 1,
                              color: const Color(0xFFE9E9E9),
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final isSelected = selectedIndex == index;

                            return SizedBox(
                              width: chartAreaWidth / items.length,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: chartHorizontalPadding,
                                ),
                                child: _AnimatedBarItem(
                                  index: index,
                                  label: item.label,
                                  value: item.value,
                                  maxValue: maxValue,
                                  isSelected: isSelected,
                                  onTap: () => onItemTap(index),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  int _resolveMaxValue(List<StatsChartItem> items) {
    final rawMax = items.isEmpty
        ? 100
        : items.map((e) => e.value).reduce(math.max);

    if (rawMax <= 0) {
      return 100;
    }

    final rounded = ((rawMax / 4).ceil()) * 4;
    final headroom = math.max((rounded * 0.2).ceil(), 2);

    return math.max(rounded + headroom, 4);
  }
}

class _AnimatedBarItem extends StatelessWidget {
  final int index;
  final String label;
  final int value;
  final int maxValue;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedBarItem({
    required this.index,
    required this.label,
    required this.value,
    required this.maxValue,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxValue == 0 ? 0.0 : value / maxValue;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;
                final barTopOffset =
                (ratio.clamp(0.0, 1.0) * availableHeight);
                final tooltipBottom = barTopOffset + 5;

                return Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
                        duration: Duration(milliseconds: 750 + (index * 100)),
                        curve: Curves.easeOutCubic,
                        builder: (context, animatedRatio, child) {
                          return FractionallySizedBox(
                            heightFactor: animatedRatio,
                            alignment: Alignment.bottomCenter,
                            child: child,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFF8989)
                                : const Color(0xFFFFCCCC),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected
                                ? [
                              const BoxShadow(
                                color: Color(0x18000000),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ]
                                : null,
                            border: isSelected
                                ? Border.all(
                              color: const Color(0xFFFF8989),                              width: 2,
                            )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        bottom: tooltipBottom,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8989),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF8989).withOpacity(0.25),                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '$value분',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.black : const Color(0xFF666666),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}