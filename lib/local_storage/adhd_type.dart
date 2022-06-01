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
