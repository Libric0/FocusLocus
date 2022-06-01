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
