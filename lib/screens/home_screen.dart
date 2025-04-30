import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loyalty_card_app/services/auth_service.dart';
import 'package:loyalty_card_app/services/card_service.dart';
import 'package:loyalty_card_app/services/sync_service.dart';
import 'package:loyalty_card_app/widgets/sync_status_indicator.dart';
import 'package:loyalty_card_app/widgets/card_grid_item.dart';
import 'package:loyalty_card_app/screens/add_card_screen.dart';
import 'package:loyalty_card_app/screens/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Everyday Rewards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SyncStatusIndicator(
            isOnline: true,
            isSyncing: false,
            lastSyncTime: null,
          ),
          Expanded(
            child: Consumer<CardService>(
              builder: (context, cardService, _) {
                final cards = cardService.cards;
                
                if (cards.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.card_giftcard,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No cards yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your first card',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return CardGridItem(
                      card: card,
                      onTap: () {
                        // TODO: Navigate to card details
                      },
                      onFavoriteToggle: () {
                        cardService.toggleFavorite(card.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCardScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
