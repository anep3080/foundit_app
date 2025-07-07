import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui_constants.dart'; // Import your constants file

enum MessageType { success, error }

class MessageModal extends StatelessWidget {
  final MessageType type;
  final String title;
  final String message;

  const MessageModal({
    super.key,
    required this.type,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = type == MessageType.success ? kGreenSuccess : kRedError;
    Color iconColor = type == MessageType.success ? kGreenSuccess : kRedError;
    IconData icon = type == MessageType.success ? Icons.check_circle : Icons.cancel;

    return AlertDialog(
      backgroundColor: kWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ),
      contentPadding: const EdgeInsets.all(30),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.close, color: Colors.grey, size: 28),
            ),
          ),
          Icon(icon, color: iconColor, size: 48),
          const SizedBox(height: 15),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              color: const Color(0xFF333333),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to show the modal
  static void show(BuildContext context, MessageType type, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MessageModal(type: type, title: title, message: message);
      },
    );
  }
}