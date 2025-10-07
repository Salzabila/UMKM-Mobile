// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barang.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BarangAdapter extends TypeAdapter<Barang> {
  @override
  final int typeId = 0;

  @override
  Barang read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Barang(
      id: fields[0] as String,
      namaBarang: fields[1] as String,
      jenis: fields[2] as String,
      tanggalMasuk: fields[3] as DateTime,
      expired: fields[4] as DateTime?,
      stok: fields[5] as int,
      harga: fields[6] as double,
      fotoUrl: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Barang obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.namaBarang)
      ..writeByte(2)
      ..write(obj.jenis)
      ..writeByte(3)
      ..write(obj.tanggalMasuk)
      ..writeByte(4)
      ..write(obj.expired)
      ..writeByte(5)
      ..write(obj.stok)
      ..writeByte(6)
      ..write(obj.harga)
      ..writeByte(7)
      ..write(obj.fotoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarangAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
