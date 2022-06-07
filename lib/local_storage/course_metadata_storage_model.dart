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

part 'course_metadata_storage_model.g.dart';

/// A storage model that contains all information to a course that shall be
/// stored on the local disk (i.e. information that is not a part of a courses
/// content)
@HiveType(typeId: 1)
class CourseMetadataStorageModel extends HiveObject {
  /// The number of decks that have been unlocked in that course
  @HiveField(0, defaultValue: 0)
  int decksUnlocked;
  @HiveField(1, defaultValue: 0)
  int currentDeck;
  CourseMetadataStorageModel({this.decksUnlocked = 0, this.currentDeck = 0});
}
