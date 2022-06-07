// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

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
