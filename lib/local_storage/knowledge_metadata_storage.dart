import 'package:hive/hive.dart';
import 'package:focuslocus/local_storage/knowledge_metadata_storage_model.dart';

/// The knowledge Metadata storage takes care of all scheduling information
/// for knowledge-items. In the future, it may also track improvement records
/// for them
class KnowledgeMetadataStorage {
  static KnowledgeMetadataStorage? _instance;
  static Box<KnowledgeMetadataStorageModel>? _knowledgeMetadataStorage;

  KnowledgeMetadataStorage._();

  static Future<void> init() async {
    _instance ??= KnowledgeMetadataStorage._();
    if (!Hive.isBoxOpen("KnowledgeMetadata")) {
      _knowledgeMetadataStorage = await Hive.openBox("KnowledgeMetadata");
    }
  }

  static Box get box {
    _initIfNull();
    return _knowledgeMetadataStorage!;
  }

  /// Returns the due time. If there is no due time saved on disk (either because
  /// the knowledge item has no entry or no due time), it takes the standard due
  /// time (can be set to e.g. DateTime.now()), saves and returns that instead.
  static DateTime getDue(String knowledgeID, {DateTime? standardDueTime}) {
    _initIfNull();
    KnowledgeMetadataStorageModel? knowledgeMetadata =
        _knowledgeMetadataStorage!.get(knowledgeID);
    if (knowledgeMetadata != null) {
      DateTime? due = knowledgeMetadata.due;
      if (due == null) {
        due = standardDueTime ?? DateTime.now();
        knowledgeMetadata.due = due;
        knowledgeMetadata.save();
      }
      return due;
    } else {
      knowledgeMetadata = KnowledgeMetadataStorageModel(
        due: standardDueTime ?? DateTime.now(),
      );
      _knowledgeMetadataStorage!.put(knowledgeID, knowledgeMetadata);
      return standardDueTime ?? DateTime.now();
    }
  }

  static void setDue(String knowledgeID, DateTime due) {
    _initIfNull();
    KnowledgeMetadataStorageModel? knowledgeMetadata =
        _knowledgeMetadataStorage!.get(knowledgeID);
    if (knowledgeMetadata != null) {
      knowledgeMetadata.due = due;
      knowledgeMetadata.save();
    } else {
      knowledgeMetadata = KnowledgeMetadataStorageModel(due: due);
      _knowledgeMetadataStorage!.put(knowledgeID, knowledgeMetadata);
    }
  }

  static DateTime? getLastPracticed(String knowledgeID) {
    _initIfNull();
    KnowledgeMetadataStorageModel? knowledgeMetadata =
        _knowledgeMetadataStorage!.get(knowledgeID);
    if (knowledgeMetadata != null) {
      return knowledgeMetadata.lastPracticed;
    } else {
      knowledgeMetadata = KnowledgeMetadataStorageModel();
      _knowledgeMetadataStorage!.put(knowledgeID, knowledgeMetadata);
      return null;
    }
  }

  static void setLastPracticed(String knowledgeID, DateTime lastPracticed) {
    _initIfNull();

    KnowledgeMetadataStorageModel? knowledgeMetadata =
        _knowledgeMetadataStorage!.get(knowledgeID);
    if (knowledgeMetadata != null) {
      knowledgeMetadata.lastPracticed = lastPracticed;
      knowledgeMetadata.save();
    } else {
      knowledgeMetadata =
          KnowledgeMetadataStorageModel(lastPracticed: lastPracticed);
      _knowledgeMetadataStorage!.put(knowledgeID, knowledgeMetadata);
    }
  }

  static int getLastInterval(String knowledgeID) {
    _initIfNull();
    KnowledgeMetadataStorageModel? knowledgeMetadata =
        _knowledgeMetadataStorage!.get(knowledgeID);
    if (knowledgeMetadata != null) {
      return knowledgeMetadata.lastInterval;
    } else {
      knowledgeMetadata = KnowledgeMetadataStorageModel();
      _knowledgeMetadataStorage!.put(knowledgeID, knowledgeMetadata);
      return 0;
    }
  }

  static void setLastInterval(String knowledgeID, int lastInterval) {
    _initIfNull();
    KnowledgeMetadataStorageModel? knowledgeMetadata =
        _knowledgeMetadataStorage!.get(knowledgeID);
    if (knowledgeMetadata != null) {
      knowledgeMetadata.lastInterval = lastInterval;
      knowledgeMetadata.save();
    } else {
      knowledgeMetadata =
          KnowledgeMetadataStorageModel(lastInterval: lastInterval);
      _knowledgeMetadataStorage!.put(knowledgeID, knowledgeMetadata);
    }
  }

  static void _initIfNull() {
    if (_instance == null) {
      init();
    }
  }
}
