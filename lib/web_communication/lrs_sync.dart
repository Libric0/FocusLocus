import 'package:flutter/material.dart';
import 'package:tincan/tincan.dart';
import 'package:focuslocus/local_storage/adhd_type.dart';
import 'package:focuslocus/local_storage/learning_metadata_storage.dart';
import 'package:focuslocus/local_storage/quiz_card_metadata_type.dart';
import 'package:focuslocus/local_storage/user_storage.dart';

/// The class that syncs the current learning metadata to the LRS at startup.
/// Additionally, it sends the ADHD Type to the LRS if it was consentet to
/// in the welcome screen.
class LrsSync {
  static late final RemoteLRS _lrs;
  static List<LRSResponse> lastresponses = [];
  LrsSync._();

  /// Initializes the LrsSync and uploads the learning data to the LRS if the last
  /// time was more than a day ago
  static Future<void> init() async {
    if (UserStorage.hasConsent) {
      _lrs = RemoteLRS(
        endpoint: '',
        username: '',
        password: 'carput draconis',
      );
    }
    if (!UserStorage.hasConsent) {
      return;
    }

    if (DateTime.now()
        .subtract(const Duration(days: 1))
        .isAfter(UserStorage.lastSynced)) {
      sendKnowledge();
    }
  }

  /// Sends a statement containing the ADHDType
  static Future<void> sendADHDType(ADHDType type,
      {BuildContext? context}) async {
    if (UserStorage.hasConsent && !UserStorage.hasUploadedADHDType) {
      try {
        LRSResponse r = await _lrs.saveStatement(
          Statement(
            actor: Agent(
                name: UserStorage.pseudonym,
                mbox:
                    "mailto:" + UserStorage.pseudonym + "@learninglocker.net"),
            verb: Verb(
              id: "http://xapi.elearn.rwth-aachen.de/definitions/generic/verbs/answered",
              display: {"en-US": "answered"},
            ),
            object: Activity(
              id: "http://xapi.elearn.rwth-aachen.de/definitions/generic/activities/question",
              definition: ActivityDefinition(
                name: {"en-US": "question"},
              ),
            ),
            result: Result(response: type.name),
          ),
        );

        UserStorage.hasUploadedADHDType = true;
        LrsSync.lastresponses.add(r);
      } catch (e) {
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  "Es konnte keine Verbindung zum LRS aufgenommen werden. Überprüfe deine Verbingung und versuch es später erneut")));
        }
      }
    }
  }

  /// Sends the current state of the learning data to the LRS.
  static Future<void> sendKnowledge({BuildContext? context}) async {
    if (UserStorage.hasConsent) {
      try {
        LRSResponse r = await _lrs.saveStatements(
          [
            for (String cardType in [
              "category_bomber",
              "category_grid_button_select",
              "multiple_choice_button",
              "multiple_choice_swiping",
              "statement_complete_selection",
              "statement_complete_typing"
            ])
              Statement(
                actor: Agent(
                    // Just a mock-actor based on the pseudonym
                    name: UserStorage.pseudonym,
                    mbox: "mailto:" +
                        UserStorage.pseudonym +
                        "@learninglocker.net"),
                verb: Verb(
                    id: "http://xapi.elearn.rwth-aachen.de/definitions/seriousgames/verbs/initialized",
                    display: {"en-US": "initialized"}),
                object: Activity(
                  id: "http://xapi.elearn.rwth-aachen.de/definitions/seriousgames/activities/game",
                  definition: ActivityDefinition(name: {"en-US": "game"}),
                ),
                // The scores received within each quiz-card-type
                result: Result(
                  extensions: Extensions(
                    {
                      "http://xapi.elearn.rwth-aachen.de/definitions/generic/extensions/result/numberCompleted":
                          LearningMetadataStorage.get(
                              cardType, QuizCardMetadataType.numberCompleted),
                      "http://xapi.elearn.rwth-aachen.de/definitions/generic/extensions/result/sumPlaytime":
                          LearningMetadataStorage.get(
                              cardType, QuizCardMetadataType.sumPlaytime),
                      "http://xapi.elearn.rwth-aachen.de/definitions/generic/extensions/result/numberErrors":
                          LearningMetadataStorage.get(
                              cardType, QuizCardMetadataType.numberErrors),
                      "http://xapi.elearn.rwth-aachen.de/definitions/generic/extensions/result/numberOmissionErrors":
                          LearningMetadataStorage.get(cardType,
                              QuizCardMetadataType.numberOmissionErrors),
                      "http://xapi.elearn.rwth-aachen.de/definitions/generic/extensions/result/numberCommissionErrors":
                          LearningMetadataStorage.get(cardType,
                              QuizCardMetadataType.numberCommissionErrors),
                      "http://xapi.elearn.rwth-aachen.de/definitions/generic/extensions/result/numberStarted":
                          LearningMetadataStorage.get(
                              cardType, QuizCardMetadataType.numberStarted),
                      "http://xapi.elearn.rwth-aachen.de/definitions/generic/extensions/result/numberSucceeded":
                          LearningMetadataStorage.get(
                              cardType, QuizCardMetadataType.numberSucceeded),
                    },
                  ),
                ),
                context: Context(
                  extensions: Extensions(
                    {
                      "http://xapi.elearn.rwth-aachen.de/definitions/seriousgames/extensions/context/gamemode":
                          cardType,
                    },
                  ),
                ),
              ),
          ],
        );
        UserStorage.markSynced();
        LrsSync.lastresponses.add(r);
      } catch (e) {
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  "Es konnte keine Verbindung zum LRS aufgenommen werden. Überprüfe deine Verbingung und versuch es später erneut")));
        }
      }
    }
  }
}

/*

*/
