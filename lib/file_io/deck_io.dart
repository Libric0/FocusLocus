// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:focuslocus/knowledge/knowledge_category.dart';
import 'package:focuslocus/knowledge/knowledge_item.dart';
import 'package:focuslocus/knowledge/knowledge_multiple_choice.dart';
import 'package:focuslocus/knowledge/knowledge_statement.dart';
import 'package:focuslocus/knowledge/math_object.dart';
import 'package:focuslocus/knowledge/math_universe.dart';
import 'package:focuslocus/local_storage/knowledge_metadata_storage.dart';
import 'package:xml/xml.dart';

/// This class is used to parse deck files (.wcd). For now, it will only be used on
/// internal files that are shipped with the binary. In later work, it will be
/// used to parse local deck-files that can be imported and stored on the
/// disk
class DeckIO {
  /// Returns the deck's knowledge as an XmlDocument. The Deck itself is
  /// identified by its knowledgePath
  static Future<XmlDocument> getDeckDocument(String knowledgePath) async {
    String documentString =
        await rootBundle.loadString("assets/deck_data/$knowledgePath");
    return XmlDocument.parse(documentString);
  }

  /// Parses all knowledgeItemNodes (as XML nodes) into a list, given a quiz-decks
  /// knowledge Path, which can be found in the course file.
  static Future<List<XmlNode>> getKnowledgeItemNodes(
      String knowledgePath) async {
    XmlDocument deckDocument = await getDeckDocument(knowledgePath);
    List<XmlNode> knowledgeItemNodes = deckDocument.rootElement.children
        .where((node) => node.toString().startsWith("<knowledgeItem"))
        .toList();
    return knowledgeItemNodes;
  }

  /// Parses all KnowledgeItems into a list, given only the knowledge path.
  /// Is asyncronous because it uses getKnowledgeItemNodes (and in turn get
  /// DeckDocument)
  static Future<List<KnowledgeItem>> getKnowledge(String knowledgePath) async {
    List<KnowledgeItem> knowledge = [];
    List<XmlNode> knowledgeItemNodes =
        await getKnowledgeItemNodes(knowledgePath);
    XmlNode rootNode = await getDeckDocument(knowledgePath)
        .then((value) => value.root.children[2]);
    //print(rootNode.children.toString());
    List<MathUniverse> universes = parseMathUniverses(rootNode, knowledgePath);
    DateTime standardDueTime = DateTime.now();
    for (XmlNode knowledgeItemNode in knowledgeItemNodes) {
      if (knowledgeItemNode.getAttribute("type") ==
          "knowledgeMultipleChoiceTexText") {
        knowledge.add(parseKnowledgeMultipleChoiceTexText(
            knowledgeItemNode, knowledgePath, standardDueTime));
      } else if (knowledgeItemNode.getAttribute("type") ==
          "knowledgeCategory") {
        knowledge.add(parseKnowledgeCategory(
            knowledgeItemNode, knowledgePath, standardDueTime, universes));
      } else if (knowledgeItemNode.getAttribute("type") ==
          "knowledgeStatement") {
        knowledge.add(parseKnowledgeStatement(
            knowledgeItemNode, knowledgePath, standardDueTime));
      }
    }
    return knowledge;
  }

  // ignore: slash_for_doc_comments
  /*****************************************************************************
   * Parsing different Knowledge Items
   ****************************************************************************/

  //TODO: For every ! your find in this file, add a try catch with a corresponding exception

