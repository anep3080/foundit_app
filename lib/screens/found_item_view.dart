import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import '../ui_constants.dart';
import '../services/supabase_service.dart';
import '../widgets/message_modal.dart';

// Helper function to capitalize the first letter of a string
String capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return '';
  }
  return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
}

class FoundItemViewScreen extends StatefulWidget {
  final String itemId;

  const FoundItemViewScreen({super.key, required this.itemId});

  @override
  State<FoundItemViewScreen> createState() => _FoundItemViewScreenState();
}

class _FoundItemViewScreenState extends State<FoundItemViewScreen> {
  Map<String, dynamic>? _itemData;
  bool _isLoading = true;
  String? _currentUserUserType; // To store the user's type
  bool _isCurrentUserReporter = false; // To check if the current user reported this item
  String? _reporterTelegramUsername; // To store the reporter's Telegram username

  @override
  void initState() {
    super.initState();
    _fetchItemDetails();
    _fetchCurrentUserType();
  }

  Future<void> _fetchCurrentUserType() async {
    final User? currentUser = supabaseService.currentUser;
    if (currentUser != null) {
      try {
        final Map<String, dynamic> profile = await supabaseService.client
            .from('profiles')
            .select('user_type')
            .eq('id', currentUser.id)
            .single();
        setState(() {
          _currentUserUserType = profile['user_type'];
        });
      } catch (e) {
        debugPrint('Error fetching user type: $e');
        setState(() {
          _currentUserUserType = 'user'; // Default to 'user' on error
        });
      }
    } else {
      setState(() {
        _currentUserUserType = 'guest'; // Guest if not logged in
      });
    }
  }

  Future<void> _fetchItemDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final Map<String, dynamic> response = await supabaseService.client
          .from('found_items')
          .select('*, reporter_id(id, telegram_username)') // Explicitly select 'id' from reporter_id
          .eq('id', widget.itemId)
          .single();

