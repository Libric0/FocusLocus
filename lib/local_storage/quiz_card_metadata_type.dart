/// A list of all learning information types in the same order as the HiveField IDs in the class QuizCardMetadata
/// The exact indices of these enums is FieldID + 1
enum QuizCardMetadataType {
  numberCompleted, //http://xapi.elearn.rwth-aachen.de/definitions/generic/verbs/completed
  sumPlaytime, //http://xapi.elearn.rwth-aachen.de/definitions/generic/verbs/played
  numberErrors, //http://xapi.elearn.rwth-aachen.de/definitions/generic/verbs/lost
  numberOmissionErrors, //http://xapi.elearn.rwth-aachen.de/definitions/generic/verbs/left
  numberCommissionErrors,
  numberStarted, //http://xapi.elearn.rwth-aachen.de/definitions/seriousgames/verbs/started
  numberSucceeded, //http://xapi.elearn.rwth-aachen.de/definitions/generic/verbs/won
}
