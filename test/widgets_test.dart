import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loyalty_card_app/models/loyalty_card.dart';
import 'package:loyalty_card_app/widgets/card_list_item.dart';
import 'package:loyalty_card_app/widgets/card_grid_item.dart';
import 'package:loyalty_card_app/widgets/card_info_section.dart';
import 'package:loyalty_card_app/widgets/color_picker.dart';
import 'package:loyalty_card_app/widgets/confirmation_dialog.dart';
import 'package:loyalty_card_app/widgets/date_picker_field.dart';
import 'package:loyalty_card_app/widgets/settings_tile.dart';
import 'package:loyalty_card_app/widgets/sync_status_indicator.dart';

void main() {
  group('CardListItem Widget Tests', () {
    final testCard = LoyaltyCard(
      id: '1',
      name: 'Test Card',
      cardNumber: '1234567890',
      barcode: '9876543210',
      barcodeType: 'QR',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testWidgets('CardListItem displays correct information', (WidgetTester tester) async {
      bool isFavorite = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardListItem(
              card: testCard,
              onTap: () {},
              onFavoriteToggle: () {
                isFavorite = !isFavorite;
              },
            ),
          ),
        ),
      );

      expect(find.text('Test Card'), findsOneWidget);
      expect(find.text('1234567890'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('CardListItem favorite toggle works', (WidgetTester tester) async {
      bool isFavorite = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardListItem(
              card: testCard,
              onTap: () {},
              onFavoriteToggle: () {
                isFavorite = !isFavorite;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();
      expect(isFavorite, true);
    });
  });

  group('CardGridItem Widget Tests', () {
    final testCard = LoyaltyCard(
      id: '1',
      name: 'Test Card',
      cardNumber: '1234567890',
      barcode: '9876543210',
      barcodeType: 'QR',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testWidgets('CardGridItem displays correct information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardGridItem(
              card: testCard,
              onTap: () {},
              onFavoriteToggle: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Card'), findsOneWidget);
      expect(find.text('1234567890'), findsOneWidget);
    });
  });

  group('CardInfoSection Widget Tests', () {
    testWidgets('CardInfoSection displays correct information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardInfoSection(
              title: 'Test Title',
              value: 'Test Value',
              icon: Icons.info,
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Value'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });
  });

  group('ColorPicker Widget Tests', () {
    testWidgets('ColorPicker displays color options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorPicker(
              selectedColor: null,
              onColorSelected: (color) {},
            ),
          ),
        ),
      );

      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Blue'), findsOneWidget);
      expect(find.text('Pink'), findsOneWidget);
      expect(find.text('Green'), findsOneWidget);
    });
  });

  group('ConfirmationDialog Widget Tests', () {
    testWidgets('ConfirmationDialog displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ConfirmationDialog(
                      title: 'Test Title',
                      content: 'Test Content',
                      confirmText: 'Confirm',
                      cancelText: 'Cancel',
                      onConfirm: () {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });

  group('DatePickerField Widget Tests', () {
    testWidgets('DatePickerField displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DatePickerField(
              labelText: 'Test Label',
              selectedDate: DateTime.now(),
              onDateSelected: (date) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
    });
  });

  group('SettingsTile Widget Tests', () {
    testWidgets('SettingsTile displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTile(
              icon: Icons.settings,
              title: 'Test Title',
              subtitle: 'Test Subtitle',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });

  group('SyncStatusIndicator Widget Tests', () {
    testWidgets('SyncStatusIndicator displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncStatusIndicator(
              isOnline: true,
              isSyncing: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    });
  });
} 