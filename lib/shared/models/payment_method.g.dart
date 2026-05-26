// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentMethodAdapter extends TypeAdapter<PaymentMethod> {
  @override
  final int typeId = 1;

  @override
  PaymentMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentMethod.upi;
      case 1:
        return PaymentMethod.card;
      case 2:
        return PaymentMethod.netBanking;
      case 3:
        return PaymentMethod.wallet;
      case 4:
        return PaymentMethod.cash;
      default:
        return PaymentMethod.upi;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentMethod obj) {
    switch (obj) {
      case PaymentMethod.upi:
        writer.writeByte(0);
        break;
      case PaymentMethod.card:
        writer.writeByte(1);
        break;
      case PaymentMethod.netBanking:
        writer.writeByte(2);
        break;
      case PaymentMethod.wallet:
        writer.writeByte(3);
        break;
      case PaymentMethod.cash:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
