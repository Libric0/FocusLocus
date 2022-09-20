// // Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
// //
// // This file is part of FocusLocus.
// //
// // FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
// //
// // FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
// //
// // You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

// import 'package:focuslocus/knowledge/math_object.dart';

// /// A set of math objects with a unique identifier, lists of names and a list
// /// containing Mathobjects. When an iterator is created from this iterable, it
// /// just traverses the internal list of mathObjects
// class MathUniverse extends Iterable<MathObject> {
//   /// The unique identifier. Used to allow multiple knowledge items to use
//   /// this universe at once
//   String universeId;

//   /// List of names that can be used for this category interchangably in the singular
//   List<String> namesSingular;

//   /// List of names that can be used for this category interchangably in the plural
//   List<String> namesPlural;

//   /// List of all mathobjects in this category
//   List<MathObject> mathObjects;

//   MathUniverse({
//     required String universeId,
//     List<String> namesSingular = const [],
//     List<String> namesPlural = const [],
//     List<MathObject> mathObjects = const [],
//   }) : this._(
//           universeId: "mathUniverse." + universeId,
//           namesSingular: namesSingular,
//           namesPlural: namesPlural,
//           mathObjects: mathObjects,
//         );

//   MathUniverse._({
//     required this.universeId,
//     this.namesSingular = const [],
//     this.namesPlural = const [],
//     this.mathObjects = const [],
//   });
//   int get size => mathObjects.length;

//   String texTextRawStringAt(int index) {
//     return elementAt(index).rawString;
//   }

//   /// Returns an iterator for the math objects
//   @override
//   Iterator<MathObject> get iterator => mathObjects.iterator;
// }
