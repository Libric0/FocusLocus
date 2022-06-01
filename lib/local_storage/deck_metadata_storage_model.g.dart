// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_metadata_storage_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeckMetadataStorageModelAdapter
    extends TypeAdapter<DeckMetadataStorageModel> {
  @override
  final int typeId = 2;

  @override
  DeckMetadataStorageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeckMetadataStorageModel(
      timesPracticed: fields[0] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DeckMetadataStorageModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.timesPracticed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeckMetadataStorageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
