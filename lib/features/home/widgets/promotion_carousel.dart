import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';

class Promotion {
  const Promotion({
    required this.title,
    required this.description,
    required this.imageAsset,
  });

  final String title;
  final String description;
  final String imageAsset;
}

// Demo offers: replace these with your own promotion content when available.
const homePromotions = [
  Promotion(
    title: 'Double Points Weekend',
    description: 'Earn 2x points on all purchases this weekend!',
    imageAsset: 'assets/images/promotion_photo_1.jpg',
  ),
  Promotion(
    title: 'Coffee & Rewards',
    description: 'Enjoy your favourite coffee and collect points.',
    imageAsset: 'assets/images/promotion_photo_2.png',
  ),
  Promotion(
    title: 'Member Specials',
    description: 'Discover something special on your next visit.',
    imageAsset: 'assets/images/promotion_photo_3.png',
  ),
];

class PromotionCarousel extends StatefulWidget {
  const PromotionCarousel({super.key});

  @override
  State<PromotionCarousel> createState() => _PromotionCarouselState();
}

class _PromotionCarouselState extends State<PromotionCarousel> {
  final _controller = PageController();
  int _currentPage = 0;
  Timer? _autoSwipe;

  @override
  void initState() {
    super.initState();
    _autoSwipe = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_controller.hasClients) return;
      final next = (_currentPage + 1) % homePromotions.length;
      _controller.animateToPage(next, duration: const Duration(milliseconds: 450), curve: Curves.easeInOutCubic);
    });
  }

  @override
  void dispose() {
    _autoSwipe?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _selectPage(int index) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(index);
    } else {
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        double measure(String text, TextStyle style) {
          final painter = TextPainter(
            text: TextSpan(
              text: text,
              style: DefaultTextStyle.of(context).style.merge(style),
            ),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout(maxWidth: math.max(1, constraints.maxWidth - 40));
          final height = painter.height;
          painter.dispose();
          return height;
        }

        final height = homePromotions.fold<double>(
          200,
          (height, promotion) => math.max(
            height,
            measure(promotion.title, _titleStyle) +
                measure(promotion.description, _descriptionStyle) +
                74,
          ),
        );
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: homePromotions.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) =>
                      _PromotionSlide(promotion: homePromotions[index]),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(homePromotions.length, (index) {
                      final selected = index == _currentPage;
                      return Semantics(
                        label:
                            'Promotion ${index + 1} of ${homePromotions.length}',
                        button: true,
                        selected: selected,
                        child: Tooltip(
                          message: 'Show ${homePromotions[index].title}',
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _selectPage(index),
                            child: SizedBox(
                              width: 24,
                              height: 48,
                              child: Center(
                                child: AnimatedContainer(
                                  duration: reduceMotion
                                      ? Duration.zero
                                      : const Duration(milliseconds: 250),
                                  curve: Curves.easeOutCubic,
                                  width: selected ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha: selected ? 1 : .5,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

const _titleStyle = TextStyle(
  color: Colors.white,
  fontSize: 16,
  fontWeight: FontWeight.w700,
);
const _descriptionStyle = TextStyle(
  color: Color(0xE6FFFFFF),
  fontSize: 12,
  height: 1.5,
);

class _PromotionSlide extends StatelessWidget {
  const _PromotionSlide({required this.promotion});

  final Promotion promotion;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Image.asset(
        promotion.imageAsset,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
      ),
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x22000000), Color(0xCC000000)],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(promotion.title, style: _titleStyle),
            const SizedBox(height: 6),
            Text(promotion.description, style: _descriptionStyle),
          ],
        ),
      ),
    ],
  );
}
