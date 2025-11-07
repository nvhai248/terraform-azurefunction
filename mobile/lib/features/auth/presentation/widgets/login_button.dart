import 'package:flutter/material.dart';
import 'package:mobile/core/config/theme/app_colors.dart';
import 'package:mobile/core/config/theme/text_styles.dart';
import 'package:mobile/shared/widgets/loading_indicator.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const LoginButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.white.withOpacity(0.7),
          disabledForegroundColor: AppColors.primary.withOpacity(0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CustomLoadingIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Signing In...',
                    style: AppTextStyles.buttonLarge,
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Microsoft logo
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: CustomPaint(
                      painter: MicrosoftLogoPainter(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Continue with Microsoft',
                    style: AppTextStyles.buttonLarge,
                  ),
                ],
              ),
      ),
    );
  }
}

class MicrosoftLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final squareSize = size.width / 2.2;
    final gap = size.width * 0.1;

    // Orange square (top-left)
    paint.color = const Color(0xFFF25022);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, squareSize, squareSize),
      paint,
    );

    // Green square (top-right)
    paint.color = const Color(0xFF7FBA00);
    canvas.drawRect(
      Rect.fromLTWH(squareSize + gap, 0, squareSize, squareSize),
      paint,
    );

    // Blue square (bottom-left)
    paint.color = const Color(0xFF00A4EF);
    canvas.drawRect(
      Rect.fromLTWH(0, squareSize + gap, squareSize, squareSize),
      paint,
    );

    // Yellow square (bottom-right)
    paint.color = const Color(0xFFFFB900);
    canvas.drawRect(
      Rect.fromLTWH(squareSize + gap, squareSize + gap, squareSize, squareSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}