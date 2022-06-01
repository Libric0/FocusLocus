// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adhd_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ADHDTypeAdapter extends TypeAdapter<ADHDType> {
  @override
  final int typeId = 4;

  @override
  ADHDType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ADHDType.adhd;
      case 1:
        return ADHDType.noAdhdButFocusProblems;
      case 2:
        return ADHDType.noFocusProblems;
      default:
        return ADHDType.adhd;
    }
  }

  @override
  void write(BinaryWriter writer, ADHDType obj) {
    switch (obj) {
      case ADHDType.adhd:
        writer.writeByte(0);
        break;
      case ADHDType.noAdhdButFocusProblems:
        writer.writeByte(1);
        break;
      case ADHDType.noFocusProblems:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ADHDTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
