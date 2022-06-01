// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_card_metadata_storage_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizCardMetadataStorageModelAdapter
    extends TypeAdapter<QuizCardMetadataStorageModel> {
  @override
  final int typeId = 0;

  @override
  QuizCardMetadataStorageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizCardMetadataStorageModel(
      type: fields[0] as String,
      numberStarted: fields[6] as int,
      numberCompleted: fields[1] as int,
      numberFalseCommissions: fields[5] as int,
      numberOmissionErrors: fields[4] as int,
      numberErrors: fields[3] as int,
      sumPlaytime: fields[2] as int,
      numberSucceeded: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, QuizCardMetadataStorageModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.numberCompleted)
      ..writeByte(2)
      ..write(obj.sumPlaytime)
      ..writeByte(3)
      ..write(obj.numberErrors)
      ..writeByte(4)
      ..write(obj.numberOmissionErrors)
      ..writeByte(5)
      ..write(obj.numberFalseCommissions)
      ..writeByte(6)
      ..write(obj.numberStarted)
      ..writeByte(7)
      ..write(obj.numberSucceeded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizCardMetadataStorageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
