// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pelanggan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PelangganAdapter extends TypeAdapter<Pelanggan> {
  @override
  final int typeId = 1;

  @override
  Pelanggan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pelanggan(
      id: fields[0] as String,
      namaLengkap: fields[1] as String,
      nomorHp: fields[2] as String,
      email: fields[3] as String?,
      fotoPath: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Pelanggan obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.namaLengkap)
      ..writeByte(2)
      ..write(obj.nomorHp)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.fotoPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PelangganAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
