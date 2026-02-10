import 'package:flutter/material.dart';
import '../models/transaction_options.dart';
import '../theme/app_theme.dart';

class RecurrenceSelectionScreen extends StatelessWidget {
  final RecurrenceType selectedRecurrence;
  final Function(RecurrenceType) onSelected;

  const RecurrenceSelectionScreen({
    super.key,
    required this.selectedRecurrence,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Tekrar',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 48), // Spacer to balance the close button
              ],
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: RecurrenceType.values.length,
              separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.05), height: 1),
              itemBuilder: (context, index) {
                final type = RecurrenceType.values[index];
                final isSelected = type == selectedRecurrence;

                return ListTile(
                  title: Text(
                    type.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: isSelected 
                      ? const Icon(Icons.check, size: 14, color: AppTheme.primaryColor)
                      : const SizedBox(width: 14, height: 14),
                  ),
                  onTap: () {
                    onSelected(type);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
