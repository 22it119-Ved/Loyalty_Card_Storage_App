import 'package:flutter/material.dart';

class ColorPicker extends StatelessWidget {
  final String? selectedColor;
  final Function(String?) onColorSelected;
  
  const ColorPicker({
    Key? key,
    this.selectedColor,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Card Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildColorOption(context, null, 'Default'),
            _buildColorOption(context, '0xFF5C6BC0', 'Blue'),
            _buildColorOption(context, '0xFFEC407A', 'Pink'),
            _buildColorOption(context, '0xFF66BB6A', 'Green'),
            _buildColorOption(context, '0xFFFFB74D', 'Orange'),
            _buildColorOption(context, '0xFF9575CD', 'Purple'),
            _buildColorOption(context, '0xFF4DD0E1', 'Cyan'),
            _buildColorOption(context, '0xFFF44336', 'Red'),
          ],
        ),
      ],
    );
  }
  
  Widget _buildColorOption(BuildContext context, String? colorValue, String label) {
    final isSelected = selectedColor == colorValue;
    final color = colorValue != null
        ? Color(int.parse(colorValue))
        : Theme.of(context).primaryColor;
    
    return GestureDetector(
      onTap: () => onColorSelected(colorValue),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? color.withOpacity(0.8)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: isSelected ? 8 : 4,
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
