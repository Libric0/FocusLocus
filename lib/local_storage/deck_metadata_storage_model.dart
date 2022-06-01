import 'package:hive/hive.dart';

part 'deck_metadata_storage_model.g.dart';

/// A storage model that contains all locally stored information of a deck
/// that is not part of the decks content itself, but user data.

@HiveType(typeId: 2)
class DeckMetadataStorageModel extends HiveObject {
  @HiveField(0)
  int timesPracticed;

  DeckMetadataStorageModel({this.timesPracticed = 0});
}
