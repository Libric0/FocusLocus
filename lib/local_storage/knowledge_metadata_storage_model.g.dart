// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'knowledge_metadata_storage_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KnowledgeMetadataStorageModelAdapter
    extends TypeAdapter<KnowledgeMetadataStorageModel> {
  @override
  final int typeId = 3;

  @override
  KnowledgeMetadataStorageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KnowledgeMetadataStorageModel(
      due: fields[0] as DateTime?,
      lastPracticed: fields[1] as DateTime?,
      lastInterval: fields[2] == null ? 0 : fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, KnowledgeMetadataStorageModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.due)
      ..writeByte(1)
      ..write(obj.lastPracticed)
      ..writeByte(2)
      ..write(obj.lastInterval);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnowledgeMetadataStorageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