  /// Returns a list containing all MathUniverse-Instances that are stored within the given XmlDocument as direct children of the rootNode.
  static List<MathUniverse> parseMathUniverses(
    XmlNode rootNode,
    String knowledgePath,
  ) {
    List<XmlNode> mathUniverseNodes = rootNode.children
        .where((element) => element.getAttribute("type") == "mathUniverse")
        .toList();
    // The universes to be returned
    List<MathUniverse> ret = [];
    for (XmlNode mathUniverseNode in mathUniverseNodes) {
      // gives the universe an unique identifier
      String universeId = getIdFromXmlNode(mathUniverseNode, knowledgePath);

      // parses the names lists
      List<String> namesSingular = getNamesFromXmlNode(mathUniverseNode,
          nameListElementTag: "namesSingular");
      List<String> namesPlural = getNamesFromXmlNode(mathUniverseNode,
          nameListElementTag: "namesPlural");

      // parses all math objects in that universe
      List<MathObject> mathObjects =
          getMathObjectsFromXmlNode(mathUniverseNode, knowledgePath);
      // Initializes a universe object and adds it to the list
      ret.add(MathUniverse(
          universeId: universeId,
          mathObjects: mathObjects,
          namesPlural: namesPlural,
          namesSingular: namesSingular));
    }
    return ret;
  }

  /// Parses an XmlNode with the type attribute 'knowledgeCategory' into a KnowledgeCategory object.
  /// It takes the knowledgePath to generate the unique identifier and the standardDueTime from the parser
  /// ensure that the due time has been surpassed for new knowledge items.
  static KnowledgeCategory parseKnowledgeCategory(
      XmlNode knowledgeItemNode,
      String knowledgePath,
      DateTime standardDueTime,
      List<MathUniverse> universes) {
    // ID of the knowledge
    String id = knowledgePath + "." + knowledgeItemNode.getAttribute("id")!;

    // The universe is parsed by the ID and taken from the list of universes.
    // This makes it possible to have multiple categories over the same universe
    String universeId = knowledgeItemNode.getElement("universe")!.text;
    MathUniverse universe = universes.firstWhere((element) =>
        element.universeId ==
        "mathUniverse." +
            getIdFromAttributeAndKnowledgePath(knowledgePath, universeId));

    // Questions
    XmlNode questionsNode = knowledgeItemNode.children
        .firstWhere((element) => element.toString().startsWith("<questions>"));
    List<XmlNode> questionNodes = questionsNode.children
        .where((element) => element.toString().startsWith("<question>"))
        .toList();
    List<String> questions = [
      for (XmlNode questionNode in questionNodes) questionNode.text
    ];

    // indices in category
    String indicesInCategoryString = knowledgeItemNode.children
        .firstWhere(
            (element) => element.toString().startsWith("<indicesInCategory>"))
        .text;
    List<String> indicesInCategoryStrings = indicesInCategoryString.split(",");
    List<int> indicesInCategory = [
      for (String indexString in indicesInCategoryStrings)
        int.parse(indexString)
    ];

    // CategoryNamesSingular
    XmlNode categoryNamesSingularNode = knowledgeItemNode.children.firstWhere(
        (element) => element.toString().startsWith("<categoryNamesSingular"));
    List<XmlNode> categoryNamesSingularNameNodes = categoryNamesSingularNode
        .children
        .where((element) => element.toString().startsWith("<name>"))
        .toList();
    List<String> categoryNamesSingular = [
      for (XmlNode nameNode in categoryNamesSingularNameNodes) nameNode.text
    ];

    // CategoryNamesPlural
    XmlNode categoryNamesPluralNode = knowledgeItemNode.children.firstWhere(
        (element) => element.toString().startsWith("<categoryNamesPlural"));
    List<XmlNode> categoryNamesPluralNameNodes = categoryNamesPluralNode
        .children
        .where((element) => element.toString().startsWith("<name>"))
        .toList();
    List<String> categoryNamesPlural = [
      for (XmlNode nameNode in categoryNamesPluralNameNodes) nameNode.text
    ];

    // Parts of a dual category, empty by default
    List<String> dualQuestions = [];
    List<int> indicesInDualCategory = [];
    List<String> dualCategoryNamesSingular = [];
    List<String> dualCategoryNamesPlural = [];

    // Testing whether a dual category is saved. If the knowledgeItemNode
    // has any child that starts with <dual, we assume that a dual set exists
    List<XmlNode> childrenForDual = knowledgeItemNode.children
        .where((element) => element.toString().startsWith("<dual"))
        .toList();

    // Dual category is parsed, if it exists
    // Starting with dual questions
    if (childrenForDual.isNotEmpty) {
      XmlNode? dualQuestionsNode = knowledgeItemNode.children.firstWhere(
          (element) => element.toString().startsWith("<dualQuestions>"));
      List<XmlNode> dualQuestionNodes = dualQuestionsNode.children
          .where((element) => element.toString().startsWith("<question>"))
          .toList();
      dualQuestions = [
        for (XmlNode questionNode in dualQuestionNodes) questionNode.text
      ];

      // Indices in dual category
      String indicesInDualCategoryString = knowledgeItemNode.children
          .firstWhere((element) =>
              element.toString().startsWith("<indicesInDualCategory>"))
          .text;
      List<String> indicesInDualCategoryStrings =
          indicesInDualCategoryString.split(",");
      indicesInDualCategory = [
        for (String indexString in indicesInDualCategoryStrings)
          int.parse(indexString)
      ];

      // Dual Category Names Singular
      XmlNode dualCategoryNamesSingularNode = knowledgeItemNode.children
          .firstWhere((element) =>
              element.toString().startsWith("<dualCategoryNamesSingular"));
      List<XmlNode> dualCategoryNamesSingularNameNodes =
          dualCategoryNamesSingularNode.children
              .where((element) => element.toString().startsWith("<name>"))
              .toList();
      dualCategoryNamesSingular = [
        for (XmlNode nameNode in dualCategoryNamesSingularNameNodes)
          nameNode.text
      ];

      // Dual Category Names Plural
      XmlNode dualCategoryNamesPluralNode = knowledgeItemNode.children
          .firstWhere((element) =>
              element.toString().startsWith("<dualCategoryNamesPlural"));
      List<XmlNode> dualCategoryNamesPluralNameNodes =
          dualCategoryNamesPluralNode.children
              .where((element) => element.toString().startsWith("<name>"))
              .toList();
      dualCategoryNamesPlural = [
        for (XmlNode nameNode in dualCategoryNamesPluralNameNodes) nameNode.text
      ];
    }
    KnowledgeCategory ret = KnowledgeCategory(
      universe: universe,
      questions: questions,
      indicesInCategory: indicesInCategory,
      categoryNamesSingular: categoryNamesSingular,
      categoryNamesPlural: categoryNamesPlural,
      dualQuestions: dualQuestions,
      dualCategoryNamesPlural: dualCategoryNamesPlural,
      dualCategoryNamesSingular: dualCategoryNamesSingular,
      indicesInDualCategory: indicesInDualCategory,
      id: id,
    );

    return generateKnowledgeSchedulingInfo<KnowledgeCategory>(
        ret, standardDueTime);
  }

