import 'package:focuslocus/knowledge/math_object.dart';

/// A set of math objects with a unique identifier, lists of names and a list
/// containing Mathobjects. When an iterator is created from this iterable, it
/// just traverses the internal list of mathObjects
class MathUniverse extends Iterable<MathObject> {
  /// The unique identifier. Used to allow multiple knowledge items to use
  /// this universe at once
  String universeId;

  /// List of names that can be used for this category interchangably in the singular
  List<String> namesSingular;

  /// List of names that can be used for this category interchangably in the plural
  List<String> namesPlural;

  /// List of all mathobjects in this category
  List<MathObject> mathObjects;

  MathUniverse({
    required String universeId,
    List<String> namesSingular = const [],
    List<String> namesPlural = const [],
    List<MathObject> mathObjects = const [],
  }) : this._(
          universeId: "mathUniverse." + universeId,
          namesSingular: namesSingular,
          namesPlural: namesPlural,
          mathObjects: mathObjects,
        );

  MathUniverse._({
    required this.universeId,
    this.namesSingular = const [],
    this.namesPlural = const [],
    this.mathObjects = const [],
  });
  int get size => mathObjects.length;

  String texTextRawStringAt(int index) {
    return elementAt(index).rawString;
  }

  /// Returns an iterator for the math objects
  @override
  Iterator<MathObject> get iterator => mathObjects.iterator;
}
