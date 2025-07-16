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

class LostItemViewScreen extends StatefulWidget {
  final String itemId;

  const LostItemViewScreen({super.key, required this.itemId});

  @override
  State<LostItemViewScreen> createState() => _LostItemViewScreenState();
}

class _LostItemViewScreenState extends State<LostItemViewScreen> {
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
        final profile = await supabaseService.client
            .from('profiles')
            .select('user_type, telegram_username')
            .eq('id', currentUser.id)
            .single();
        setState(() {
          _currentUserUserType = profile['user_type'];
        });
      } catch (e) {
        debugPrint('Error fetching current user type: $e');
      }
    }
  }

  Future<void> _fetchItemDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Corrected the foreign key reference to 'reporter_id' based on old working code
      final response = await supabaseService.client
          .from('lost_items')
          .select('''
            *,
            profiles!reporter_id(telegram_username)
          ''')
          .eq('id', widget.itemId)
          .maybeSingle(); // Use maybeSingle()

      setState(() {
        _itemData = response; // response will be null if no record found
        if (_itemData != null) {
          // Access telegram_username from the nested 'profiles' map
          _reporterTelegramUsername = (_itemData!['profiles'] as Map<String, dynamic>?)?['telegram_username'];
          _isCurrentUserReporter = supabaseService.currentUser?.id == _itemData!['user_id'];

          // Add debug prints here
          debugPrint('LostItemView - _isCurrentUserReporter: $_isCurrentUserReporter');
          debugPrint('LostItemView - Item Status: ${_itemData!['status']}');
          debugPrint('LostItemView - Current User ID: ${supabaseService.currentUser?.id}');
          debugPrint('LostItemView - Item Reporter ID (user_id): ${_itemData!['user_id']}');

        }
      });
    } catch (e) {
      debugPrint('Error fetching lost item details: $e');
      // Log the specific error type and message for better debugging
      debugPrint('Supabase Query Error in LostItemViewScreen: ${e.runtimeType} - ${e.toString()}');
      MessageModal.show(context, MessageType.error, 'Error', 'Failed to load item details.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateItemStatus(String newStatus) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await supabaseService.client
          .from('lost_items')
          .update({'status': newStatus})
          .eq('id', widget.itemId);

      MessageModal.show(context, MessageType.success, 'Success', 'Item status updated to $newStatus.');
      _fetchItemDetails(); // Refresh details
    } catch (e) {
      debugPrint('Error updating item status: $e');
      MessageModal.show(context, MessageType.error, 'Error', 'Failed to update item status.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchTelegram(String username) async {
    final url = 'https://t.me/$username';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      MessageModal.show(context, MessageType.error, 'Error', 'Could not launch Telegram. Make sure the app is installed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground, // Use new background color
      appBar: AppBar(
        backgroundColor: kBackground, // Match app bar background
        elevation: 0,
        title: Text(
          'Lost Item Details',
          style: GoogleFonts.poppins(
            color: kPrimaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: kPrimaryBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryYellow))
          : _itemData == null // Check if _itemData is null (meaning no record found)
              ? Center(
                  child: Text(
                    'Item not found or no longer exists.', // More specific message
                    style: GoogleFonts.poppins(color: kGrey),
                  ),
                )
              : SingleChildScrollView(
                  padding: kDefaultPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item Image
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: kLightGrey,
                          borderRadius: kDefaultBorderRadius,
                          boxShadow: [
                            kNeumorphicShadowDark,
                            kNeumorphicShadowLight,
                          ],
                          image: _itemData!['image_url'] != null && _itemData!['image_url'].isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(_itemData!['image_url']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _itemData!['image_url'] == null || _itemData!['image_url'].isEmpty
                            ? Icon(
                                Icons.image_not_supported,
                                color: kGrey,
                                size: 80,
                              )
                            : null,
                      ),
                      const SizedBox(height: kLargeSpacing),
                      // Item Name
                      Text(
                        _itemData!['item_name'] ?? 'N/A',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryBlack,
                        ),
                      ),
                      const SizedBox(height: kMediumSpacing),
                      // Details Section
                      Container(
                        padding: kMediumPadding,
                        decoration: BoxDecoration(
                          color: kBackground,
                          borderRadius: kDefaultBorderRadius,
                          boxShadow: [
                            kNeumorphicShadowDark,
                            kNeumorphicShadowLight,
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(label: 'Category', value: capitalizeFirstLetter(_itemData!['category'] ?? 'N/A')),
                            _buildDetailRow(label: 'Status', value: capitalizeFirstLetter(_itemData!['status'] ?? 'Not Found'), isStatus: true),
                            _buildDetailRow(label: 'Description', value: _itemData!['description'] ?? 'N/A'),
                            _buildDetailRow(label: 'Lost Location', value: _itemData!['lost_location'] ?? 'N/A'),
                            _buildDetailRow(label: 'Date Lost', value: _itemData!['date_lost'] ?? 'N/A'),
                            _buildDetailRow(label: 'Reported By', value: _itemData!['reporter_name'] ?? 'Anonymous'),
                            // Access telegram_username from the nested 'profiles' map
                            if (_reporterTelegramUsername != null && _reporterTelegramUsername!.isNotEmpty)
                              _buildDetailRow(label: 'Reporter Telegram', value: '@$_reporterTelegramUsername'),
                          ],
                        ),
                      ),
                      const SizedBox(height: kLargeSpacing),

                      // Action Buttons (Conditional Visibility)
                      // Admin actions
                      if (_currentUserUserType == 'admin' && _itemData!['status'] == 'pending_approval') ...[
                        _buildActionButton(
                          text: 'Approve Claim',
                          color: kPrimaryGreen,
                          onPressed: () => _updateItemStatus('claimed'),
                        ),
                        const SizedBox(height: kMediumSpacing),
                        _buildActionButton(
                          text: 'Reject Claim',
                          color: kRedError,
                          onPressed: () => _updateItemStatus('not found'), // Revert to not found
                        ),
                      ],

                      // Reporter actions
                      Visibility(
                        visible: _isCurrentUserReporter && _itemData!['status'] == 'not found' && !_isLoading,
                        child: Center(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () => _updateItemStatus('found'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryYellow,
                              foregroundColor: kPrimaryWhite,
                              padding: const EdgeInsets.symmetric(horizontal: kLargeSpacing, vertical: kMediumSpacing),
                              shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius),
                              elevation: 5,
                            ),
                            child: Text('Mark as Found', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),

                      // Other user actions (Chat with Reporter)
                      Visibility(
                        visible: !_isCurrentUserReporter && _reporterTelegramUsername != null && _reporterTelegramUsername!.isNotEmpty && !_isLoading,
                        child: Column(
                          children: [
                            const SizedBox(height: kMediumSpacing),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : () => _launchTelegram(_reporterTelegramUsername!),
                                icon: const Icon(Icons.chat),
                                label: Text('Chat with Reporter', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kBlueInfo, // Use a suitable color for chat
                                  foregroundColor: kPrimaryWhite,
                                  padding: const EdgeInsets.symmetric(horizontal: kLargeSpacing, vertical: kMediumSpacing),
                                  shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius),
                                  elevation: 5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status message for found/claimed items
                      if (_itemData!['status'].toString().toLowerCase().trim() == 'found' || _itemData!['status'].toString().toLowerCase().trim() == 'claimed')
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: kMediumSpacing),
                            child: Text(
                              'This item has been ${_itemData!['status']}.',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _itemData!['status'].toString().toLowerCase().trim() == 'found' ? kPrimaryYellow : kPrimaryGreen,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isStatus = false,
  }) {
    Color? valueColor;
    if (isStatus) {
      switch (value.toLowerCase().trim()) {
        case 'not found':
          valueColor = kRedError;
          break;
        case 'found':
          valueColor = kPrimaryYellow; // Use yellow for 'Found' status in Lost items
          break;
        case 'claimed':
          valueColor = kPrimaryGreen; // Use green for claimed
          break;
        case 'pending approval': // Changed from pending_approval for display
          valueColor = kGrey;
          break;
        case 'rejected':
          valueColor = kPrimaryBlack; // Use black for rejected
          break;
        default:
          valueColor = kPrimaryBlack;
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
                color: kPrimaryBlack, // Label color
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: valueColor ?? kPrimaryBlack, // Value color
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTapDown: (_) {
        if (onPressed != null) {
          setState(() {
            // Apply inner shadow on press down for debossed effect
          });
        }
      },
      onTapUp: (_) {
        if (onPressed != null) {
          setState(() {
            // Revert to outer shadow on press up
          });
        }
      },
      onTapCancel: () {
        if (onPressed != null) {
          setState(() {
            // Revert to outer shadow if tap is cancelled
          });
        }
      },
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: kMediumPadding,
        decoration: BoxDecoration(
          color: color, // Use the passed color
          borderRadius: kSmallBorderRadius,
          boxShadow: onPressed != null
              ? [
                  kNeumorphicShadowDark,
                  kNeumorphicShadowLight,
                ]
              : [], // No shadow if disabled
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: kPrimaryWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