  /// Parses an XmlNode with the type attribute 'knowledgeMultipleChoiceTexText' into a KnowledgeMultipleChoiceTexText object.
  /// It takes the knowledgePath to generate the unique identifier and the standardDueTime from the parser
  /// ensure that the due time has been surpassed for new knowledge items.
  static KnowledgeMultipleChoiceTexText parseKnowledgeMultipleChoiceTexText(
    XmlNode knowledgeItemNode,
    String knowledgePath,
    DateTime standardDueTime,
  ) {
    String id = getIdFromXmlNode(knowledgeItemNode, knowledgePath);

    List<String> questions = [];
    for (XmlNode questionNode in knowledgeItemNode.children
        .where((element) => element.toString().startsWith("<questions>"))
        //The first child of the knowledgeItemNode that has the tag questions
        .toList()[0]
        // All children should be question elements, TODO: Add exception or something similar to make sure only question elements are used.
        .children
        .where((element) => element.toString().startsWith("<question>"))
        .toList()) {
      // Add the text of each question element into the list
      questions.add(questionNode.text);
    }

    // parses all correct choices
    List<String> correctChoices = [];
    for (XmlNode correctChoiceNode in knowledgeItemNode.children
        .where((element) => element.toString().startsWith("<correctChoices>"))
        .toList()[0]
        .children
        .where((element) => element.toString().startsWith("<choice"))
        .toList()) {
      correctChoices.add(correctChoiceNode.text);
    }

    // parses all incorrect choices
    List<String> incorrectChoices = [];
    for (XmlNode incorrectChoiceNode in knowledgeItemNode.children
        .where((element) => element.toString().startsWith("<incorrectChoices>"))
        .toList()[0]
        .children
        .where((element) => element.toString().startsWith("<choice"))
        .toList()) {
      incorrectChoices.add(incorrectChoiceNode.text);
    }

    // initializes the KnowledgeMultipleChoiceTextText object and adds scheduling
    // info from the hive database
    KnowledgeMultipleChoiceTexText ret = KnowledgeMultipleChoiceTexText(
        id: id,
        questions: questions,
        correctChoices: correctChoices,
        incorrectChoices: incorrectChoices);

    return generateKnowledgeSchedulingInfo<KnowledgeMultipleChoiceTexText>(
        ret, standardDueTime);
  }

