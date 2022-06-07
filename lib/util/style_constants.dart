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

/// A set of style constants that are used within the application. May be extended
/// in the future to make it look more consistent.
class StyleConstants {
  static const double cardBorderRadiusSize = 25;
  static const BoxShadow cardBoxShadow = BoxShadow(
    offset: Offset(0, 5),
    blurRadius: 10,
    color: Color.fromARGB(100, 0, 0, 0),
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(8);
  static const EdgeInsets cardMargin = EdgeInsets.all(12);
}
