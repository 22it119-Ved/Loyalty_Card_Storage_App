import 'package:hive/hive.dart';

part 'loyalty_card.g.dart';

@HiveType(typeId: 0)
class LoyaltyCard {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String barcode;

  @HiveField(3)
  final String barcodeType;

  @HiveField(4)
  final String cardNumber;

  @HiveField(5)
  final String? logoUrl;

  @HiveField(6)
  final String? color;

  @HiveField(7)
  final DateTime? expiryDate;

  @HiveField(8)
  final String? notes;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  @HiveField(11)
  final bool isFavorite;

  @HiveField(12)
  final String? localLogoPath;

  @HiveField(13)
  final bool isDeleted;

  LoyaltyCard({
    required this.id,
    required this.name,
    required this.barcode,
    required this.barcodeType,
    required this.cardNumber,
    this.logoUrl,
    this.color,
    this.expiryDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.localLogoPath,
    this.isDeleted = false,
  });

  LoyaltyCard copyWith({
    String? id,
    String? name,
    String? barcode,
    String? barcodeType,
    String? cardNumber,
    String? logoUrl,
    String? color,
    DateTime? expiryDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    String? localLogoPath,
    bool? isDeleted,
  }) {
    return LoyaltyCard(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      barcodeType: barcodeType ?? this.barcodeType,
      cardNumber: cardNumber ?? this.cardNumber,
      logoUrl: logoUrl ?? this.logoUrl,
      color: color ?? this.color,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      localLogoPath: localLogoPath ?? this.localLogoPath,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'barcodeType': barcodeType,
      'cardNumber': cardNumber,
      'logoUrl': logoUrl,
      'color': color,
      'expiryDate': expiryDate?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
      'isDeleted': isDeleted,
    };
  }

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      id: json['id'],
      name: json['name'],
      barcode: json['barcode'],
      barcodeType: json['barcodeType'],
      cardNumber: json['cardNumber'],
      logoUrl: json['logoUrl'],
      color: json['color'],
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isFavorite: json['isFavorite'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}