  /// Parses an XmlNode with the type attribute 'knowledgeStatement' into a KnowledgeStatement object.
  /// It takes the knowledgePath to generate the unique identifier and the standardDueTime from the parser
  /// ensure that the due time has been surpassed for new knowledge items.
  static KnowledgeStatement parseKnowledgeStatement(
    XmlNode knowledgeItemNode,
    String knowledgePath,
    DateTime standardDueTime,
  ) {
    String id = getIdFromXmlNode(knowledgeItemNode, knowledgePath);

    // parsing contentItems
    XmlNode contentItemsnode = knowledgeItemNode.children.firstWhere(
        (element) => element.toString().startsWith("<contentItems>"));
    List<XmlNode> contentItemNodes = contentItemsnode.children
        .where((element) => element.toString().startsWith("<contentItem"))
        .toList();

    // Checks whether only exactly one contentItemCompletable is within the
    // statement element. If not, it throws an exception with a fitting message
    // and recommendations what to do
    int completableNodesCount = 0;
    List<String> contentItems = [];
    for (XmlNode node in contentItemNodes) {
      if (node.toString().startsWith("<contentItemCompletable/>")) {
        contentItems.add("");
        completableNodesCount++;
      } else {
        contentItems.add(node.text.trim());
      }
    }
    if (completableNodesCount != 1) {
      throw ParseException(
        "You added $completableNodesCount items of the type contentItemCompletable to $id." +
            (completableNodesCount == 0
                ? "Please add one node of the form <contentItemCompletable/> into your file."
                : "Please remove all but one node of the form <contentItemCompletable/> from your file."),
      );
    }

    // parrsing correctFillIns
    XmlNode correctFillInsNode = knowledgeItemNode.children.firstWhere(
        (element) => element.toString().startsWith("<correctFillIns>"));
    List<XmlNode> correctFillInNodes = correctFillInsNode.children
        .where((element) => element.toString().startsWith("<fillIn>"))
        .toList();

    List<String> correctFillIns = [];
    for (XmlNode node in correctFillInNodes) {
      correctFillIns.add(node.text);
    }

    // parrsing incorrectFillIns
    XmlNode incorrectFillInsNode = knowledgeItemNode.children.firstWhere(
        (element) => element.toString().startsWith("<incorrectFillIns>"));
    List<XmlNode> incorrectFillInNodes = incorrectFillInsNode.children
        .where((element) => element.toString().startsWith("<fillIn>"))
        .toList();

    List<String> incorrectFillIns = [];
    for (XmlNode node in incorrectFillInNodes) {
      incorrectFillIns.add(node.text);
    }

    // initializing the KnowledgeStatement to be returned with the parsed values
    KnowledgeStatement ret = KnowledgeStatement(
      id: id,
      contentItems: contentItems,
      correctFillIns: correctFillIns,
      incorrectFillIns: incorrectFillIns,
    );

    // retrieves the sheduling info from the hive database and returns the object
    return generateKnowledgeSchedulingInfo<KnowledgeStatement>(
        ret, standardDueTime);
  }
  /********************************************
   * Retrieving data that may be needed for many knowledge items
   ***********************************************/

