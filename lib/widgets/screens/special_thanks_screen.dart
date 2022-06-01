import 'package:flutter/material.dart';
import 'package:focuslocus/local_storage/learning_metadata_storage.dart';
import 'package:focuslocus/util/color_transform.dart';
import 'package:focuslocus/widgets/ui_elements/folo_card.dart';

/// A screen showing a little Thank you Message to professor rossmanith for
/// letting me use his lecture material.
class SpecialThanksScreen extends StatefulWidget {
  const SpecialThanksScreen({Key? key}) : super(key: key);

  @override
  _SpecialThanksScreenState createState() => _SpecialThanksScreenState();
}

class _SpecialThanksScreenState extends State<SpecialThanksScreen> {
  bool firstBuild = true;
  List<String> cardTypes = LearningMetadataStorage.getAllCardTypes();
  List<DropdownMenuItem<String>> cardTypeMenuItems = [];
  int selectedTypeIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTransform.scaffoldBackgroundColor(Colors.blue),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        shadowColor: Colors.blue,
        title: const Text("Danke!"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: FoloCard(
          color: Colors.blue,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: const [
              Text(
                  "Vielen Dank an Professor Rossmanith dafür, dass er mich diese Übungsaufgaben mithilfe der Vorlesungsfolien hat erstellen und veröffentlichen lassen. Ebenfalls vielen dank für das Interesse an meinem Projekt!"),
            ]),
          ),
        ),
      ),
    );
  }
}
