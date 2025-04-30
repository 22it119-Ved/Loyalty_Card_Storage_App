import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loyalty_card_app/models/loyalty_card.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class CardService extends ChangeNotifier {
  late Box<LoyaltyCard> _cardsBox;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Uuid _uuid = const Uuid();
  bool _isInitialized = false;
  
  List<LoyaltyCard> _cards = [];
  List<LoyaltyCard> get cards => _cards.where((card) => !card.isDeleted).toList();
  List<LoyaltyCard> get favoriteCards => cards.where((card) => card.isFavorite).toList();
  
  // Initialize the service
  Future<void> initialize(String userId) async {
    if (_isInitialized) return;
    
    await Hive.initFlutter();
    Hive.registerAdapter(LoyaltyCardAdapter());
    
    // Encrypt the box with the user's ID as the key
    final encryptionKey = _generateEncryptionKey(userId);
    await _secureStorage.write(key: 'encryptionKey', value: base64Encode(encryptionKey));
    
    _cardsBox = await Hive.openBox<LoyaltyCard>(
      'cards_$userId',
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    
    _loadCards();
    _isInitialized = true;
  }
  
  // Generate encryption key from user ID
  List<int> _generateEncryptionKey(String userId) {
    final key = utf8.encode(userId);
    final digest = sha256.convert(key);
    return digest.bytes;
  }
  
  // Load cards from local storage
  void _loadCards() {
    _cards = _cardsBox.values.toList();
    notifyListeners();
  }
  
  // Add a new card
  Future<LoyaltyCard> addCard({
    required String name,
    required String barcode,
    required String barcodeType,
    required String cardNumber,
    String? logoUrl,
    String? color,
    DateTime? expiryDate,
    String? notes,
  }) async {
    final now = DateTime.now();
    String? localLogoPath;
    
    // Download and store logo locally if URL is provided
    if (logoUrl != null && logoUrl.isNotEmpty) {
      localLogoPath = await _downloadAndStoreImage(logoUrl);
    }
    
    final card = LoyaltyCard(
      id: _uuid.v4(),
      name: name,
      barcode: barcode,
      barcodeType: barcodeType,
      cardNumber: cardNumber,
      logoUrl: logoUrl,
      color: color,
      expiryDate: expiryDate,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      localLogoPath: localLogoPath,
    );
    
    await _cardsBox.put(card.id, card);
    _loadCards();
    return card;
  }
  
  // Update an existing card
  Future<LoyaltyCard> updateCard({
    required String id,
    String? name,
    String? barcode,
    String? barcodeType,
    String? cardNumber,
    String? logoUrl,
    String? color,
    DateTime? expiryDate,
    String? notes,
    bool? isFavorite,
  }) async {
    final card = _cardsBox.get(id);
    
    if (card == null) {
      throw Exception('Card not found');
    }
    
    String? localLogoPath = card.localLogoPath;
    
    // If logo URL has changed, download and store the new image
    if (logoUrl != null && logoUrl != card.logoUrl) {
      // Delete old image if it exists
      if (card.localLogoPath != null) {
        final file = File(card.localLogoPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      // Download and store new image
      if (logoUrl.isNotEmpty) {
        localLogoPath = await _downloadAndStoreImage(logoUrl);
      } else {
        localLogoPath = null;
      }
    }
    
    final updatedCard = card.copyWith(
      name: name,
      barcode: barcode,
      barcodeType: barcodeType,
      cardNumber: cardNumber,
      logoUrl: logoUrl,
      color: color,
      expiryDate: expiryDate,
      notes: notes,
      updatedAt: DateTime.now(),
      isFavorite: isFavorite,
      localLogoPath: localLogoPath,
    );
    
    await _cardsBox.put(id, updatedCard);
    _loadCards();
    return updatedCard;
  }
  
  // Toggle favorite status
  Future<void> toggleFavorite(String id) async {
    final card = _cardsBox.get(id);
    
    if (card != null) {
      final updatedCard = card.copyWith(
        isFavorite: !card.isFavorite,
        updatedAt: DateTime.now(),
      );
      
      await _cardsBox.put(id, updatedCard);
      _loadCards();
    }
  }
  
  // Delete a card (soft delete)
  Future<void> deleteCard(String id) async {
    final card = _cardsBox.get(id);
    
    if (card != null) {
      final updatedCard = card.copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
      
      await _cardsBox.put(id, updatedCard);
      _loadCards();
    }
  }
  
  // Permanently delete a card
  Future<void> permanentlyDeleteCard(String id) async {
    final card = _cardsBox.get(id);
    
    if (card != null) {
      // Delete local logo file if it exists
      if (card.localLogoPath != null) {
        final file = File(card.localLogoPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      await _cardsBox.delete(id);
      _loadCards();
    }
  }
  
  // Get a card by ID
  LoyaltyCard? getCard(String id) {
    return _cardsBox.get(id);
  }
  
  // Search cards by name
  List<LoyaltyCard> searchCards(String query) {
    if (query.isEmpty) {
      return cards;
    }
    
    final lowercaseQuery = query.toLowerCase();
    return cards.where((card) {
      return card.name.toLowerCase().contains(lowercaseQuery) ||
             card.cardNumber.toLowerCase().contains(lowercaseQuery) ||
             (card.notes?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }
  
  // Download and store image locally
  Future<String?> _downloadAndStoreImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      
      if (response.statusCode == 200) {
        final appDir = await getApplicationDocumentsDirectory();
        final filename = '${_uuid.v4()}${path.extension(imageUrl)}';
        final filePath = path.join(appDir.path, filename);
        
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        return filePath;
      }
    } catch (e) {
      debugPrint('Error downloading image: $e');
    }
    
    return null;
  }
  
  // Get cards that are about to expire
  List<LoyaltyCard> getExpiringCards({int daysThreshold = 30}) {
    final now = DateTime.now();
    final threshold = now.add(Duration(days: daysThreshold));
    
    return cards.where((card) {
      if (card.expiryDate == null) return false;
      return card.expiryDate!.isAfter(now) && card.expiryDate!.isBefore(threshold);
    }).toList();
  }
  
  // Get all cards for sync
  List<LoyaltyCard> getAllCardsForSync() {
    return _cardsBox.values.toList();
  }
  
  // Bulk update cards (used during sync)
  Future<void> bulkUpdateCards(List<LoyaltyCard> updatedCards) async {
    for (final card in updatedCards) {
      await _cardsBox.put(card.id, card);
    }
    _loadCards();
  }
  
  // Close the box when done
  Future<void> close() async {
    await _cardsBox.close();
    _isInitialized = false;
  }
}

// This adapter would be generated by Hive's build_runner
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
