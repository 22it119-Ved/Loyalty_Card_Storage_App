import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:loyalty_card_app/models/loyalty_card.dart';
import 'package:loyalty_card_app/services/card_service.dart';
import 'package:loyalty_card_app/screens/edit_card_screen.dart';
import 'package:loyalty_card_app/widgets/card_info_section.dart';
import 'package:loyalty_card_app/widgets/confirmation_dialog.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class CardDetailScreen extends StatelessWidget {
  final String cardId;
  
  const CardDetailScreen({
    Key? key,
    required this.cardId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardService = Provider.of<CardService>(context);
    final card = cardService.getCard(cardId);
    
    if (card == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Card Details'),
        ),
        body: const Center(
          child: Text('Card not found'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(card.name),
        actions: [
          // Toggle favorite
          IconButton(
            icon: Icon(
              card.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: card.isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              cardService.toggleFavorite(card.id);
            },
          ),
          // Share
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareCard(context, card),
          ),
          // More options
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value, card, cardService),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Card header with logo and color
            Container(
              width: double.infinity,
              height: 150,
              color: card.color != null
                  ? Color(int.parse(card.color!))
                  : Theme.of(context).primaryColor,
              child: Center(
                child: card.localLogoPath != null
                    ? Image.file(
                        File(card.localLogoPath!),
                        width: 100,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.credit_card,
                            size: 80,
                            color: Colors.white,
                          );
                        },
                      )
                    : const Icon(
                        Icons.credit_card,
                        size: 80,
                        color: Colors.white,
                      ),
              ),
            ),
            
            // Barcode section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Barcode
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data: card.barcode,
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          card.barcode,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Copy barcode button
                  TextButton.icon(
                    onPressed: () => _copyToClipboard(context, card.barcode),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Barcode'),
                  ),
                  
                  const Divider(height: 32),
                  
                  // Card information
                  CardInfoSection(
                    title: 'Card Number',
                    value: card.cardNumber,
                    icon: Icons.credit_card,
                    onCopy: () => _copyToClipboard(context, card.cardNumber),
                  ),
                  
                  if (card.expiryDate != null)
                    CardInfoSection(
                      title: 'Expiry Date',
                      value: _formatDate(card.expiryDate!),
                      icon: Icons.calendar_today,
                    ),
                  
                  if (card.notes != null && card.notes!.isNotEmpty)
                    CardInfoSection(
                      title: 'Notes',
                      value: card.notes!,
                      icon: Icons.note,
                    ),
                  
                  CardInfoSection(
                    title: 'Added On',
                    value: _formatDate(card.createdAt),
                    icon: Icons.access_time,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // In a real app, this would trigger the barcode to be displayed in fullscreen
          _showFullscreenBarcode(context, card);
        },
        icon: const Icon(Icons.fullscreen),
        label: const Text('Fullscreen'),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _shareCard(BuildContext context, LoyaltyCard card) {
    Share.share(
      'Card: ${card.name}\nNumber: ${card.cardNumber}\nBarcode: ${card.barcode}',
      subject: 'Loyalty Card Details',
    );
  }
  
  void _handleMenuAction(
    BuildContext context,
    String action,
    LoyaltyCard card,
    CardService cardService,
  ) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditCardScreen(card: card),
          ),
        );
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => ConfirmationDialog(
            title: 'Delete Card',
            content: 'Are you sure you want to delete this card?',
            confirmText: 'Delete',
            confirmColor: Colors.red,
            onConfirm: () {
              cardService.deleteCard(card.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home screen
            },
          ),
        );
        break;
    }
  }
  
  void _showFullscreenBarcode(BuildContext context, LoyaltyCard card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              card.name,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Barcode
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: card.barcode,
                        version: QrVersions.auto,
                        size: 300.0,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        card.barcode,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Card Number: ${card.cardNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
