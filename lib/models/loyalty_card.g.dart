// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loyalty_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoyaltyCardAdapter extends TypeAdapter<LoyaltyCard> {
  @override
  final int typeId = 0;

  @override
  LoyaltyCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoyaltyCard(
      id: fields[0] as String,
      name: fields[1] as String,
      barcode: fields[2] as String,
      barcodeType: fields[3] as String,
      cardNumber: fields[4] as String,
      logoUrl: fields[5] as String?,
      color: fields[6] as String?,
      expiryDate: fields[7] as DateTime?,
      notes: fields[8] as String?,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      isFavorite: fields[11] as bool,
      localLogoPath: fields[12] as String?,
      isDeleted: fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LoyaltyCard obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.barcode)
      ..writeByte(3)
      ..write(obj.barcodeType)
      ..writeByte(4)
      ..write(obj.cardNumber)
      ..writeByte(5)
      ..write(obj.logoUrl)
      ..writeByte(6)
      ..write(obj.color)
      ..writeByte(7)
      ..write(obj.expiryDate)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.isFavorite)
      ..writeByte(12)
      ..write(obj.localLogoPath)
      ..writeByte(13)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoyaltyCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
