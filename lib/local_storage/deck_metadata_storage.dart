import 'package:focuslocus/local_storage/deck_metadata_storage_model.dart';
import 'package:hive/hive.dart';

/// The storage for all deck metadata. Right now, it only takes care of
/// how many times a deck was practiced.
class DeckMetadataStorage {
  static DeckMetadataStorage? _instance;
  static Box<DeckMetadataStorageModel>? _deckStorage;

  DeckMetadataStorage._();
  static Future<void> init() async {
    _instance ??= DeckMetadataStorage._();
    if (!Hive.isBoxOpen("DeckMetadata")) {
      _deckStorage = await Hive.openBox("DeckMetadata");
    }
  }

  static int getTimesPracticed(String deckId) {
    _initIfNull();
    DeckMetadataStorageModel? deck = _deckStorage!.get(deckId);
    if (deck != null) {
      return deck.timesPracticed;
    } else {
      deck = DeckMetadataStorageModel();
      _deckStorage!.put(deckId, deck);
    }
    return deck.timesPracticed;
  }

  static void incrementTimesPracticed(String deckId) {
    _initIfNull();
    DeckMetadataStorageModel? deck = _deckStorage!.get(deckId);
    if (deck != null) {
      deck.timesPracticed++;
      deck.save();
    } else {
      deck = DeckMetadataStorageModel(timesPracticed: 1);
      _deckStorage!.put(deckId, deck);
    }
  }

  static void setTimesPracticed(String deckId, int timesPracticed) {
    _initIfNull();
    DeckMetadataStorageModel? deck = _deckStorage!.get(deckId);
    if (deck != null) {
      deck.timesPracticed = timesPracticed;
      deck.save();
    } else {
      deck = DeckMetadataStorageModel(timesPracticed: timesPracticed);
      _deckStorage!.put(deckId, deck);
    }
  }

  static void _initIfNull() {
    if (_instance == null) {
      init();
    }
  }
}
