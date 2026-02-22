class WallpaperModel {
  final String id;
  final String category;
  final WallpaperAssets assets;
  final ClockConfig clock;
  final DateConfig? date;
  final DepthConfig depth;
  final String version;

  WallpaperModel({
    required this.id,
    required this.category,
    required this.assets,
    required this.clock,
    this.date,
    required this.depth,
    required this.version,
  });

  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    return WallpaperModel(
      id: json['id'] as String,
      category: json['category'] as String,
      assets: WallpaperAssets.fromJson(json['assets'] as Map<String, dynamic>),
      clock: ClockConfig.fromJson(json['clock'] as Map<String, dynamic>),
      date: json['date'] != null ? DateConfig.fromJson(json['date'] as Map<String, dynamic>) : null,
      depth: DepthConfig.fromJson(json['depth'] as Map<String, dynamic>),
      version: json['version'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'assets': assets.toJson(),
      'clock': clock.toJson(),
      if (date != null) 'date': date!.toJson(),
      'depth': depth.toJson(),
      'version': version,
    };
  }

  WallpaperModel copyWith({
    String? id,
    String? category,
    WallpaperAssets? assets,
    ClockConfig? clock,
    DateConfig? date,
    DepthConfig? depth,
    String? version,
  }) {
    return WallpaperModel(
      id: id ?? this.id,
      category: category ?? this.category,
      assets: assets ?? this.assets,
      clock: clock ?? this.clock,
      date: date ?? this.date,
      depth: depth ?? this.depth,
      version: version ?? this.version,
    );
  }
}

class DateConfig {
  final bool enabled;
  final String format;
  final double size;
  final ClockPosition position;

  DateConfig({
    required this.enabled,
    required this.format,
    required this.size,
    required this.position,
  });

