// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

/// Data class that turns internal values, like the names of enums, to
/// strings that can be shown within the UI
class StringReplacements {
  /// Proper naming schemes for card types
  static Map<String, String> internalCardTypeNameToPrettyString = {
    'multiple_choice_button': 'Multiple-Choice Buttons',
    'multiple_choice_swiping': 'Multiple-Choice Swiping',
    'category_bomber': 'Category Bomber',
    'category_grid_button_select': 'Category Buttons',
    'statement_complete_selection': 'Statement-Complete Selection',
    'statement_complete_typing': 'Statement-Complete Typing'
  };
}
