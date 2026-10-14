import 'dart:math' as math;

import 'package:flutter/material.dart';

class Promotion {
  const Promotion({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  final String title;
  final String description;
  final String imageUrl;
}

// Demo offers: replace these with your own promotion content when available.
const homePromotions = [
  Promotion(
    title: 'Double Points Weekend',
    description: 'Earn 2x points on all purchases this weekend!',
    imageUrl: 'https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=900&q=80',
  ),
  Promotion(
    title: 'Coffee & Rewards',
    description: 'Enjoy your favourite coffee and collect points.',
    imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=900&q=80',
  ),
  Promotion(
    title: 'Member Specials',
    description: 'Discover something special on your next visit.',
    imageUrl: 'https://images.unsplash.com/photo-1513201099705-a9746e1e201f?auto=format&fit=crop&w=900&q=80',
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

  @override
  void dispose() {
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
                              width: 48,
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

  Widget _fallback() => Image.asset(
    'assets/images/promotion_photo.jpg',
    fit: BoxFit.cover,
    excludeFromSemantics: true,
  );

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Image.network(
        promotion.imageUrl,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _fallback(),
        errorBuilder: (context, error, stackTrace) => _fallback(),
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