  factory DateConfig.fromJson(Map<String, dynamic> json) {
    return DateConfig(
      enabled: json['enabled'] as bool,
      format: json['format'] as String,
      size: (json['size'] as num).toDouble(),
      position: ClockPosition.fromJson(json['position'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'format': format,
      'size': size,
      'position': position.toJson(),
    };
  }
}

class WallpaperAssets {
  final String background;
  final String? foreground;

  WallpaperAssets({
    required this.background,
    this.foreground,
  });

  factory WallpaperAssets.fromJson(Map<String, dynamic> json) {
    return WallpaperAssets(
      background: json['background'] as String,
      foreground: json['foreground'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'background': background,
      if (foreground != null) 'foreground': foreground,
    };
  }
}

class ClockConfig {
  final bool enabled;
  final String format;
  final String font;
  final String color;
  final double opacity;
  final double sizeRatio;
  final ClockPosition position;
  final double lineHeight;
  final double letterSpacing;
  final bool splitDigits;
  final bool verticalLayout;
  final bool horizontalLayout;
  final ClockTransform? transform;
  final ClockEffects? effects;
  final ClockStyle? style;

  ClockConfig({
    required this.enabled,
    required this.format,
    required this.font,
    required this.color,
    required this.opacity,
    required this.sizeRatio,
    required this.position,
    required this.lineHeight,
    this.letterSpacing = 0.0,
    required this.splitDigits,
    this.verticalLayout = false,
    this.horizontalLayout = false,
    this.transform,
    this.effects,
    this.style,
  });

  factory ClockConfig.fromJson(Map<String, dynamic> json) {
    return ClockConfig(
      enabled: json['enabled'] as bool,
      format: json['format'] as String,
      font: json['font'] as String,
      color: json['color'] as String,
      opacity: (json['opacity'] as num).toDouble(),
      sizeRatio: (json['sizeRatio'] as num).toDouble(),
      position: ClockPosition.fromJson(json['position'] as Map<String, dynamic>),
      lineHeight: (json['lineHeight'] as num).toDouble(),
      letterSpacing: json['letterSpacing'] != null ? (json['letterSpacing'] as num).toDouble() : 0.0,
      splitDigits: json['splitDigits'] as bool,
      verticalLayout: json['verticalLayout'] as bool? ?? false,
      horizontalLayout: json['horizontalLayout'] as bool? ?? false,
      transform: json['transform'] != null ? ClockTransform.fromJson(json['transform'] as Map<String, dynamic>) : null,
      effects: json['effects'] != null ? ClockEffects.fromJson(json['effects'] as Map<String, dynamic>) : null,
      style: json['style'] != null ? ClockStyle.fromJson(json['style'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'format': format,
      'font': font,
      'color': color,
      'opacity': opacity,
      'sizeRatio': sizeRatio,
      'position': position.toJson(),
      'lineHeight': lineHeight,
      'letterSpacing': letterSpacing,
      'splitDigits': splitDigits,
      'verticalLayout': verticalLayout,
      'horizontalLayout': horizontalLayout,
      if (transform != null) 'transform': transform!.toJson(),
      if (effects != null) 'effects': effects!.toJson(),
      if (style != null) 'style': style!.toJson(),
    };
  }

  ClockConfig copyWith({
    bool? enabled,
    String? format,
    String? font,
    String? color,
    double? opacity,
    double? sizeRatio,
    ClockPosition? position,
    double? lineHeight,
    double? letterSpacing,
    bool? splitDigits,
    bool? verticalLayout,
    bool? horizontalLayout,
    ClockTransform? transform,
    ClockEffects? effects,
    ClockStyle? style,
  }) {
    return ClockConfig(
      enabled: enabled ?? this.enabled,
      format: format ?? this.format,
      font: font ?? this.font,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      sizeRatio: sizeRatio ?? this.sizeRatio,
      position: position ?? this.position,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      splitDigits: splitDigits ?? this.splitDigits,
      verticalLayout: verticalLayout ?? this.verticalLayout,
      horizontalLayout: horizontalLayout ?? this.horizontalLayout,
      transform: transform ?? this.transform,
      effects: effects ?? this.effects,
      style: style ?? this.style,
    );
  }
}

class ClockTransform {
  final double horizontalStretch;
  final double verticalStretch;
  final double horizontalSkew;
  final double verticalSkew;
  final double perspectiveX;
  final double perspectiveY;
  final double perspectiveZ;

  ClockTransform({
    this.horizontalStretch = 1.0,
    this.verticalStretch = 1.0,
    this.horizontalSkew = 0.0,
    this.verticalSkew = 0.0,
    this.perspectiveX = 0.0,
    this.perspectiveY = 0.0,
    this.perspectiveZ = 0.0,
  });

  factory ClockTransform.fromJson(Map<String, dynamic> json) {
    return ClockTransform(
      horizontalStretch: json['horizontalStretch'] != null ? (json['horizontalStretch'] as num).toDouble() : 1.0,
      verticalStretch: json['verticalStretch'] != null ? (json['verticalStretch'] as num).toDouble() : 1.0,
      horizontalSkew: json['horizontalSkew'] != null ? (json['horizontalSkew'] as num).toDouble() : 0.0,
      verticalSkew: json['verticalSkew'] != null ? (json['verticalSkew'] as num).toDouble() : 0.0,
      perspectiveX: json['perspectiveX'] != null ? (json['perspectiveX'] as num).toDouble() : 0.0,
      perspectiveY: json['perspectiveY'] != null ? (json['perspectiveY'] as num).toDouble() : 0.0,
      perspectiveZ: json['perspectiveZ'] != null ? (json['perspectiveZ'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'horizontalStretch': horizontalStretch,
      'verticalStretch': verticalStretch,
      'horizontalSkew': horizontalSkew,
      'verticalSkew': verticalSkew,
      'perspectiveX': perspectiveX,
      'perspectiveY': perspectiveY,
      'perspectiveZ': perspectiveZ,
    };
  }
}

class ClockEffects {
  final bool innerGlow;
  final bool outerGlow;

  ClockEffects({
    this.innerGlow = false,
    this.outerGlow = false,
  });

  factory ClockEffects.fromJson(Map<String, dynamic> json) {
    return ClockEffects(
      innerGlow: json['innerGlow'] as bool? ?? false,
      outerGlow: json['outerGlow'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'innerGlow': innerGlow,
      'outerGlow': outerGlow,
    };
  }
}

class ClockStyle {
  final double? strokeWidth;
  final String? strokeColor;
  final double? shadowBlur;
  final String? shadowColor;
  final double? shadowOffsetX;
  final double? shadowOffsetY;
  final GradientConfig? gradient;

  ClockStyle({
    this.strokeWidth,
    this.strokeColor,
    this.shadowBlur,
    this.shadowColor,
    this.shadowOffsetX,
    this.shadowOffsetY,
    this.gradient,
  });

  factory ClockStyle.fromJson(Map<String, dynamic> json) {
    return ClockStyle(
      strokeWidth: json['strokeWidth'] != null ? (json['strokeWidth'] as num).toDouble() : null,
      strokeColor: json['strokeColor'] as String?,
      shadowBlur: json['shadowBlur'] != null ? (json['shadowBlur'] as num).toDouble() : null,
      shadowColor: json['shadowColor'] as String?,
      shadowOffsetX: json['shadowOffsetX'] != null ? (json['shadowOffsetX'] as num).toDouble() : null,
      shadowOffsetY: json['shadowOffsetY'] != null ? (json['shadowOffsetY'] as num).toDouble() : null,
      gradient: json['gradient'] != null ? GradientConfig.fromJson(json['gradient'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (strokeWidth != null) 'strokeWidth': strokeWidth,
      if (strokeColor != null) 'strokeColor': strokeColor,
      if (shadowBlur != null) 'shadowBlur': shadowBlur,
      if (shadowColor != null) 'shadowColor': shadowColor,
      if (shadowOffsetX != null) 'shadowOffsetX': shadowOffsetX,
      if (shadowOffsetY != null) 'shadowOffsetY': shadowOffsetY,
      if (gradient != null) 'gradient': gradient!.toJson(),
    };
  }
}

class GradientConfig {
  final bool enabled;
  final List<String> colors;
  final double angle;

  GradientConfig({
    required this.enabled,
    required this.colors,
    required this.angle,
  });

  factory GradientConfig.fromJson(Map<String, dynamic> json) {
    return GradientConfig(
      enabled: json['enabled'] as bool,
      colors: (json['colors'] as List).cast<String>(),
      angle: (json['angle'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'colors': colors,
      'angle': angle,
    };
  }
}

class ClockPosition {
  final double x;
  final double y;

  ClockPosition({required this.x, required this.y});

  factory ClockPosition.fromJson(Map<String, dynamic> json) {
    return ClockPosition(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }
}

class DepthConfig {
  final List<String> layerOrder;
  final ParallaxConfig parallax;

  DepthConfig({
    required this.layerOrder,
    required this.parallax,
  });

  factory DepthConfig.fromJson(Map<String, dynamic> json) {
    return DepthConfig(
      layerOrder: (json['layerOrder'] as List).cast<String>(),
      parallax: ParallaxConfig.fromJson(json['parallax'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'layerOrder': layerOrder,
      'parallax': parallax.toJson(),
    };
  }
}

class ParallaxConfig {
  final int background;
  final int clock;
  final int foreground;

  ParallaxConfig({
    required this.background,
    required this.clock,
    required this.foreground,
  });

  factory ParallaxConfig.fromJson(Map<String, dynamic> json) {
    return ParallaxConfig(
      background: json['background'] as int,
      clock: json['clock'] as int,
      foreground: json['foreground'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'background': background,
      'clock': clock,
      'foreground': foreground,
    };
  }
}
