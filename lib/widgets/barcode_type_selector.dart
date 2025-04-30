import 'package:flutter/material.dart';

class BarcodeTypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String) onChanged;
  
  const BarcodeTypeSelector({
    Key? key,
    required this.selectedType,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Barcode Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTypeChip('QR_CODE', 'QR Code'),
            _buildTypeChip('CODE_128', 'Code 128'),
            _buildTypeChip('EAN_13', 'EAN-13'),
            _buildTypeChip('EAN_8', 'EAN-8'),
            _buildTypeChip('UPC_A', 'UPC-A'),
            _buildTypeChip('CODE_39', 'Code 39'),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTypeChip(String type, String label) {
    final isSelected = selectedType == type;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onChanged(type);
        }
      },
    );
  }
}
