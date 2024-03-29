// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'dart:math';

/// A utility class to calculate the colors seen in the user interface. It uses
/// the Hue Saturation Value Representation, instead of RGB values
class ColorTransform {
  static Color gradientColorMix(double point, List<Color> colors) {
    // Turning point into a quasi-index ranging from 0.0 to colors.length-1
    point = min(1, max(0, point)) * (colors.length - 1);
    // mixing the two colors nearest to the point
    if (point == colors.length.toDouble()) {
      return colors.last;
    } else {
      int foregroundOpacity = (255.0 * (point - point.floor())).round();
      return Color.alphaBlend(colors[point.ceil()].withAlpha(foregroundOpacity),
          colors[point.floor()]);
    }
  }

  /// The accent color for any main color [color]. It transform the hue to generate a color
  /// that fits to this one, but decreases the saturation so that it does not
  /// pop as much as the main color.
  static Color accentColor(Color color) {
    HSVColor retHSV = HSVColor.toHSVColor(color);
    retHSV.hue -= 40;
    if (retHSV.hue < 0) {
      retHSV.hue += 360;
    }
    retHSV.saturation *= .9;
    return HSVColor.fromHSVColor(retHSV);
  }

  /// Whenever a gradient is calculated from a main color, the second color
  /// is a slightly altered form of the main color.
  static Color gradientColor(Color color) {
    HSVColor retHSV = HSVColor.toHSVColor(color);
    retHSV.hue += 15;
    if (retHSV.hue < 0) {
      retHSV.hue += 360;
    }
    if (retHSV.value > .9) {
      retHSV.value = .9;
    }
    return HSVColor.fromHSVColor(retHSV);
  }

  /// Multiplies the HSV value component by a given factor. The factor is 0.6 by default.
  /// Additionally, it reduces the saturation slightly.
  static Color darker(Color color, {double factor = 0.6}) {
    HSVColor retHSV = HSVColor.toHSVColor(color);
    retHSV.value *= factor;
    retHSV.saturation *= .9;
    return HSVColor.fromHSVColor(retHSV);
  }

  /// Generates the backgroundcolor for any screen that has the main color [color]
  static Color scaffoldBackgroundColor(Color color) {
    HSVColor retHSV = HSVColor.toHSVColor(color);

    retHSV.value = 1;
    retHSV.saturation *= 0.15;

    return HSVColor.fromHSVColor(retHSV);
  }

  /// The neutral background color for widgets, that are not the scaffold, for
  /// a main color [color]. It is used, for example, as the background color
  /// for an empty linearProgressIndicator
  static Color widgetBackgroundColor(Color color) {
    HSVColor retHSV = HSVColor.toHSVColor(color);

    retHSV.value = 1;
    retHSV.saturation *= 0.55;

    return HSVColor.fromHSVColor(retHSV);
  }

  /// Changes the saturation of a color [color] directly. [saturation] may be
  /// between 0 and 1
  static Color withSaturation(Color color, double saturation) {
    if (saturation < 0) {
      saturation = 0;
    }
    if (saturation > 1) {
      saturation = 1;
    }
    HSVColor retHSV = HSVColor.toHSVColor(color);

    retHSV.saturation = saturation;

    return HSVColor.fromHSVColor(retHSV);
  }

  /// Changes the value of a Color [color] directly. [value] may be between
  /// 0 and 1
  static Color withValue(Color color, double value) {
    if (value < 0) {
      value = 0;
    }
    if (value > 1) {
      value = 1;
    }
    HSVColor retHSV = HSVColor.toHSVColor(color);

    retHSV.value = value;

    return HSVColor.fromHSVColor(retHSV);
  }

  /// Computes a darker variant of a main color, so that the hue is still
  /// decernable, but the color is well readable with regard to background
  /// colors generated by this class.
  static Color textColor(Color color) {
    HSVColor retHSV = HSVColor.toHSVColor(color);
    retHSV.value *= .8;

    return HSVColor.fromHSVColor(retHSV);
  }
}

/// A color in HSV representation
class HSVColor {
  /// The hue of the color. May be between 0 and 360
  double hue;

  /// The Saturation of the color. May be between 0 and 1
  double saturation;

  /// The value of the color. May be between 0 and 1
  double value;

  /// The opacity of the color. May be between 0 and 255. 255 is completely
  /// opaque.
  int alpha;

  HSVColor(
      {required this.hue,
      required this.saturation,
      required this.value,
      this.alpha = 255});

  // Basically this algorithm:
  // https://www5.in.tum.de/lehre/vorlesungen/graphik/info/csc/COL_25.htm#topic24

  /// Computes a HSVColor from a color within the material.dart library
  static HSVColor toHSVColor(Color color) {
    double r = color.red.toDouble() / 255.0,
        g = color.green.toDouble() / 255.0,
        b = color.blue.toDouble() / 255.0;

    double h, s, v, maxv, minv;
    maxv = max(r, max(g, b));
    minv = min(r, min(g, b));

    //We have a shade of grey, because r=b=g
    if (maxv == minv) {
      h = 0;
    }
    //red is dominant
    else if (maxv == r) {
      h = 60 * ((g - b) / (maxv - minv));
    }
    //green is dominant
    else if (maxv == g) {
      h = 60 * (2 + ((b - r) / (maxv - minv)));
    }
    //blue is dominant
    else {
      h = 60 * (4 + ((r - g) / (maxv - minv)));
    }

    if (h < 0) {
      h += 360;
    }

    if (maxv == 0) {
      s = 0;
    } else {
      s = (maxv - minv) / maxv;
    }
    v = maxv;
    return HSVColor(hue: h, saturation: s, value: v, alpha: color.alpha);
  }

  /// Computes a material.dart color from a HSVcolor
  static Color fromHSVColor(HSVColor hsvColor) {
    int hi = (hsvColor.hue / 60).floor();
    double f = (hsvColor.hue / 60) - hi.toDouble();
    double p = hsvColor.value * (1.0 - hsvColor.saturation);
    double q = hsvColor.value * (1.0 - (hsvColor.saturation * f));
    double t = hsvColor.value * (1.0 - (hsvColor.saturation * (1.0 - f)));

    switch (hi) {
      case 1:
        return Color.fromARGB(
          hsvColor.alpha,
          (q * 255.0).round(),
          (hsvColor.value * 255.0).round(),
          (p * 255.0).round(),
        );
      case 2:
        return Color.fromARGB(
          hsvColor.alpha,
          (p * 255.0).round(),
          (hsvColor.value * 255.0).round(),
          (t * 255.0).round(),
        );
      case 3:
        return Color.fromARGB(
          hsvColor.alpha,
          (p * 255.0).round(),
          (q * 255.0).round(),
          (hsvColor.value * 255.0).round(),
        );
      case 4:
        return Color.fromARGB(
          hsvColor.alpha,
          (t * 255.0).round(),
          (p * 255.0).round(),
          (hsvColor.value * 255.0).round(),
        );
      case 5:
        return Color.fromARGB(
          hsvColor.alpha,
          (hsvColor.value * 255.0).round(),
          (p * 255.0).round(),
          (q * 255.0).round(),
        );
      default:
        return Color.fromARGB(
          hsvColor.alpha,
          (hsvColor.value * 255.0).round(),
          (t * 255.0).round(),
          (p * 255.0).round(),
        );
    }
  }
}
