// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biaya_operasional.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BiayaOperasionalAdapter extends TypeAdapter<BiayaOperasional> {
  @override
  final int typeId = 2;

  @override
  BiayaOperasional read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BiayaOperasional(
      id: fields[0] as String,
      namaBiaya: fields[1] as String,
      jumlah: fields[2] as double,
      tanggal: fields[3] as DateTime,
      kategori: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BiayaOperasional obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.namaBiaya)
      ..writeByte(2)
      ..write(obj.jumlah)
      ..writeByte(3)
      ..write(obj.tanggal)
      ..writeByte(4)
      ..write(obj.kategori);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiayaOperasionalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
