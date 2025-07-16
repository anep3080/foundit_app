import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui_constants.dart'; // Import your constants file

enum MessageType { success, error, info } // Added info type

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
    Color borderColor;
    Color iconColor;
    IconData icon;

    switch (type) {
      case MessageType.success:
        borderColor = kPrimaryGreen;
        iconColor = kPrimaryGreen;
        icon = Icons.check_circle;
        break;
      case MessageType.error:
        borderColor = kRedError;
        iconColor = kRedError;
        icon = Icons.cancel;
        break;
      case MessageType.info: // New info type styling
        borderColor = kPrimaryYellow;
        iconColor = kPrimaryYellow;
        icon = Icons.info;
        break;
    }

    return AlertDialog(
      backgroundColor: kPrimaryWhite, // White background for modal
      shape: RoundedRectangleBorder(
        borderRadius: kDefaultBorderRadius,
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
              child: const Icon(Icons.close, color: kGrey, size: 28),
            ),
          ),
          Icon(icon, color: iconColor, size: 48),
          const SizedBox(height: kMediumSpacing),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              color: kPrimaryBlack, // Black for title
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: kMediumSpacing),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: kGrey, // Grey for message body
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
        return MessageModal(
          type: type,
          title: title,
          message: message,
        );
      },
    );
  }
}
