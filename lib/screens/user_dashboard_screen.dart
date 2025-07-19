import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui_constants.dart';
import '../services/supabase_service.dart';
import '../widgets/message_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase types
import 'dart:async'; // Import for Timer

// Helper function to capitalize the first letter of a string
String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return '';
  return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
}

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  List<Map<String, dynamic>> _userLostItems = [];
  List<Map<String, dynamic>> _userFoundItems = [];
  bool _isLoading = true;
  String? _currentUserId; // To store the current user's ID

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedLostStatus; // Specific for lost items
  String? _selectedFoundStatus; // Specific for found items

  Timer? _debounce; // For debouncing search input
  String _lastSearchedText = ''; // To store the last text that triggered a search

  final List<String> _categories = [
    'All', 'Electronics', 'Documents', 'Clothing', 'Keys', 'Bags', 'Jewelry',
    'Wallets', 'Books', 'Other', 'Accessories'
  ];
  final List<String> _lostStatuses = [
    'All', 'Not Found', 'Found', 'Claimed', 'Pending Approval', 'Rejected'
  ];
  final List<String> _foundStatuses = [
    'All', 'Unclaimed', 'Claimed', 'Pending Approval', 'Rejected'
  ];

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserIdAndReports(); // Combined fetch for user ID and reports
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel(); // Cancel any active debounce timer
    super.dispose();
  }

  // New method to fetch current user ID and then reports
  Future<void> _fetchCurrentUserIdAndReports() async {
    final User? currentUser = supabaseService.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUserId = currentUser.id;
      });
      debugPrint('UserDashboardScreen - Initial Current User ID: $_currentUserId');
      _selectedCategory = _categories.first; // Initialize with 'All'
      _selectedLostStatus = _lostStatuses.first; // Initialize with 'All'
      _selectedFoundStatus = _foundStatuses.first; // Initialize with 'All'
      _fetchUserReports();
    } else {
      // If user is not logged in, show error and navigate to auth screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        MessageModal.show(context, MessageType.error, 'Access Denied', 'You must be logged in to view this page.');
        Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
      });
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_lastSearchedText != _searchController.text) {
        setState(() {
          _searchQuery = _searchController.text;
          _lastSearchedText = _searchController.text;
        });
        _fetchUserReports(); // Re-fetch items with new search query
      }
    });
  }

  Future<void> _fetchUserReports() async {
    // Only fetch if _currentUserId is available
    if (_currentUserId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    debugPrint('UserDashboardScreen - Fetching user reports for ID: $_currentUserId');
    try {
      // Start building lost items query
      var lostQuery = supabaseService.client
          .from('lost_items')
          .select()
          .eq('reporter_id', _currentUserId!);

      // Apply search filter for lost items
      if (_searchQuery.isNotEmpty) {
        lostQuery = lostQuery.ilike('item_name', '%$_searchQuery%');
      }

      // Apply category filter for lost items
      if (_selectedCategory != 'All' && _selectedCategory != null) {
        // FIX: Use capitalizeFirstLetter for category filter
        lostQuery = lostQuery.eq('category', capitalizeFirstLetter(_selectedCategory!));
      }

      // Apply status filter for lost items
      if (_selectedLostStatus != 'All' && _selectedLostStatus != null) {
        lostQuery = lostQuery.eq('status', _selectedLostStatus!.toLowerCase().replaceAll(' ', '_'));
      }

      // Finally, apply ordering for lost items
      final lostResponse = await lostQuery.order('created_at', ascending: false);

      // Start building found items query
      var foundQuery = supabaseService.client
          .from('found_items')
          .select()
          .eq('reporter_id', _currentUserId!);

      // Apply search filter for found items
      if (_searchQuery.isNotEmpty) {
        foundQuery = foundQuery.ilike('item_name', '%$_searchQuery%');
      }

      // Apply category filter for found items
      if (_selectedCategory != 'All' && _selectedCategory != null) {
        // FIX: Use capitalizeFirstLetter for category filter
        foundQuery = foundQuery.eq('category', capitalizeFirstLetter(_selectedCategory!));
      }

      // Apply status filter for found items
      if (_selectedFoundStatus != 'All' && _selectedFoundStatus != null) {
        foundQuery = foundQuery.eq('status', _selectedFoundStatus!.toLowerCase().replaceAll(' ', '_'));
      }

      // Finally, apply ordering for found items
      final foundResponse = await foundQuery.order('created_at', ascending: false);

      setState(() {
        _userLostItems = lostResponse;
        _userFoundItems = foundResponse;
        debugPrint('UserDashboardScreen - Fetched Lost Items: ${_userLostItems.length}');
        debugPrint('UserDashboardScreen - Fetched Found Items: ${_userFoundItems.length}');
      });
    } catch (e) {
      debugPrint('UserDashboardScreen - Error fetching user reports: $e');
      if (mounted) {
        MessageModal.show(context, MessageType.error, 'Error', 'Failed to load your reports: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateItemStatus(String itemId, String itemType, String newStatus) async {
    setState(() => _isLoading = true);
    try {
      if (itemType == 'Lost') {
        await supabaseService.client
            .from('lost_items')
            .update({'status': newStatus})
            .eq('id', itemId);
      } else { // itemType == 'Found'
        await supabaseService.client
            .from('found_items')
            .update({'status': newStatus})
            .eq('id', itemId);
      }
      if (mounted) {
        MessageModal.show(context, MessageType.success, 'Success', 'Item status updated to ${capitalizeFirstLetter(newStatus)}.');
      }
      _fetchUserReports(); // Refresh the list after update
    } catch (e) {
      debugPrint('Error updating item status: $e');
      if (mounted) {
        MessageModal.show(context, MessageType.error, 'Error', 'Failed to update item status: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteReport(String itemId, String itemType) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kBackground,
          shape: RoundedRectangleBorder(borderRadius: kDefaultBorderRadius),
          title: Text('Confirm Delete', style: GoogleFonts.poppins(color: kPrimaryBlack, fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to delete this ${itemType == 'Lost' ? 'lost' : 'found'} item report?', style: GoogleFonts.poppins(color: kGrey)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: GoogleFonts.poppins(color: kPrimaryBlack)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: kRedError,
                shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius),
              ),
              child: Text('Delete', style: GoogleFonts.poppins(color: kPrimaryWhite)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() => _isLoading = true);
      try {
        if (itemType == 'Lost') {
          await supabaseService.client.from('lost_items').delete().eq('id', itemId);
        } else {
          await supabaseService.client.from('found_items').delete().eq('id', itemId);
        }
        if (mounted) {
          MessageModal.show(context, MessageType.success, 'Deleted', '$itemType report deleted.');
        }
        _fetchUserReports();
      } catch (e) {
        if (mounted) {
          MessageModal.show(context, MessageType.error, 'Error', 'Failed to delete: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        title: Text('My Reports', style: GoogleFonts.poppins(color: kPrimaryBlack, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kPrimaryBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryYellow))
          : RefreshIndicator(
              onRefresh: _fetchUserReports,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: kDefaultPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: kMediumSpacing),
                    _buildFilterDropdowns(),
                    const SizedBox(height: kLargeSpacing),
                    _buildSection('My Lost Items', _userLostItems, 'Lost'),
                    const SizedBox(height: kLargeSpacing),
                    _buildSection('My Found Items', _userFoundItems, 'Found'),
                    const SizedBox(height: kLargeSpacing),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: kSmallBorderRadius,
        boxShadow: [
          kNeumorphicShadowDark,
          kNeumorphicShadowLight,
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.poppins(color: kPrimaryBlack),
        decoration: InputDecoration(
          hintText: 'Search your reports...',
          hintStyle: GoogleFonts.poppins(color: kGrey),
          prefixIcon: Icon(Icons.search, color: kGrey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: kGrey),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged(); // Trigger search with empty query
                  },
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide(color: kPrimaryYellow, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: kMediumSpacing, vertical: kMediumSpacing),
        ),
        onChanged: (value) {
          _onSearchChanged(); // Debounced search on text change
        },
        onSubmitted: (value) {
          if (_debounce?.isActive ?? false) _debounce!.cancel(); // Cancel any pending debounce
          setState(() {
            _searchQuery = value;
            _lastSearchedText = value;
          });
          _fetchUserReports(); // Perform search on submit
        },
      ),
    );
  }

  Widget _buildFilterDropdowns() {
    return Column(
      children: [
        _buildDropdownField(
          labelText: 'Category',
          value: _selectedCategory,
          items: _categories,
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
            _fetchUserReports();
          },
        ),
        const SizedBox(height: kMediumSpacing),
        _buildDropdownField(
          labelText: 'Lost Item Status',
          value: _selectedLostStatus,
          items: _lostStatuses,
          onChanged: (String? newValue) {
            setState(() {
              _selectedLostStatus = newValue;
            });
            _fetchUserReports();
          },
        ),
        const SizedBox(height: kMediumSpacing),
        _buildDropdownField(
          labelText: 'Found Item Status',
          value: _selectedFoundStatus,
          items: _foundStatuses,
          onChanged: (String? newValue) {
            setState(() {
              _selectedFoundStatus = newValue;
            });
            _fetchUserReports();
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String labelText,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: kSmallBorderRadius,
        boxShadow: [
          kNeumorphicShadowDark,
          kNeumorphicShadowLight,
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.poppins(color: kGrey),
          filled: true,
          fillColor: kBackground,
          enabledBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide(color: kPrimaryYellow, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: kMediumSpacing, vertical: kMediumSpacing),
        ),
        dropdownColor: kBackground,
        style: GoogleFonts.poppins(color: kPrimaryBlack),
        icon: const Icon(Icons.arrow_drop_down, color: kGrey),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: GoogleFonts.poppins(color: kPrimaryBlack)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> items, String itemType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryBlack)),
        const SizedBox(height: kMediumSpacing),
        items.isEmpty
            ? _buildNoItemsMessage(itemType.toLowerCase())
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildReportCard(
                    itemData: item,
                    itemType: itemType,
                  );
                },
              ),
      ],
    );
  }

  Widget _buildNoItemsMessage(String itemType) {
    return Center(
      child: Padding(
        padding: kDefaultPadding,
        child: Column(
          children: [
            Icon(itemType == 'found' ? Icons.search : Icons.help_outline, size: 60, color: kGrey),
            const SizedBox(height: kSmallSpacing),
            Text('You have not reported any $itemType items yet.',
                textAlign: TextAlign.center, style: GoogleFonts.poppins(color: kGrey, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required Map<String, dynamic> itemData,
    required String itemType,
  }) {
    final String id = itemData['id'];
    final String itemName = itemData['item_name'];
    // final String description = itemData['description']; // Not used in card display, but available
    final String? imageUrl = itemData['image_url'];
    final String status = itemData['status'] ?? (itemType == 'Lost' ? 'not_found' : 'unclaimed');
    final String date = itemType == 'Lost' ? itemData['date_lost'] : itemData['date_found'];
    final String location = itemType == 'Lost' ? itemData['lost_location'] : itemData['found_location'];
    final String reporterId = itemData['reporter_id'];

    final bool isCurrentUserReporter = _currentUserId != null && _currentUserId == reporterId;

    // Determine visibility of "Mark as Found" button
    final bool showMarkAsFound = isCurrentUserReporter &&
        itemType == 'Lost' && // Ensure it's a lost item
        status.toLowerCase() != 'found' && // Disappears if status is 'found'
        status.toLowerCase() != 'claimed'; // Disappears if status is 'claimed'

    // Determine visibility of "Mark as Claimed" button
    final bool showMarkAsClaimed = isCurrentUserReporter &&
        itemType == 'Found' && // Ensure it's a found item
        status.toLowerCase() != 'claimed'; // Disappears if status is 'claimed'

    // Determine visibility of "Delete" button
    // It should only disappear when the item is explicitly 'found' or 'claimed'
    final bool canDelete = isCurrentUserReporter &&
        status.toLowerCase() != 'found' &&
        status.toLowerCase() != 'claimed';


    return Card(
      margin: const EdgeInsets.symmetric(vertical: kSmallSpacing),
      shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius),
      elevation: 3,
      child: Padding(
        padding: kMediumPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: kLightGrey,
                    borderRadius: kSmallBorderRadius,
                    image: imageUrl != null && imageUrl.isNotEmpty
                        ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: imageUrl == null || imageUrl.isEmpty
                      ? const Center(child: Icon(Icons.image_not_supported, size: 40, color: kGrey))
                      : null,
                ),
                const SizedBox(width: kMediumSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$itemName (${capitalizeFirstLetter(itemType)})',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: kPrimaryBlack)),
                      Text('Status: ${capitalizeFirstLetter(status.replaceAll('_', ' '))}', style: GoogleFonts.poppins(fontSize: 14, color: kGrey)),
                      Text('Date: $date', style: GoogleFonts.poppins(fontSize: 14, color: kGrey)),
                      Text('Location: $location', style: GoogleFonts.poppins(fontSize: 14, color: kGrey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: kSmallSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // View Details Button
                TextButton(
                  onPressed: () {
                    if (itemType == 'Lost') {
                      Navigator.pushNamed(context, '/lost_item_view', arguments: id);
                    } else {
                      Navigator.pushNamed(context, '/found_item_view', arguments: id);
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: kPrimaryYellow),
                  child: Text('View Details', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                ),
                // Mark as Found Button (for lost items reported by current user)
                if (showMarkAsFound)
                  TextButton(
                    onPressed: () => _updateItemStatus(id, itemType, 'found'),
                    style: TextButton.styleFrom(foregroundColor: kPrimaryGreen),
                    child: Text('Mark as Found', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  ),
                // Mark as Claimed Button (for found items reported by current user)
                if (showMarkAsClaimed)
                  TextButton(
                    onPressed: () => _updateItemStatus(id, itemType, 'claimed'),
                    style: TextButton.styleFrom(foregroundColor: kPrimaryGreen),
                    child: Text('Mark as Claimed', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  ),
                // Delete Button
                if (canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete, color: kRedError),
                    onPressed: () => _deleteReport(id, itemType),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}