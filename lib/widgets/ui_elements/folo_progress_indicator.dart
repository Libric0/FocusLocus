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

/// A linear progress indicator that has been altered to fit into the theming
/// of FocusLocus
class FoloProgressIndicator extends StatelessWidget {
  final Color color;
  final Color backgroundColor;
  final double value;
  const FoloProgressIndicator(
      {required this.color,
      this.backgroundColor = Colors.white,
      required this.value,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: LinearProgressIndicator(
        color: color,
        backgroundColor: backgroundColor,
        minHeight: 20,
        value: value,
      ),
    );
  }
}
