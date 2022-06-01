import 'package:flutter/material.dart';
import 'package:focuslocus/local_storage/learning_metadata_storage.dart';
import 'package:focuslocus/local_storage/quiz_card_metadata_type.dart';
import 'package:focuslocus/util/color_transform.dart';
import 'package:focuslocus/util/string_replacements.dart';
import 'package:focuslocus/widgets/ui_elements/folo_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A screen showing the QuizCardMetadata statistics to the user in a simple
/// table. In the future, it could also use graphs.
class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool firstBuild = true;
  List<String> cardTypes = LearningMetadataStorage.getAllCardTypes();
  List<DropdownMenuItem<String>> cardTypeMenuItems = [];
  int selectedTypeIndex = 0;
  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      for (String cardType in cardTypes) {
        cardTypeMenuItems.add(
          DropdownMenuItem<String>(
            value: cardType,
            child: LimitedBox(
              maxWidth: 180,
              child: Text(
                StringReplacements
                    .internalCardTypeNameToPrettyString[cardType]!,
                style: TextStyle(color: ColorTransform.textColor(Colors.blue)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      }
      firstBuild = false;
    }
    return Scaffold(
      backgroundColor: ColorTransform.scaffoldBackgroundColor(Colors.blue),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        shadowColor: Colors.blue,
        title: const Text("Stats"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (cardTypes.isNotEmpty)
            DropdownButton(
              value: cardTypes[selectedTypeIndex],
              items: cardTypeMenuItems,
              onChanged: (String? cardTypeName) {
                if (cardTypeName != null) {
                  setState(() {
                    selectedTypeIndex = cardTypes.indexOf(cardTypeName);
                  });
                }
              },
            ),
          const SizedBox(
            width: 12,
          )
        ],
      ),
      body: cardTypes.isEmpty
          ? Center(
              child: Text(
              AppLocalizations.of(context)!.statsScreenNothingDoneYet,
              textAlign: TextAlign.center,
            ))
          : Center(
              child: FoloCard(
                color: Colors.blue,
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context)!
                            .statsScreenColumnLabelName,
                        style: TextStyle(
                          color: ColorTransform.textColor(Colors.blue),
                        ),
                      ),
                    ),
                    DataColumn(
                        label: Text(
                      AppLocalizations.of(context)!
                          .statsScreenColumnLabelContent,
                      style: TextStyle(
                        color: ColorTransform.textColor(Colors.blue),
                      ),
                    ))
                  ],
                  rows: [
                    for (QuizCardMetadataType type
                        in QuizCardMetadataType.values)
                      DataRow(
                        cells: [
                          DataCell(Text(
                            type.name,
                            style: TextStyle(
                              color: ColorTransform.textColor(Colors.blue),
                            ),
                          )),
                          DataCell(
                            Text(
                              LearningMetadataStorage.get(
                                      cardTypes[selectedTypeIndex], type)
                                  .toString(),
                              style: TextStyle(
                                color: ColorTransform.textColor(Colors.blue),
                              ),
                            ),
                          )
                        ],
                      )
                  ],
                ),
              ),
            ),
    );
  }
}
