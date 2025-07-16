import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui_constants.dart';
import '../services/supabase_service.dart';
import '../widgets/message_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase types

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
  String? _currentUserId;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedLostStatus; // Specific for lost items
  String? _selectedFoundStatus; // Specific for found items

  final List<String> _categories = [
    'All', 'Electronics', 'Documents', 'Clothing', 'Keys', 'Bags', 'Jewelry',
    'Wallets', 'Books', 'Other', 'Accessories' // Added Accessories for consistency
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
    _currentUserId = supabaseService.currentUser?.id;
    debugPrint('UserDashboardScreen - Initial Current User ID: $_currentUserId'); // Debug print
    if (_currentUserId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        MessageModal.show(context, MessageType.error, 'Access Denied', 'You must be logged in to view this page.');
        Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
      });
    } else {
      _selectedCategory = _categories.first; // Initialize with 'All'
      _selectedLostStatus = _lostStatuses.first; // Initialize with 'All'
      _selectedFoundStatus = _foundStatuses.first; // Initialize with 'All'
      _fetchUserReports();
      _searchController.addListener(_onSearchChanged);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _fetchUserReports(); // Re-fetch items with new search query
  }

  Future<void> _fetchUserReports() async {
    setState(() => _isLoading = true);
    debugPrint('UserDashboardScreen - Fetching user reports for ID: $_currentUserId'); // Debug print
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
        lostQuery = lostQuery.eq('category', _selectedCategory!.toLowerCase());
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
        foundQuery = foundQuery.eq('category', _selectedCategory!.toLowerCase());
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
        debugPrint('UserDashboardScreen - Fetched Lost Items: ${_userLostItems.length}'); // Debug print
        debugPrint('UserDashboardScreen - Fetched Found Items: ${_userFoundItems.length}'); // Debug print
      });
    } catch (e) {
      debugPrint('UserDashboardScreen - Error fetching user reports: $e'); // Debug print
      MessageModal.show(context, MessageType.error, 'Error', 'Failed to load your reports: $e');
    } finally {
      setState(() => _isLoading = false);
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
      MessageModal.show(context, MessageType.success, 'Success', 'Item status updated to $newStatus.');
      _fetchUserReports(); // Refresh the list after update
    } catch (e) {
      debugPrint('Error updating item status: $e');
      MessageModal.show(context, MessageType.error, 'Error', 'Failed to update item status: $e');
    } finally {
      setState(() => _isLoading = false);
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
        MessageModal.show(context, MessageType.success, 'Deleted', '$itemType report deleted.');
        _fetchUserReports();
      } catch (e) {
        MessageModal.show(context, MessageType.error, 'Error', 'Failed to delete: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground, // Changed from kPrimaryYellowGreen
      appBar: AppBar(
        backgroundColor: kBackground, // Changed from kDarkRed
        title: Text('My Reports', style: GoogleFonts.poppins(color: kPrimaryBlack, fontWeight: FontWeight.bold)), // Changed from kWhite
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kPrimaryBlack), // Changed from kWhite
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryYellow)) // Changed from kDarkRed
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
        onSubmitted: (value) {
          _onSearchChanged(); // Trigger search on submit
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
        Text(title, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryBlack)), // Changed from kDarkRed
        const SizedBox(height: kMediumSpacing),
        items.isEmpty
            ? _buildNoItemsMessage(itemType.toLowerCase())
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  // Pass the full item map to _buildReportCard for detailed checks
                  return _buildReportCard(
                    itemData: item, // Pass the entire item data
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
    required Map<String, dynamic> itemData, // Now accepts the full item data
    required String itemType,
  }) {
    final String id = itemData['id'];
    final String itemName = itemData['item_name'];
    final String description = itemData['description'];
    final String? imageUrl = itemData['image_url'];
    final String status = itemData['status'] ?? (itemType == 'Lost' ? 'not found' : 'unclaimed');
    final String date = itemType == 'Lost' ? itemData['date_lost'] : itemData['date_found'];
    final String location = itemType == 'Lost' ? itemData['lost_location'] : itemData['found_location'];
    final String reporterId = itemData['reporter_id']; // Assuming 'reporter_id' exists in itemData

    final bool isCurrentUserReporter = _currentUserId == reporterId;

    // Determine if the delete button should be shown
    final bool canDelete = !(itemType == 'Lost' && (status == 'found' || status == 'claimed')) &&
        !(itemType == 'Found' && status == 'claimed');

    // Determine if "Mark as Found" or "Mark as Claimed" button should be shown
    final bool showMarkAsFound = isCurrentUserReporter && itemType == 'Lost' && status == 'not found';
    final bool showMarkAsClaimed = isCurrentUserReporter && itemType == 'Found' && status == 'unclaimed';


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
                      ? Center(child: Icon(Icons.image_not_supported, size: 40, color: kGrey))
                      : null,
                ),
                const SizedBox(width: kMediumSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$itemName (${capitalizeFirstLetter(itemType)})',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: kPrimaryBlack)), // Changed from kDarkRed
                      Text('Status: ${capitalizeFirstLetter(status)}', style: GoogleFonts.poppins(fontSize: 14, color: kGrey)),
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
                  style: TextButton.styleFrom(foregroundColor: kPrimaryYellow), // Changed from kDarkRed
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
