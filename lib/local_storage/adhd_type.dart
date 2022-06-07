// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.
import 'package:hive/hive.dart';

part 'adhd_type.g.dart';

/// A hive type representing the ADHD type the user has.
@HiveType(typeId: 4)
enum ADHDType {
  @HiveField(0)
  adhd,
  @HiveField(1)
  noAdhdButFocusProblems,
  @HiveField(2)
  noFocusProblems,
}
