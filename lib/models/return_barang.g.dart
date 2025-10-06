// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'return_barang.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReturnBarangAdapter extends TypeAdapter<ReturnBarang> {
  @override
  final int typeId = 3;

  @override
  ReturnBarang read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReturnBarang(
      id: fields[0] as String,
      barangId: fields[1] as String,
      namaBarang: fields[2] as String,
      jumlah: fields[3] as int,
      alasan: fields[4] as String,
      tanggalReturn: fields[5] as DateTime,
      petugas: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ReturnBarang obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.barangId)
      ..writeByte(2)
      ..write(obj.namaBarang)
      ..writeByte(3)
      ..write(obj.jumlah)
      ..writeByte(4)
      ..write(obj.alasan)
      ..writeByte(5)
      ..write(obj.tanggalReturn)
      ..writeByte(6)
      ..write(obj.petugas);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReturnBarangAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
