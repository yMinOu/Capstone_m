/// 통계 화면에서 사용할 약한 영역 분석 위젯.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nihongo/features/stats/data/models/stats_model.dart';

class StatsWeakAreaWidget extends StatefulWidget {
  final int animationSeed;
  final List<StatsWeakAreaItem> items;
  final String message;

  const StatsWeakAreaWidget({
    super.key,
    this.animationSeed = 0,
    required this.items,
    required this.message,
  });

  @override
  State<StatsWeakAreaWidget> createState() => _StatsWeakAreaWidgetState();
}

class _StatsWeakAreaWidgetState extends State<StatsWeakAreaWidget>
    with SingleTickerProviderStateMixin {
  static const double _chartWidth = 360;
  static const double _chartHeight = 320;

  late final AnimationController _fillAnimationController;
  late final Animation<double> _fillAnimation;

  ScrollPosition? _scrollPosition;
  bool _isCurrentlyVisible = false;
  bool _hasPlayedVisibleAnimation = false;
  int? _selectedIndex;

  List<StatsWeakAreaItem> get _safeItems => widget.items.length == 6
      ? widget.items
      : const [
    StatsWeakAreaItem(label: '단어', weaknessPercent: 30),
    StatsWeakAreaItem(label: '한자', weaknessPercent: 30),
    StatsWeakAreaItem(label: '예문', weaknessPercent: 30),
    StatsWeakAreaItem(label: '가타카나', weaknessPercent: 30),
    StatsWeakAreaItem(label: '히라가나', weaknessPercent: 30),
    StatsWeakAreaItem(label: '스피킹', weaknessPercent: 30),
  ];

  @override
  void initState() {
    super.initState();

    _fillAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _fillAnimation = CurvedAnimation(
      parent: _fillAnimationController,
      curve: Curves.easeOutQuart,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attachScrollListener();
      _checkVisibilityAndAnimate();
    });
  }

  @override
  void didUpdateWidget(covariant StatsWeakAreaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animationSeed != widget.animationSeed) {
      _selectedIndex = null;
      _isCurrentlyVisible = false;
      _hasPlayedVisibleAnimation = false;
      _fillAnimationController.reset();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibilityAndAnimate();
    });
  }

  void _attachScrollListener() {
    final position = Scrollable.of(context)?.position;
    if (_scrollPosition == position) {
      return;
    }

    _scrollPosition?.removeListener(_checkVisibilityAndAnimate);
    _scrollPosition = position;
    _scrollPosition?.addListener(_checkVisibilityAndAnimate);
  }

  void _checkVisibilityAndAnimate() {
    if (!mounted) {
      return;
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final widgetTop = renderObject.localToGlobal(Offset.zero).dy;
    final widgetBottom = widgetTop + renderObject.size.height;

    final visibleTopLimit = screenHeight * 0.92;
    final visibleBottomLimit = screenHeight * 0.12;

    final isVisibleNow =
        widgetTop < visibleTopLimit && widgetBottom > visibleBottomLimit;

    if (isVisibleNow && !_isCurrentlyVisible) {
      _isCurrentlyVisible = true;

      if (!_hasPlayedVisibleAnimation) {
        _hasPlayedVisibleAnimation = true;
        _fillAnimationController.forward(from: 0);
      }
      return;
    }

    if (!isVisibleNow && _isCurrentlyVisible) {
      _isCurrentlyVisible = false;
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_checkVisibilityAndAnimate);
    _fillAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _safeItems;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFD9D9D9),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '약한 영역 분석',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          AnimatedBuilder(
            animation: _fillAnimation,
            builder: (context, child) {
              final pointCenters = _RadarChartLayout.calculatePointCenters(
                size: const Size(_chartWidth, _chartHeight),
                items: items,
                progress: _fillAnimation.value,
              );

              return SizedBox(
                height: 340,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final chartLeft = math.max(
                      0.0,
                      (constraints.maxWidth - _chartWidth) / 2,
                    );
                    const chartTop = 8.0;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: chartLeft,
                          top: chartTop,
                          child: SizedBox(
                            width: _chartWidth,
                            height: _chartHeight,
                            child: CustomPaint(
                              painter: _RadarChartPainter(
                                items: items,
                                progress: _fillAnimation.value,
                              ),
                            ),
                          ),
                        ),
                        ...List.generate(items.length, (index) {
                          final point = pointCenters[index];

                          return Positioned(
                            left: chartLeft + point.dx - 14,
                            top: chartTop + point.dy - 14,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                setState(() {
                                  if (_selectedIndex == index) {
                                    _selectedIndex = null;
                                  } else {
                                    _selectedIndex = index;
                                  }
                                });
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                color: Colors.transparent,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        if (_selectedIndex != null)
                          _buildTooltip(
                            constraints: constraints,
                            chartLeft: chartLeft,
                            chartTop: chartTop,
                            point: pointCenters[_selectedIndex!],
                            score: items[_selectedIndex!].weaknessPercent,
                          ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Text(
                  '💡',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF444444),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltip({
    required BoxConstraints constraints,
    required double chartLeft,
    required double chartTop,
    required Offset point,
    required int score,
  }) {
    const tooltipWidth = 52.0;

    final desiredLeft = chartLeft + point.dx + 10;
    final desiredTop = chartTop + point.dy - 15;

    final left = desiredLeft
        .clamp(0.0, math.max(0.0, constraints.maxWidth - tooltipWidth))
        .toDouble();

    final top = desiredTop.clamp(0.0, 280.0).toDouble();

    return Positioned(
      left: left,
      top: top,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '$score',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _RadarChartLayout {
  static const double centerTopPadding = 18;
  static const int sideCount = 6;

  static List<Offset> calculatePointCenters({
    required Size size,
    required List<StatsWeakAreaItem> items,
    required double progress,
  }) {
    final center = Offset(
      size.width / 2,
      size.height / 2 + centerTopPadding,
    );
    final radius = math.min(size.width, size.height) * 0.42;

    return List.generate(items.length, (index) {
      final finalRatio = (items[index].weaknessPercent.clamp(0, 100)) / 100;
      final animatedRatio = finalRatio * progress;

      return _pointForIndex(
        center: center,
        radius: radius * animatedRatio,
        index: index,
        sideCount: sideCount,
      );
    });
  }

  static Offset _pointForIndex({
    required Offset center,
    required double radius,
    required int index,
    required int sideCount,
  }) {
    final angle = (-math.pi / 2) + (2 * math.pi * index / sideCount);
    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<StatsWeakAreaItem> items;
  final double progress;

  const _RadarChartPainter({
    required this.items,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2 + _RadarChartLayout.centerTopPadding,
    );
    final radius = math.min(size.width, size.height) * 0.42;
    const sideCount = _RadarChartLayout.sideCount;

    final gridPaint = Paint()
      ..color = const Color(0xFFE1E1E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..color = const Color(0xFFE1E1E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final fillPaint = Paint()
      ..color = const Color(0xFF8C8C8C).withOpacity(0.45)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final pointPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    for (int level = 1; level <= 4; level++) {
      final scale = level / 4;
      final path = Path();

      for (int i = 0; i < sideCount; i++) {
        final point = _pointForIndex(
          center: center,
          radius: radius * scale,
          index: i,
          sideCount: sideCount,
        );

        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }

      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (int i = 0; i < sideCount; i++) {
      final point = _pointForIndex(
        center: center,
        radius: radius,
        index: i,
        sideCount: sideCount,
      );
      canvas.drawLine(center, point, axisPaint);
    }

    final dataPath = Path();
    final dataPoints = <Offset>[];

    for (int i = 0; i < items.length; i++) {
      final finalRatio = (items[i].weaknessPercent.clamp(0, 100)) / 100;
      final animatedRatio = finalRatio * progress;

      final point = _pointForIndex(
        center: center,
        radius: radius * animatedRatio,
        index: i,
        sideCount: sideCount,
      );

      dataPoints.add(point);

      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }

    dataPath.close();
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    for (final point in dataPoints) {
      canvas.drawCircle(point, 4, pointPaint);
    }

    for (int i = 0; i < items.length; i++) {
      final outerPoint = _pointForIndex(
        center: center,
        radius: radius + 28,
        index: i,
        sideCount: sideCount,
      );

      _drawLabel(
        canvas,
        text: items[i].label,
        center: outerPoint,
      );
    }
  }

  Offset _pointForIndex({
    required Offset center,
    required double radius,
    required int index,
    required int sideCount,
  }) {
    final angle = (-math.pi / 2) + (2 * math.pi * index / sideCount);
    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  }

  void _drawLabel(
      Canvas canvas, {
        required String text,
        required Offset center,
      }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF777777),
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    if (oldDelegate.progress != progress) {
      return true;
    }

    if (oldDelegate.items.length != items.length) {
      return true;
    }

    for (int i = 0; i < items.length; i++) {
      if (oldDelegate.items[i].label != items[i].label ||
          oldDelegate.items[i].weaknessPercent != items[i].weaknessPercent) {
        return true;
      }
    }

    return false;
  }
}