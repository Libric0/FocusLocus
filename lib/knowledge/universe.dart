// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

class Universe extends Iterable<String> {
  /// List of names that can be used for this category interchangably in the singular
  List<String> namesSingular;

  /// List of names that can be used for this category interchangably in the plural
  List<String> namesPlural;

  /// Set of all objects in this category, represented as rawStrings for TexText
  Set<String> objects;

  Universe({
    required this.namesSingular,
    required this.namesPlural,
    required this.objects,
  });

  factory Universe.fromJSON({required Map<String, dynamic> jsonObject}) {
    List<String> namesSingular = [];
    if (jsonObject['namesSingular'] == null) {
      throw Exception(
          "No singular names have been provided for the Universe with the JSON representation: ${jsonObject.toString()}");
    }
    // namesSingular may be entered as List of names or a single name
    if (jsonObject['namesSingular'] is List) {
      for (dynamic name in jsonObject['namesSingular']) {
        if (name is! String) {
          throw Exception(
              "The List namesSingular contains objects other than Strings for the Universe with the JSON representation: ${jsonObject.toString()}");
        }
        namesSingular.add(name);
      }
    } else if (jsonObject['namesSingular'] is String) {
      namesSingular.add(jsonObject['namesSingular']);
    } else {
      throw Exception(
          "The object with the name namesSingular is neither a List nor a string for the Universe with the JSON representation: ${jsonObject.toString()}");
    }

    List<String> namesPlural = [];
    if (jsonObject['namesPlural'] == null) {
      throw Exception(
          "No plural names have been provided for the Universe with the JSON representation: ${jsonObject.toString()}");
    }
    // namesPlural may be entered as List of names or a single name
    if (jsonObject['namesPlural'] is List) {
      for (dynamic name in jsonObject['namesPlural']) {
        if (name is! String) {
          throw Exception(
              "The List namesPlural contains objects other than Strings for the Universe with the JSON representation: ${jsonObject.toString()}");
        }
        namesPlural.add(name);
      }
    } else if (jsonObject['namesPlural'] is String) {
      namesPlural.add(jsonObject['namesPlural']);
    } else {
      throw Exception(
          "The object with the name namesPlural is not a List for the Universe with the JSON representation: ${jsonObject.toString()}");
    }

    Set<String> objects = {};
    if (jsonObject['objects'] == null) {
      throw Exception(
          "No objects have been provided for the Universe with the JSON representation: ${jsonObject.toString()}");
    }
    // We always expect a list of objects.
    if (jsonObject['objects'] is! List) {
      throw Exception(
          "The object with the name objects is not a List for the Universe with the JSON representation: ${jsonObject.toString()}");
    }
    for (dynamic name in jsonObject['objects']) {
      if (name is! String) {
        throw Exception(
            "The List objects contains objects other than Strings for the Universe with the JSON representation: ${jsonObject.toString()}");
      }
      objects.add(name);
    }

    return Universe(
      namesSingular: namesSingular,
      namesPlural: namesPlural,
      objects: objects,
    );
  }
  @override
  Iterator<String> get iterator => objects.iterator;
}
