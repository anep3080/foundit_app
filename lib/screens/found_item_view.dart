import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui_constants.dart'; // Import your constants file

class FoundItemViewScreen extends StatefulWidget {
  final String itemId; // Assuming an item ID is passed

  const FoundItemViewScreen({super.key, required this.itemId});

  @override
  State<FoundItemViewScreen> createState() => _FoundItemViewScreenState();
}

class _FoundItemViewScreenState extends State<FoundItemViewScreen> {
  // Placeholder data for the item
  String _itemName = 'Found Backpack';
  String _description = 'A blue backpack containing books and a laptop. Found near the cafeteria.';
  String _dateFound = '2023-10-22'; // Changed
  String _foundLocation = 'Cafeteria'; // Changed
  String _category = 'Bags';
  String? _imageUrl = 'https://via.placeholder.com/700x700/007bff/FFFFFF?text=Found+Backpack'; // Placeholder image
  String _status = 'unclaimed'; // 'unclaimed', 'claimed', 'pending_approval', 'rejected' // Changed
  bool _isOwner = true; // Simulate if current user is the owner
  String? _reporterTelegram = '@finder_user'; // Simulate reporter's telegram

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryYellowGreen,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildContentBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'FoundIt',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(2, 2),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        Row(
          children: [
            _buildNavIcon(FontAwesomeIcons.home, 'Home', () => print('Home')),
            _buildNavIcon(FontAwesomeIcons.tachometerAlt, 'Dashboard', () => print('Dashboard')),
          ],
        ),
      ],
    );
  }

  Widget _buildNavIcon(IconData icon, String tooltip, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: kBlack, width: 2),
            ),
            child: Icon(icon, color: kBlack, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildContentBox() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: kLightYellow,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [kDefaultBoxShadow],
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: () => print('Back to Home'),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: kBlack, width: 2),
                ),
                child: const Icon(FontAwesomeIcons.arrowLeft, color: kBlack, size: 18),
              ),
            ),
          ),
          if (_isOwner && _status != 'claimed' && _status != 'rejected') // Changed
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => print('Edit Item'),
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: kYellowEdit,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: kYellowEdit, width: 2),
                  ),
                  child: const Icon(FontAwesomeIcons.edit, color: Color(0xFF333333), size: 18),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40), // Space for back/edit buttons
              Container(
                width: double.infinity,
                height: 700,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _imageUrl != null && _imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              'No Image Available',
                              style: GoogleFonts.poppins(color: const Color(0xFF666666), fontSize: 18),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          'No Image Available',
                          style: GoogleFonts.poppins(color: const Color(0xFF666666), fontSize: 18),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              Text(
                _itemName,
                style: GoogleFonts.poppins(fontSize: 32, color: const Color(0xFF333333)),
              ),
              const SizedBox(height: 5),
              _buildDetailRow('Category:', _category),
              _buildDetailRow('Date Found:', _dateFound), // Changed
              _buildDetailRow('Found Location:', _foundLocation), // Changed
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: GoogleFonts.poppins(fontSize: 20, color: const Color(0xFF333333)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _description,
                      style: GoogleFonts.poppins(fontSize: 16, color: const Color(0xFF555555)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      'Current Status:',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF333333)),
                    ),
                    const SizedBox(height: 10),
                    _buildStatusDisplay(_status),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF333333), fontSize: 15),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(color: const Color(0xFF555555), fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDisplay(String status) {
    Color bgColor;
    Color textColor;
    String displayText;

    switch (status) {
      case 'unclaimed': // Changed
        bgColor = const Color(0xFFFFE0E0); // Light red
        textColor = const Color(0xFFD9534F); // Darker red
        displayText = '❌ Unclaimed'; // Changed
        break;
      case 'claimed': // Changed
        bgColor = const Color(0xFFE6FFE6); // Light green
        textColor = const Color(0xFF5CB85C); // Darker green
        displayText = '✅ Claimed by owner'; // Changed
        break;
      case 'pending_approval':
        bgColor = const Color(0xFFFFF3CD); // Light yellow
        textColor = const Color(0xFFF0AD4E); // Darker yellow/orange
        displayText = '⏳ Pending Approval';
        break;
      case 'rejected':
        bgColor = const Color(0xFFE9ECEF); // Light grey
        textColor = const Color(0xFF6C757D); // Darker grey
        displayText = '🚫 Rejected';
        break;
      default:
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        displayText = status.replaceAll('_', ' ').toCapitalized();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        displayText,
        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: textColor),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 15,
      runSpacing: 15,
      alignment: WrapAlignment.center,
      children: [
        if (_isOwner && _status == 'unclaimed') // Changed
          ElevatedButton.icon(
            onPressed: () {
              _showConfirmationDialog('claimed'); // Changed
            },
            icon: const Icon(FontAwesomeIcons.checkCircle, color: kWhite),
            label: Text(
              'Mark as Claimed by Owner', // Changed
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF28A745), // Green
              foregroundColor: kWhite,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        if (_reporterTelegram != null && !_isOwner)
          ElevatedButton.icon(
            onPressed: () {
              print('Chat with Reporter: $_reporterTelegram');
              // Implement URL launcher for Telegram
            },
            icon: const Icon(FontAwesomeIcons.telegramPlane, color: kWhite),
            label: Text(
              'Chat with Reporter',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF17A2B8), // Info blue
              foregroundColor: kWhite,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
      ],
    );
  }

  void _showConfirmationDialog(String action) {
    String message = '';
    if (action == 'claimed') { // Changed
      message = "Are you sure you want to mark this found item as 'Claimed by owner'? This action cannot be undone."; // Changed
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kLightYellow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            'Are you sure?',
            style: GoogleFonts.poppins(color: const Color(0xFF333333), fontSize: 24),
          ),
          content: Text(
            message,
            style: GoogleFonts.poppins(color: const Color(0xFF555555), fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              style: TextButton.styleFrom(
                backgroundColor: kRedError,
                foregroundColor: kWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Text('No', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                setState(() {
                  _status = action; // Simulate status update
                });
                print('Confirmed action: $action');
              },
              style: TextButton.styleFrom(
                backgroundColor: kGreenSuccess,
                foregroundColor: kWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Text('Yes', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}

extension StringExtension on String {
  String toCapitalized() => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}