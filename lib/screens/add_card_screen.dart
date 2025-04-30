import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loyalty_card_app/services/card_service.dart';
import 'package:loyalty_card_app/services/sync_service.dart';
import 'package:loyalty_card_app/widgets/barcode_type_selector.dart';
import 'package:loyalty_card_app/widgets/color_picker.dart';
import 'package:loyalty_card_app/widgets/date_picker_field.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({Key? key}) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _barcodeType = 'QR_CODE';
  String? _selectedColor;
  DateTime? _expiryDate;
  String? _logoUrl;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _barcodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _scanBarcode() async {
    try {
      final barcode = await FlutterBarcodeScanner.scanBarcode(
        '#FF5C6BC0',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
      
      if (barcode != '-1') {
        setState(() {
          _barcodeController.text = barcode;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to scan barcode'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _pickLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // In a real app, you would upload this image to storage
      // and get a URL back. For this example, we'll just use a placeholder.
      setState(() {
        _logoUrl = 'https://example.com/logo.png';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logo selected'),
        ),
      );
    }
  }
  
  Future<void> _saveCard() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final cardService = Provider.of<CardService>(context, listen: false);
        
        await cardService.addCard(
          name: _nameController.text,
          barcode: _barcodeController.text,
          barcodeType: _barcodeType,
          cardNumber: _cardNumberController.text,
          logoUrl: _logoUrl,
          color: _selectedColor,
          expiryDate: _expiryDate,
          notes: _notesController.text,
        );
        
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save card: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Loyalty Card'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Card Name',
                        hintText: 'e.g., Starbucks Rewards',
                        prefixIcon: Icon(Icons.card_membership),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a card name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Card number
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                        hintText: 'e.g., 1234 5678 9012 3456',
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a card number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Barcode
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _barcodeController,
                            decoration: const InputDecoration(
                              labelText: 'Barcode',
                              hintText: 'Scan or enter manually',
                              prefixIcon: Icon(Icons.qr_code),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a barcode';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _scanBarcode,
                          icon: const Icon(Icons.qr_code_scanner),
                          tooltip: 'Scan Barcode',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Barcode type
                    BarcodeTypeSelector(
                      selectedType: _barcodeType,
                      onChanged: (value) {
                        setState(() {
                          _barcodeType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Logo
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _logoUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _logoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.image, size: 30);
                                    },
                                  ),
                                )
                              : const Icon(Icons.image, size: 30),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _pickLogo,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Add Logo'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Card color
                    ColorPicker(
                      selectedColor: _selectedColor,
                      onColorSelected: (color) {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Expiry date
                    DatePickerField(
                      labelText: 'Expiry Date (Optional)',
                      selectedDate: _expiryDate,
                      onDateSelected: (date) {
                        setState(() {
                          _expiryDate = date;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Add any additional information',
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveCard,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Save Card',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
