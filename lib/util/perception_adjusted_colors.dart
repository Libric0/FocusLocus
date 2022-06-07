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
import 'package:focuslocus/local_storage/user_storage.dart';

/// A set of colors that are semantically important and therefore need replacements
/// for colorblind people
class _ColorPerception {
  final Color good;
  final Color bad;
  final Color selected;

  const _ColorPerception({
    this.good = Colors.green,
    this.bad = Colors.red,
    this.selected = Colors.blue,
  });
}

/// The class that is used to access colors designed for different perception types, based on the colorPerception-object in the user storage
class PerceptionAdjustedColors {
  static final Map<String, _ColorPerception> _colorPerceptions = {
    "protanopia": const _ColorPerception(
      bad: Colors.purple,
      good: Colors.amber,
      selected: Colors.blue,
    ),
    "deuteranopia": const _ColorPerception(
      bad: Colors.purple,
      good: Colors.amber,
      selected: Colors.blue,
    ),
    "tritanopia": _ColorPerception(
      bad: Colors.red,
      good: Colors.green,
      selected: Colors.blue[300] ?? Colors.blue,
    ),
    "achromatopsia": _ColorPerception(
      bad: Colors.red[900] ?? Colors.red,
      good: Colors.green[300] ?? Colors.green,
      selected: Colors.blue,
    )
  };
  static const _ColorPerception _default = _ColorPerception();

  /// The color that marks things as bad/incorrect. Red is the default
  static Color get bad =>
      (_colorPerceptions[UserStorage.colorPerception] ?? _default).bad;

  /// The color that marks things as good/correct. Green is the default
  static Color get good =>
      (_colorPerceptions[UserStorage.colorPerception] ?? _default).good;

  /// The color that marks selected items. Blue is the dafault
  static Color get selected =>
      (_colorPerceptions[UserStorage.colorPerception] ?? _default).selected;
}
