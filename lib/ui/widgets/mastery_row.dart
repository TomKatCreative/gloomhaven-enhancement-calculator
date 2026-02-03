import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/check_row_divider.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/conditional_checkbox.dart';
import 'package:provider/provider.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/mastery.dart';
import 'package:gloomhaven_enhancement_calc/utils/utils.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';

class MasteryRow extends StatefulWidget {
  final Character character;
  final Mastery mastery;

  const MasteryRow({super.key, required this.character, required this.mastery});

  @override
  MasteryRowState createState() => MasteryRowState();
}

class MasteryRowState extends State<MasteryRow>
    with SingleTickerProviderStateMixin {
  double height = 0;
  late AnimationController _borderController;
  late Animation<double> _borderAnimation;
  bool _wasAchieved = false;
  bool _isDrawing = true; // true = drawing border, false = erasing border

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _borderAnimation = CurvedAnimation(
      parent: _borderController,
      curve: Curves.easeOut,
    );
    // Initialize state
    _wasAchieved = _isAchieved;
    if (_wasAchieved) {
      _borderController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  bool get _isAchieved => widget.character.characterMasteries
      .firstWhere((mastery) => mastery.associatedMasteryId == widget.mastery.id)
      .characterMasteryAchieved;

  @override
  Widget build(BuildContext context) {
    CharactersModel charactersModel = context.watch<CharactersModel>();

    // Check for state change and trigger animation
    final isNowAchieved = _isAchieved;
    if (isNowAchieved != _wasAchieved) {
      _wasAchieved = isNowAchieved;
      if (isNowAchieved) {
        // Draw the border
        _isDrawing = true;
        _borderController.forward(from: 0.0);
      } else {
        // Erase the border in the same direction
        _isDrawing = false;
        _borderController.forward(from: 0.0);
      }
    }

    final borderColor = Theme.of(context).colorScheme.secondary;
    final subtleBorderColor = Theme.of(context).dividerTheme.color!;

    return Container(
      margin: const EdgeInsets.only(right: 6, left: 1),
      child: AnimatedBuilder(
        animation: _borderAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _AnimatedBorderPainter(
              progress: _borderAnimation.value,
              color: borderColor,
              subtleBorderColor: subtleBorderColor,
              borderRadius: 4.0,
              isDrawing: _isDrawing,
            ),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: tinyPadding),
          child: Row(
            children: <Widget>[
              ConditionalCheckbox(
                value: widget.character.characterMasteries
                    .firstWhere(
                      (mastery) =>
                          mastery.associatedMasteryId == widget.mastery.id,
                    )
                    .characterMasteryAchieved,
                isEditMode: charactersModel.isEditMode,
                isRetired: widget.character.isRetired,
                onChanged: (bool value) => charactersModel.toggleMastery(
                  characterMasteries: widget.character.characterMasteries,
                  mastery: widget.character.characterMasteries.firstWhere(
                    (mastery) =>
                        mastery.associatedMasteryId == widget.mastery.id,
                  ),
                  value: value,
                ),
              ),
              CheckRowDivider(
                height: height,
                color:
                    widget.character.characterMasteries
                        .firstWhere(
                          (mastery) =>
                              mastery.associatedMasteryId == widget.mastery.id,
                        )
                        .characterMasteryAchieved
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).dividerTheme.color,
              ),
              SizeProviderWidget(
                onChildSize: (Size? size) {
                  if (size != null && context.mounted) {
                    setState(() {
                      height = size.height * 0.9;
                    });
                  }
                },
                child: Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: smallPadding),
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(letterSpacing: 0.7),
                        children: Utils.generateCheckRowDetails(
                          context,
                          widget.mastery.masteryDetails,
                          Theme.of(context).brightness == Brightness.dark,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter that draws an animated border around a rounded rectangle.
/// Always draws a subtle border for grouping, then animates a colored border
/// on top when complete. The border draws progressively starting from the
/// middle of the left edge (aligned with the checkbox) and going clockwise.
/// When erasing, the border disappears in the same direction (tail chases head).
class _AnimatedBorderPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color subtleBorderColor;
  final double borderRadius;
  final bool isDrawing;

  _AnimatedBorderPainter({
    required this.progress,
    required this.color,
    required this.subtleBorderColor,
    required this.borderRadius,
    required this.isDrawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = borderRadius;
    final w = size.width;
    final h = size.height;
    final midY = h / 2;

    // Build the rounded rectangle path
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(r),
    );

    // Always draw the subtle border first
    final subtlePaint = Paint()
      ..color = subtleBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, subtlePaint);

    // Draw animated colored border on top
    if ((progress <= 0 && isDrawing) || (progress >= 1 && !isDrawing)) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Build path starting from middle of left edge, going clockwise
    final path = Path()
      // Start at middle of left edge
      ..moveTo(0, midY)
      // Go up to top-left corner
      ..lineTo(0, r)
      // Top-left corner arc
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      // Top edge
      ..lineTo(w - r, 0)
      // Top-right corner arc
      ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
      // Right edge
      ..lineTo(w, h - r)
      // Bottom-right corner arc
      ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
      // Bottom edge
      ..lineTo(r, h)
      // Bottom-left corner arc
      ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
      // Back up to middle of left edge
      ..lineTo(0, midY);

    // Get path metrics to extract partial path
    final pathMetrics = path.computeMetrics().first;
    final totalLength = pathMetrics.length;

    // Extract the appropriate portion of the path
    final Path partialPath;
    if (isDrawing) {
      // Drawing: start at 0, end grows with progress
      final drawLength = totalLength * progress;
      partialPath = pathMetrics.extractPath(0, drawLength);
    } else {
      // Erasing: start grows with progress, end stays at totalLength
      final startLength = totalLength * progress;
      partialPath = pathMetrics.extractPath(startLength, totalLength);
    }

    canvas.drawPath(partialPath, paint);
  }

  @override
  bool shouldRepaint(_AnimatedBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.subtleBorderColor != subtleBorderColor ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.isDrawing != isDrawing;
  }
}
