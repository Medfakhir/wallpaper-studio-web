import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wallpaper_model.dart';

class WallpaperPainter extends CustomPainter {
  final WallpaperModel config;
  final ui.Image? backgroundImage;
  final ui.Image? foregroundImage;
  final DateTime currentTime;
  final bool showSelection;

  // Base resolution (same as mobile)
  static const double baseWidth = 1080.0;
  static const double baseHeight = 1920.0;

  WallpaperPainter({
    required this.config,
    this.backgroundImage,
    this.foregroundImage,
    required this.currentTime,
    this.showSelection = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Clear canvas
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1C1C1E),
    );

    // Draw background image
    if (backgroundImage != null) {
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.width, size.height),
        image: backgroundImage!,
        fit: BoxFit.cover,
      );
    }

    // Draw clock
    if (config.clock.enabled) {
      _drawClock(canvas, size);
    }

    // Draw foreground image
    if (foregroundImage != null) {
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.width, size.height),
        image: foregroundImage!,
        fit: BoxFit.cover,
      );
    }

    // Draw selection box if needed
    if (showSelection && config.clock.enabled) {
      _drawSelectionBox(canvas, size);
    }
  }

  void _drawClock(Canvas canvas, Size size) {
    final fontSize = size.height * config.clock.sizeRatio;
    final x = size.width * config.clock.position.x;
    final y = size.height * config.clock.position.y;

    // Format time
    final hours = currentTime.hour.toString().padLeft(2, '0');
    final minutes = currentTime.minute.toString().padLeft(2, '0');
    final timeText = config.clock.format == 'HH:mm' ? '$hours:$minutes' : '$hours$minutes';

    if (config.clock.splitDigits) {
      // Split digits layout
      final hoursText = timeText.substring(0, 2);
      final minutesText = timeText.substring(timeText.length - 2);

      _drawStyledText(canvas, hoursText, x, y, fontSize, TextAlign.left, size);
      _drawStyledText(canvas, minutesText, size.width - x, y, fontSize, TextAlign.right, size);
    } else if (config.clock.verticalLayout) {
      // Vertical layout
      final lineSpacing = fontSize * config.clock.lineHeight;
      final cleanTime = timeText.replaceAll(':', '');
      final hoursText = cleanTime.substring(0, 2);
      final minutesText = cleanTime.substring(2, 4);

      _drawStyledText(canvas, hoursText, x, y, fontSize, TextAlign.left, size);
      _drawStyledText(canvas, minutesText, x, y + lineSpacing, fontSize, TextAlign.left, size);
    } else if (config.clock.horizontalLayout) {
      // Horizontal layout with dot
      String displayText;
      if (config.clock.format == 'HH:mm') {
        final parts = timeText.split(':');
        displayText = '${parts[0]} . ${parts[1]}';
      } else {
        displayText = '${timeText.substring(0, 2)} . ${timeText.substring(2, 4)}';
      }
      _drawStyledText(canvas, displayText, x, y, fontSize, TextAlign.left, size);
    } else {
      // Normal layout - use LEFT alignment (same as mobile)
      _drawStyledText(canvas, timeText, x, y, fontSize, TextAlign.left, size);
    }
  }

  void _drawStyledText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    TextAlign align,
    Size canvasSize,
  ) {
    final textStyle = _getTextStyle(fontSize);
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: align,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Adjust x position based on alignment
    double drawX = x;
    if (align == TextAlign.right) {
      drawX = x - textPainter.width;
    } else if (align == TextAlign.center) {
      drawX = x - (textPainter.width / 2);
    }
    
    // Calculate top position from baseline (same as mobile)
    double drawY = y - fontSize;

    // Save canvas state
    canvas.save();

    // Apply transforms if any
    final transform = config.clock.transform;
    if (transform != null) {
      final hasTransforms = transform.horizontalStretch != 1.0 ||
          transform.verticalStretch != 1.0 ||
          transform.horizontalSkew != 0.0 ||
          transform.verticalSkew != 0.0 ||
          transform.perspectiveX != 0.0 ||
          transform.perspectiveY != 0.0 ||
          transform.perspectiveZ != 0.0;

      if (hasTransforms) {
        // Move to text position
        canvas.translate(drawX + textPainter.width / 2, drawY + fontSize / 2);

        // Build transform matrix
        final matrix = Matrix4.identity();

        // Apply perspective for 3D rotations
        if (transform.perspectiveX != 0.0 || transform.perspectiveY != 0.0) {
          matrix.setEntry(3, 2, 0.001);
        }

        // Apply 3D rotations
        if (transform.perspectiveX != 0.0) {
          final radians = transform.perspectiveX * 3.14159 / 180;
          matrix.rotateX(radians);
        }

        if (transform.perspectiveY != 0.0) {
          final radians = transform.perspectiveY * 3.14159 / 180;
          matrix.rotateY(radians);
        }

        // Apply scale
        matrix.scale(transform.horizontalStretch, transform.verticalStretch);

        // Apply skew
        if (transform.horizontalSkew != 0.0) {
          matrix.setEntry(0, 1, transform.horizontalSkew);
        }

        if (transform.verticalSkew != 0.0) {
          matrix.setEntry(1, 0, transform.verticalSkew);
        }

        // Apply 2D rotation
        if (transform.perspectiveZ != 0.0) {
          final radians = transform.perspectiveZ * 3.14159 / 180;
          matrix.rotateZ(radians);
        }

        canvas.transform(matrix.storage);

        // Adjust draw position to center
        drawX = -textPainter.width / 2;
        drawY = -fontSize / 2;
      }
    }

    // Draw stroke if enabled
    if (config.clock.style?.strokeWidth != null && config.clock.style!.strokeWidth! > 0) {
      final strokeStyle = textStyle.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = config.clock.style!.strokeWidth!
          ..color = _parseColor(config.clock.style!.strokeColor ?? '#000000'),
      );
      final strokeSpan = TextSpan(text: text, style: strokeStyle);
      final strokePainter = TextPainter(
        text: strokeSpan,
        textAlign: align,
        textDirection: TextDirection.ltr,
      );
      strokePainter.layout();
      strokePainter.paint(canvas, Offset(drawX, drawY));
    }

    // Draw main text
    textPainter.paint(canvas, Offset(drawX, drawY));

    // Restore canvas state
    canvas.restore();
  }

  TextStyle _getTextStyle(double fontSize) {
    // Get base font style
    TextStyle baseStyle;
    try {
      baseStyle = _getFontStyle(config.clock.font, fontSize);
    } catch (e) {
      baseStyle = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      );
    }

    // Apply letter spacing
    final letterSpacing = config.clock.letterSpacing * fontSize;

    // Apply color and opacity
    final color = _parseColor(config.clock.color).withOpacity(config.clock.opacity);

    // Apply gradient if enabled
    if (config.clock.style?.gradient?.enabled == true &&
        config.clock.style!.gradient!.colors.length >= 2) {
      final angle = (config.clock.style!.gradient!.angle) * 3.14159 / 180;
      final gradient = LinearGradient(
        colors: [
          _parseColor(config.clock.style!.gradient!.colors[0]),
          _parseColor(config.clock.style!.gradient!.colors[1]),
        ],
        transform: GradientRotation(angle),
      );

      return baseStyle.copyWith(
        letterSpacing: letterSpacing,
        foreground: Paint()
          ..shader = gradient.createShader(const Rect.fromLTWH(0, 0, 200, 70)),
        shadows: _getShadows(),
      );
    }

    return baseStyle.copyWith(
      letterSpacing: letterSpacing,
      color: color,
      shadows: _getShadows(),
    );
  }

  TextStyle _getFontStyle(String fontName, double fontSize) {
    switch (fontName) {
      case 'BebasNeue':
        return GoogleFonts.bebasNeue(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'Oswald':
        return GoogleFonts.oswald(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'Anton':
        return GoogleFonts.anton(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'Condensed':
        return GoogleFonts.robotoCondensed(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'Roboto':
        return GoogleFonts.roboto(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'Montserrat':
        return GoogleFonts.montserrat(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'OpenSans':
        return GoogleFonts.openSans(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'Lato':
        return GoogleFonts.lato(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'Poppins':
        return GoogleFonts.poppins(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'Inter':
        return GoogleFonts.inter(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'Raleway':
        return GoogleFonts.raleway(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'Nunito':
        return GoogleFonts.nunito(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'Ubuntu':
        return GoogleFonts.ubuntu(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'WorkSans':
        return GoogleFonts.workSans(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'Righteous':
        return GoogleFonts.righteous(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'RussoOne':
        return GoogleFonts.russoOne(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'Pacifico':
        return GoogleFonts.pacifico(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'Lobster':
        return GoogleFonts.lobster(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'DancingScript':
        return GoogleFonts.dancingScript(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'Satisfy':
        return GoogleFonts.satisfy(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'Caveat':
        return GoogleFonts.caveat(fontSize: fontSize, fontWeight: FontWeight.bold);
      default:
        return GoogleFonts.roboto(fontSize: fontSize, fontWeight: FontWeight.bold);
    }
  }

  List<Shadow> _getShadows() {
    final shadows = <Shadow>[];

    // Shadow effect
    if (config.clock.style?.shadowBlur != null && config.clock.style!.shadowBlur! > 0) {
      shadows.add(Shadow(
        color: _parseColor(config.clock.style!.shadowColor ?? '#000000'),
        offset: Offset(
          config.clock.style!.shadowOffsetX ?? 0,
          config.clock.style!.shadowOffsetY ?? 0,
        ),
        blurRadius: config.clock.style!.shadowBlur!,
      ));
    }

    // Outer glow effect
    if (config.clock.effects?.outerGlow == true) {
      shadows.add(Shadow(
        color: _parseColor(config.clock.color).withOpacity(0.8),
        offset: Offset.zero,
        blurRadius: 20,
      ));
    }

    // Inner glow effect (simulated with multiple white shadows)
    if (config.clock.effects?.innerGlow == true) {
      shadows.addAll([
        Shadow(
          color: Colors.white.withOpacity(0.6),
          offset: Offset.zero,
          blurRadius: 8,
        ),
        Shadow(
          color: Colors.white.withOpacity(0.4),
          offset: Offset.zero,
          blurRadius: 4,
        ),
      ]);
    }

    return shadows;
  }

  void _drawSelectionBox(Canvas canvas, Size size) {
    final fontSize = size.height * config.clock.sizeRatio;
    final x = size.width * config.clock.position.x;
    final y = size.height * config.clock.position.y;

    // Draw selection rectangle
    final paint = Paint()
      ..color = const Color(0xFFFF9500)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = Rect.fromLTWH(
      x - 10,
      y - fontSize - 10,
      200,
      fontSize + 20,
    );

    canvas.drawRect(rect, paint);

    // Draw resize handle
    final handlePaint = Paint()..color = const Color(0xFFFF9500);
    canvas.drawCircle(
      Offset(rect.right, rect.bottom),
      8,
      handlePaint,
    );
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  bool shouldRepaint(WallpaperPainter oldDelegate) {
    return oldDelegate.config != config ||
        oldDelegate.backgroundImage != backgroundImage ||
        oldDelegate.foregroundImage != foregroundImage ||
        oldDelegate.currentTime != currentTime ||
        oldDelegate.showSelection != showSelection;
  }
}
