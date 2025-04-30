import 'package:flutter/material.dart';

class DatePickerField extends StatelessWidget {
  final String labelText;
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;
  
  const DatePickerField({
    Key? key,
    required this.labelText,
    this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDatePicker(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: const Icon(Icons.calendar_today),
            suffixIcon: selectedDate != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => onDateSelected(null),
                  )
                : null,
          ),
          controller: TextEditingController(
            text: selectedDate != null
                ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                : '',
          ),
        ),
      ),
    );
  }
  
  Future<void> _showDatePicker(BuildContext context) async {
    final initialDate = selectedDate ?? DateTime.now();
    final firstDate = DateTime.now();
    final lastDate = DateTime.now().add(const Duration(days: 365 * 10)); // 10 years
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    
    if (pickedDate != null) {
      onDateSelected(pickedDate);
    }
  }
}
