import 'package:hive/hive.dart';
import 'package:focuslocus/local_storage/course_metadata_storage_model.dart';

/// The internal storage for course metatata. It has a singleton and stores
/// how many decks have been unlocked. In the future it may store other kinds
/// of progress within the course
class CourseMetadataStorage {
  static CourseMetadataStorage? _instance;
  static Box<CourseMetadataStorageModel>? _courseStorageBox;
  CourseMetadataStorage._();

  static Future<void> init() async {
    _instance ??= CourseMetadataStorage._();

    if (!Hive.isBoxOpen("CourseMetadata")) {
      _courseStorageBox = await Hive.openBox("CourseMetadata");
    }
  }

  static int getDecksUnlocked(String courseID) {
    _initIfNull();
    CourseMetadataStorageModel? course = _courseStorageBox!.get(courseID);
    if (course != null) {
      return course.decksUnlocked;
    } else {
      _courseStorageBox!.put(courseID, CourseMetadataStorageModel());
      return 0;
    }
  }

  static void incrementDecksUnlocked(String courseID) {
    _initIfNull();
    CourseMetadataStorageModel? course = _courseStorageBox!.get(courseID);

    if (course != null) {
      course.decksUnlocked++;
      course.save();
    } else {
      course = CourseMetadataStorageModel();
      _courseStorageBox!.put(courseID, course);
    }
  }

  static int currentDeckIndex(String courseID) {
    _initIfNull();
    CourseMetadataStorageModel? course = _courseStorageBox!.get(courseID);

    if (course != null) {
      print(course.currentDeck);
      return course.currentDeck;
    } else {
      _courseStorageBox!.put(courseID, CourseMetadataStorageModel());
    }
    return 0;
  }

  static void setCurrentDeckIndex(String courseID, int index) {
    _initIfNull();
    CourseMetadataStorageModel? course = _courseStorageBox!.get(courseID);

    if (course != null) {
      course.currentDeck = index;
      course.save();
    } else {
      course = CourseMetadataStorageModel(currentDeck: index);
      _courseStorageBox!.put(courseID, course);
    }
  }

  static void _initIfNull() {
    if (_instance == null) {
      init();
    }
  }
}
