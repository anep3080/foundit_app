import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ui_constants.dart';
import '../services/supabase_service.dart';

class AllFoundItemsScreen extends StatefulWidget {
  const AllFoundItemsScreen({super.key});

  @override
  State<AllFoundItemsScreen> createState() => _AllFoundItemsScreenState();
}

class _AllFoundItemsScreenState extends State<AllFoundItemsScreen> {
  List<Map<String, dynamic>> _foundItems = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String? _selectedCategory; // New state for category filter
  String? _selectedStatus; // New state for status filter (specific to found items)

  // Define available categories and statuses for found items
  final List<String> _categories = [
    'All', 'Electronics', 'Documents', 'Clothing', 'Keys', 'Bags', 'Jewelry',
    'Wallets', 'Books', 'Other'
  ];
  final List<String> _statuses = [
    'All', 'Unclaimed', 'Claimed', 'Pending Approval', 'Rejected'
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first; // Initialize with 'All'
    _selectedStatus = _statuses.first; // Initialize with 'All'
    _fetchAllFoundItems();
    _searchController.addListener(_onSearchChanged);
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
    _fetchAllFoundItems(); // Re-fetch items with new search query
  }

  void _onFilterChanged() {
    _fetchAllFoundItems(); // Re-fetch with new filter selections
  }

  Future<void> _fetchAllFoundItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var query = supabaseService.client.from('found_items').select();

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        query = query.ilike('item_name', '%$_searchQuery%');
      }

      // Apply category filter
      if (_selectedCategory != null && _selectedCategory != 'All') {
        query = query.eq('category', _selectedCategory!);
      }

      // Apply status filter
      if (_selectedStatus != null && _selectedStatus != 'All') {
        final String normalizedStatus = _selectedStatus!.toLowerCase().replaceAll(' ', '_');
        query = query.eq('status', normalizedStatus);
      }

      final List<Map<String, dynamic>> response = await query
          .order('created_at', ascending: false); // Order by most recent

      setState(() {
        _foundItems = response;
      });
    } catch (e) {
      debugPrint('Error fetching all found items: $e');
      // Optionally show a message modal here
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryYellowGreen,
      appBar: AppBar(
        backgroundColor: kDarkRed,
        title: Text(
          'All Found Items',
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
      ),
      body: Column( // Use Column to place search bar above the list
        children: [
          Padding(
            padding: kDefaultPadding.copyWith(bottom: 0), // Adjust padding
            child: _buildSearchBar(),
          ),
          const SizedBox(height: kMediumSpacing),
          Padding(
            padding: kHorizontalPadding, // Apply horizontal padding for filter bar
            child: _buildFilterBar(), // New filter bar
          ),
          const SizedBox(height: kMediumSpacing),
          Expanded( // Expanded to fill remaining space
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kDarkRed))
                : RefreshIndicator(
                    onRefresh: _fetchAllFoundItems,
                    child: _foundItems.isEmpty
                        ? Center(
                            child: SingleChildScrollView( // Allow scrolling for empty state
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: kDefaultPadding,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 60,
                                    color: kGrey,
                                  ),
                                  const SizedBox(height: kSmallSpacing),
                                  Text(
                                    _searchQuery.isNotEmpty || _selectedCategory != 'All' || _selectedStatus != 'All'
                                        ? 'No matching found items found.'
                                        : 'No found items found.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(color: kGrey, fontSize: kBodySmall.fontSize),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder( // Switched to ListView.builder to allow for consistent card layout with status badge
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _foundItems.length,
                            itemBuilder: (context, index) {
                              final item = _foundItems[index];
                              return _buildItemCard(
                                context,
                                item['id'] as String, // Explicitly cast to String
                                item['item_name'],
                                item['description'],
                                item['image_url'],
                                item['status'], // Pass status for badge
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: kSmallBorderRadius,
        boxShadow: const [kDefaultBoxShadow],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.poppins(color: kBlack, fontSize: kBodyMedium.fontSize),
        decoration: InputDecoration(
          hintText: 'Search for found items...',
          hintStyle: GoogleFonts.poppins(color: kGrey, fontSize: kBodyMedium.fontSize),
          prefixIcon: Icon(Icons.search, color: kGrey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: kGrey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                    _fetchAllFoundItems();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: kSmallPadding,
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: kSmallSpacing),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: kSmallBorderRadius,
              boxShadow: const [kDefaultBoxShadow],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                icon: const Icon(Icons.arrow_drop_down, color: kGrey),
                style: GoogleFonts.poppins(color: kBlack, fontSize: kBodyMedium.fontSize),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                  _onFilterChanged();
                },
                items: _categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(width: kMediumSpacing),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: kSmallSpacing),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: kSmallBorderRadius,
              boxShadow: const [kDefaultBoxShadow],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatus,
                icon: const Icon(Icons.arrow_drop_down, color: kGrey),
                style: GoogleFonts.poppins(color: kBlack, fontSize: kBodyMedium.fontSize),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                  _onFilterChanged();
                },
                items: _statuses.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    String itemId,
    String itemName,
    String description,
    String? imageUrl,
    String status, // Now receiving status
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/found_item_view', arguments: itemId);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: kDefaultBorderRadius),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: kLightGrey,
                  borderRadius: kSmallBorderRadius,
                  image: imageUrl != null && imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageUrl == null || imageUrl.isEmpty
                    ? Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: kGrey,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: kDarkRed,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: kGrey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: _buildStatusBadge(status), // Use status for badge
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    String statusText;

    switch (status.toLowerCase().trim()) { // Ensure consistent comparison
      case 'unclaimed':
        statusColor = kRedError;
        statusText = 'Unclaimed';
        break;
      case 'claimed':
        statusColor = kGreenSuccess;
        statusText = 'Claimed';
        break;
      case 'pending_approval':
        statusColor = kGrey;
        statusText = 'Pending Approval';
        break;
      case 'rejected':
        statusColor = kBlack;
        statusText = 'Rejected';
        break;
      default:
        statusColor = kGrey;
        statusText = 'Unknown Status';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: kCircularBorderRadius,
      ),
      child: Text(
        statusText, // No need to capitalize again, already handled
        style: GoogleFonts.poppins(
          color: kWhite,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String toCapitalized() => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}
