// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_metadata_storage_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseMetadataStorageModelAdapter
    extends TypeAdapter<CourseMetadataStorageModel> {
  @override
  final int typeId = 1;

  @override
  CourseMetadataStorageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CourseMetadataStorageModel(
      decksUnlocked: fields[0] == null ? 0 : fields[0] as int,
      currentDeck: fields[1] == null ? 0 : fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CourseMetadataStorageModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.decksUnlocked)
      ..writeByte(1)
      ..write(obj.currentDeck);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseMetadataStorageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
