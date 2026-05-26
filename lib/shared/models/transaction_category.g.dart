// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionCategoryAdapter extends TypeAdapter<TransactionCategory> {
  @override
  final int typeId = 2;

  @override
  TransactionCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionCategory.foodAndDining;
      case 1:
        return TransactionCategory.groceries;
      case 2:
        return TransactionCategory.transport;
      case 3:
        return TransactionCategory.billsAndUtilities;
      case 4:
        return TransactionCategory.shopping;
      case 5:
        return TransactionCategory.entertainment;
      case 6:
        return TransactionCategory.health;
      case 7:
        return TransactionCategory.investments;
      default:
        return TransactionCategory.foodAndDining;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionCategory obj) {
    switch (obj) {
      case TransactionCategory.foodAndDining:
        writer.writeByte(0);
        break;
      case TransactionCategory.groceries:
        writer.writeByte(1);
        break;
      case TransactionCategory.transport:
        writer.writeByte(2);
        break;
      case TransactionCategory.billsAndUtilities:
        writer.writeByte(3);
        break;
      case TransactionCategory.shopping:
        writer.writeByte(4);
        break;
      case TransactionCategory.entertainment:
        writer.writeByte(5);
        break;
      case TransactionCategory.health:
        writer.writeByte(6);
        break;
      case TransactionCategory.investments:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
