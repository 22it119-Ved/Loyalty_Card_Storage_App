import 'package:flutter/material.dart';
import 'package:loyalty_card_app/models/loyalty_card.dart';
import 'dart:io';

class CardListItem extends StatelessWidget {
  final LoyaltyCard card;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  
  const CardListItem({
    Key? key,
    required this.card,
    required this.onTap,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Card color indicator
            Container(
              width: 12,
              height: double.infinity,
              decoration: BoxDecoration(
                color: card.color != null
                    ? Color(int.parse(card.color!))
                    : Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            
            // Card logo
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(12),
              child: card.localLogoPath != null
                  ? Image.file(
                      File(card.localLogoPath!),
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.credit_card,
                          size: 40,
                          color: Colors.grey,
                        );
                      },
                    )
                  : const Icon(
                      Icons.credit_card,
                      size: 40,
                      color: Colors.grey,
                    ),
            ),
            
            // Card info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Card: ${card.cardNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (card.expiryDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Expires: ${_formatDate(card.expiryDate!)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Favorite button
            IconButton(
              icon: Icon(
                card.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: card.isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: onFavoriteToggle,
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
