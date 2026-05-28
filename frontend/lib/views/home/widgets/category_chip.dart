import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final dynamic icon;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppTheme.space2),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space4,
          vertical: AppTheme.space2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.white : AppTheme.borderSubtle,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon is IconData
                ? Icon(
                    icon as IconData,
                    size: 16,
                    color: isSelected ? Colors.black : AppTheme.textPrimary,
                  )
                : Image.asset(
                    icon as String,
                    width: 16,
                    height: 16,
                    color: isSelected ? Colors.black : AppTheme.textPrimary,
                  ),
            const SizedBox(width: AppTheme.space2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
