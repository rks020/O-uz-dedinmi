import 'package:flutter/material.dart';

class AppSnackbar {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, Colors.green, Icons.check_circle);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, Colors.red, Icons.error);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, Colors.blue, Icons.info);
  }

  static void _show(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: color.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }
}