  /// Retrieves the scheduling information for a given piece of knowledge from
  /// local disk (hive database) and returns the knowledgeItem with the scheduling
  /// information added to it
  static T generateKnowledgeSchedulingInfo<T extends KnowledgeItem>(
      T knowledgeItem, DateTime? standardDueTime) {
    DateTime due = KnowledgeMetadataStorage.getDue(knowledgeItem.id,
        standardDueTime: standardDueTime);
    DateTime? lastPracticed =
        KnowledgeMetadataStorage.getLastPracticed(knowledgeItem.id);
    int lastInterval =
        KnowledgeMetadataStorage.getLastInterval(knowledgeItem.id);
    knowledgeItem.due = due;
    knowledgeItem.lastInterval = lastInterval;
    knowledgeItem.lastPracticed = lastPracticed;
    return knowledgeItem;
  }

  /// Returns the correct formatting of an internal id given the KnowledgeItem-
  /// Node's id, type and the knowledgePath
  static String getIdFromAttributeAndKnowledgePath(
      String knowledgePath, String idAttribute) {
    return knowledgePath + "." + idAttribute;
  }

  /// Returns the id of a KnowledgeItem including the knowledgePath in the right format
  static String getIdFromXmlNode(
      XmlNode knowledgeItemNode, String knowledgePath) {
    return getIdFromAttributeAndKnowledgePath(
        knowledgePath, knowledgeItemNode.getAttribute("id")!);
  }

  /// Retrieves the names from an XmlNode that has an element with tag
  /// nameListElementTag with children of type name. You can specify which kind
  /// of tag your name-list has with the nameListElementTag. The KnowledgeCategory
  /// element, for example, has namesSingular and namesPluaral. You can simply call
  /// "getNamesFromXmlNode(knowledgeItemNode, nameListElementTag: "namesSingular")"
  /// to retrieve the singular-names for this category.
  static List<String> getNamesFromXmlNode(XmlNode knowledgeItemNode,
      {String nameListElementTag = "names"}) {
    XmlNode namesNode = knowledgeItemNode.children.firstWhere(
        (element) => element.toString().startsWith("<" + nameListElementTag));
    List<XmlNode> nameNodes = namesNode.children
        .where((element) => element.toString().startsWith("<name>"))
        .toList();
    List<String> names = [for (XmlNode nameNode in nameNodes) nameNode.text];

    return names;
  }

  /// Returns a list of MathObjects that are part of a universe
  static List<MathObject> getMathObjectsFromXmlNode(
      XmlNode knowledgeItemNode, String knowledgePath) {
    XmlNode mathObjectsNode = knowledgeItemNode.children.firstWhere(
        (element) => element.toString().startsWith("<mathObjects>"));
    List<XmlNode> mathObjectNodes = mathObjectsNode.children
        .where((element) => element.toString().startsWith("<mathObject"))
        .toList();
    List<String> mathObjectIds = [
      for (XmlNode mathObjectNode in mathObjectNodes)
        getIdFromXmlNode(mathObjectNode, knowledgePath)
    ];
    List<String> mathObjectRawStrings = [
      for (XmlNode mathObjectNode in mathObjectNodes) mathObjectNode.text
    ];
    List<MathObject> ret = [
      for (int i = 0; i < mathObjectIds.length; i++)
        MathObject(
            mathObjectId: mathObjectIds[i], rawString: mathObjectRawStrings[i])
    ];
    return ret;
  }
}