      setState(() {
        _itemData = response;
        final User? currentUser = supabaseService.currentUser;

        debugPrint('Fetched item data: $_itemData'); // Debug print
        debugPrint('Current User ID: ${currentUser?.id}'); // Debug print
        debugPrint('Type of response[\'reporter_id\']: ${response['reporter_id'].runtimeType}'); // Added debug

        if (currentUser != null && _itemData!['reporter_id'] != null) {
          String? itemReporterId;
          String? fetchedTelegramUsername;

          if (response['reporter_id'] is Map) {
            final Map reporterMap = response['reporter_id'];
            itemReporterId = reporterMap['id'] as String?; // This should now correctly get the ID
            fetchedTelegramUsername = reporterMap['telegram_username'] as String?;
          } else if (response['reporter_id'] is String) {
            // This path is less likely if the foreign key is correctly set up
            itemReporterId = response['reporter_id'] as String?;
            fetchedTelegramUsername = null; // Cannot get telegram username without successful join
          } else {
            // Fallback for any other unexpected type or null
            itemReporterId = null;
            fetchedTelegramUsername = null;
          }

          _reporterTelegramUsername = fetchedTelegramUsername;
          _isCurrentUserReporter = (itemReporterId != null && currentUser != null && itemReporterId == currentUser.id);

          debugPrint('Item Reporter ID: $itemReporterId'); // Debug print
          debugPrint('Is Current User Reporter: $_isCurrentUserReporter'); // Debug print
          debugPrint('Reporter Telegram Username: $_reporterTelegramUsername'); // Debug print

        } else {
          _isCurrentUserReporter = false;
          _reporterTelegramUsername = null;
          debugPrint('No current user or reporter_id is null in item data.');
        }
      });
    } catch (e) {
      debugPrint('Error fetching found item details: $e');
      MessageModal.show(
        context,
        MessageType.error,
        'Error',
        'Failed to load item details: ${e.toString()}',
      );
      // Removed Navigator.pop(context); here to keep the "Item not found" message visible
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateItemStatus(String newStatus) async {
    if (_itemData == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await supabaseService.client
          .from('found_items')
          .update({'status': newStatus})
          .eq('id', widget.itemId);

      MessageModal.show(
        context,
        MessageType.success,
        'Success!',
        'Item status updated to ${capitalizeFirstLetter(newStatus)}.',
      );
      _fetchItemDetails(); // Refresh details after update
    } catch (e) {
      debugPrint('Error updating item status: $e');
      MessageModal.show(
        context,
        MessageType.error,
        'Update Failed',
        'Failed to update item status: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to launch Telegram
  Future<void> _launchTelegram(String username) async {
    final Uri telegramUrl = Uri.parse('https://t.me/$username');
    if (await canLaunchUrl(telegramUrl)) {
      await launchUrl(telegramUrl);
    } else {
      MessageModal.show(
        context,
        MessageType.error,
        'Error',
        'Could not launch Telegram. Make sure the app is installed or the username is correct.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryYellowGreen,
      appBar: AppBar(
        backgroundColor: kDarkRed,
        title: Text(
          _itemData?['item_name'] ?? 'Found Item Details',
          style: GoogleFonts.poppins(
            color: kWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kWhite),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_itemData != null && _currentUserUserType == 'admin')
            PopupMenuButton<String>(
              onSelected: (String result) {
                _updateItemStatus(result);
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'unclaimed',
                  enabled: _itemData!['status'] != 'unclaimed',
                  child: Text('Mark as Unclaimed', style: GoogleFonts.poppins()),
                ),
                PopupMenuItem<String>(
                  value: 'claimed',
                  enabled: _itemData!['status'] != 'claimed',
                  child: Text('Mark as Claimed', style: GoogleFonts.poppins()),
                ),
                PopupMenuItem<String>(
                  value: 'pending_approval',
                  enabled: _itemData!['status'] != 'pending_approval',
                  child: Text('Mark as Pending Approval', style: GoogleFonts.poppins()),
                ),
                PopupMenuItem<String>(
                  value: 'rejected',
                  enabled: _itemData!['status'] != 'rejected',
                  child: Text('Mark as Rejected', style: GoogleFonts.poppins()),
                ),
              ],
              icon: const Icon(Icons.more_vert, color: kWhite),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kDarkRed))
          : _itemData == null
              ? Center(
                  child: Text(
                    'Item not found or an error occurred.',
                    style: GoogleFonts.poppins(color: kGrey, fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: kDefaultPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: kLightGrey,
                            borderRadius: kDefaultBorderRadius,
                            image: _itemData!['image_url'] != null && _itemData!['image_url'].isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(_itemData!['image_url']),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _itemData!['image_url'] == null || _itemData!['image_url'].isEmpty
                              ? Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 80,
                                    color: kGrey,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: kLargeSpacing),
                      Text(
                        _itemData!['item_name'] ?? 'N/A',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: kDarkRed,
                        ),
                      ),
                      const SizedBox(height: kMediumSpacing),
                      _buildDetailRow(
                          'Description', _itemData!['description'] ?? 'N/A'),
                      _buildDetailRow('Date Found', _itemData!['date_found'] ?? 'N/A'),
                      _buildDetailRow(
                          'Found Location', _itemData!['found_location'] ?? 'N/A'),
                      _buildDetailRow(
                          'Category', capitalizeFirstLetter(_itemData!['category'] ?? 'N/A')),
                      _buildDetailRow(
                          'Status', capitalizeFirstLetter(_itemData!['status'] ?? 'N/A'),
                          isStatus: true),
                      const SizedBox(height: kLargeSpacing),
                      // Conditional buttons based on user type and item status
                      if (_itemData!['status'] == 'unclaimed')
                        if (_isCurrentUserReporter)
                          Center(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () => _updateItemStatus('claimed'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kGreenSuccess,
                                foregroundColor: kWhite,
                                padding: const EdgeInsets.symmetric(horizontal: kLargeSpacing, vertical: kMediumSpacing),
                                shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius),
                                elevation: 5,
                              ),
                              child: Text('Mark as Claimed', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            ),
                          )
                        else if (_reporterTelegramUsername != null && _reporterTelegramUsername!.isNotEmpty)
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : () => _launchTelegram(_reporterTelegramUsername!),
                              icon: const Icon(Icons.chat),
                              label: Text('Chat with Reporter', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kBlueInfo, // Use a suitable color for chat
                                foregroundColor: kWhite,
                                padding: const EdgeInsets.symmetric(horizontal: kLargeSpacing, vertical: kMediumSpacing),
                                shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius),
                                elevation: 5,
                              ),
                            ),
                          ),
                      if (_itemData!['status'] == 'claimed')
                        Center(
                          child: Text(
                            'This item has been claimed.',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: kGreenSuccess,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    Color? valueColor;
    if (isStatus) {
      switch (value.toLowerCase()) {
        case 'unclaimed':
          valueColor = kRedError;
          break;
        case 'claimed':
          valueColor = kGreenSuccess;
          break;
        case 'pending_approval':
          valueColor = kGrey;
          break;
        case 'rejected':
          valueColor = kBlack;
          break;
        default:
          valueColor = kBlack;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSmallSpacing / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Align labels
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF333333),
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: valueColor ?? kBlack,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
