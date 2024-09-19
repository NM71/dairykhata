import 'package:hive_flutter/hive_flutter.dart';

@HiveType(typeId: 0)
class MilkRecord extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final MilkType type;

  @HiveField(2)
  final double quantity;

  MilkRecord(this.date, this.type, this.quantity);
}

@HiveType(typeId: 1)
enum MilkType {
  @HiveField(0)
  cow,

  @HiveField(1)
  buffalo
}

class MilkRecordAdapter extends TypeAdapter<MilkRecord> {
  @override
  final int typeId = 0;

  @override
  MilkRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MilkRecord(
      fields[0] as DateTime,
      fields[1] as MilkType,
      fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, MilkRecord obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MilkRecordAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}

class MilkTypeAdapter extends TypeAdapter<MilkType> {
  @override
  final int typeId = 1;

  @override
  MilkType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MilkType.cow;
      case 1:
        return MilkType.buffalo;
      default:
        return MilkType.cow;
    }
  }

  @override
  void write(BinaryWriter writer, MilkType obj) {
    switch (obj) {
      case MilkType.cow:
        writer.writeByte(0);
        break;
      case MilkType.buffalo:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MilkTypeAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}