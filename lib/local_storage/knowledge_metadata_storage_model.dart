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

part 'knowledge_metadata_storage_model.g.dart';

/// A storage model for quizKnowledge metadata, including due date and
/// lastPracticed date.

@HiveType(typeId: 3)
class KnowledgeMetadataStorageModel extends HiveObject {
  @HiveField(0)
  DateTime? due;

  @HiveField(1)
  DateTime? lastPracticed;

  @HiveField(2, defaultValue: 0)
  int lastInterval;

  KnowledgeMetadataStorageModel({
    this.due,
    this.lastPracticed,
    this.lastInterval = 0,
  });

  @override
  String toString() {
    return "{Due: $due, lastPracticed: $lastPracticed, lastInterval: $lastInterval}";
  }
}
