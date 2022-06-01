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
