import 'dart:ui';
import 'package:flutter/material.dart';

/// Modern Frosted Glass Card with BackdropFilter blur, specular border, and ambient shadow
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final double opacity;
  final Color? tintColor;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final BoxBorder? customBorder;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.blur = 16,
    this.opacity = 0.68,
    this.tintColor,
    this.borderColor = Colors.white,
    this.borderWidth = 1.4,
    this.onTap,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (tintColor ?? Colors.white).withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: customBorder ??
                Border.all(
                  color: borderColor.withValues(alpha: 0.85),
                  width: borderWidth,
                ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.45),
                blurRadius: 0,
                offset: const Offset(0, 0),
                spreadRadius: 0.6,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    if (onTap != null) {
      card = GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }
}

/// Ambient mesh glow background that allows frosted glass cards to clearly blur and refract
class GlassAmbientBackground extends StatelessWidget {
  final Widget child;

  const GlassAmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base modern slate canvas
        Positioned.fill(
          child: Container(
            color: const Color(0xFFF1F5F9),
          ),
        ),
        // Top-Right Emerald Mint Ambient Glow Orb
        Positioned(
          top: -60,
          right: -50,
          child: IgnorePointer(
            child: Container(
              width: 290,
              height: 290,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.24),
                    const Color(0xFF10B981).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Middle-Left Warm Mango/Peach Ambient Glow Orb
        Positioned(
          top: 230,
          left: -80,
          child: IgnorePointer(
            child: Container(
              width: 310,
              height: 310,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF9F0A).withValues(alpha: 0.20),
                    const Color(0xFFFF9F0A).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Lower-Right Electric Cyan Ambient Glow Orb
        Positioned(
          bottom: 120,
          right: -60,
          child: IgnorePointer(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF38BDF8).withValues(alpha: 0.18),
                    const Color(0xFF38BDF8).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Child Content
        child,
      ],
    );
  }
}
