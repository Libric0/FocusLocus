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
