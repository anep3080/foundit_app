import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ui_constants.dart';
import '../services/supabase_service.dart';

class AllLostItemsScreen extends StatefulWidget {
  const AllLostItemsScreen({super.key});

  @override
  State<AllLostItemsScreen> createState() => _AllLostItemsScreenState();
}

class _AllLostItemsScreenState extends State<AllLostItemsScreen> {
  List<Map<String, dynamic>> _lostItems = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String? _selectedCategory; // New state for category filter
  String? _selectedStatus; // New state for status filter (specific to lost items)

  // Define available categories and statuses for lost items
  final List<String> _categories = [
    'All', 'Electronics', 'Documents', 'Clothing', 'Keys', 'Bags', 'Jewelry',
    'Wallets', 'Books', 'Other'
  ];
  final List<String> _statuses = [
    'All', 'Not Found', 'Found'
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first; // Initialize with 'All'
    _selectedStatus = _statuses.first; // Initialize with 'All'
    _fetchAllLostItems();
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
    _fetchAllLostItems(); // Re-fetch items with new search query
  }

  Future<void> _fetchAllLostItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Start with the base query
      var query = supabaseService.client
          .from('lost_items')
          .select('*');

      // Apply filters conditionally
      if (_searchQuery.isNotEmpty) {
        query = query.ilike('item_name', '%$_searchQuery%');
      }

      if (_selectedCategory != 'All' && _selectedCategory != null) {
        query = query.eq('category', _selectedCategory!.toLowerCase());
      }

      if (_selectedStatus != 'All' && _selectedStatus != null) {
        // Supabase status values are typically lowercase with underscores
        query = query.eq('status', _selectedStatus!.toLowerCase().replaceAll(' ', '_'));
      }

      // Finally, apply ordering
      final response = await query.order('date_lost', ascending: false);

      setState(() {
        _lostItems = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error fetching all lost items: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          'All Lost Items',
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
          : RefreshIndicator(
              onRefresh: _fetchAllLostItems,
              color: kPrimaryYellow,
              child: SingleChildScrollView(
                padding: kDefaultPadding,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: kMediumSpacing),
                    _buildFilterDropdowns(),
                    const SizedBox(height: kLargeSpacing),
                    _lostItems.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(kLargeSpacing),
                              child: Text(
                                'No lost items matching your criteria.',
                                style: GoogleFonts.poppins(color: kGrey),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _lostItems.length,
                            itemBuilder: (context, index) {
                              final item = _lostItems[index];
                              return _buildItemCard(
                                item['id'],
                                item['image_url'],
                                item['item_name'],
                                item['description'],
                                item['status'], // Pass status for badge
                              );
                            },
                          ),
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
          hintText: 'Search items...',
          hintStyle: GoogleFonts.poppins(color: kGrey),
          prefixIcon: Icon(Icons.search, color: kGrey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: kGrey),
                  onPressed: () {
                    _searchController.clear();
                    _fetchAllLostItems(); // Clear search and re-fetch all items
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
      ),
    );
  }

  Widget _buildFilterDropdowns() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            value: _selectedCategory,
            items: _categories,
            labelText: 'Category',
            icon: Icons.category,
            onChanged: (newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
              _fetchAllLostItems();
            },
          ),
        ),
        const SizedBox(width: kMediumSpacing),
        Expanded(
          child: _buildDropdown(
            value: _selectedStatus,
            items: _statuses,
            labelText: 'Status',
            icon: Icons.info_outline,
            onChanged: (newValue) {
              setState(() {
                _selectedStatus = newValue;
              });
              _fetchAllLostItems();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String labelText,
    required IconData icon,
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
          prefixIcon: Icon(icon, color: kGrey),
          fillColor: kBackground,
          filled: true,
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
        icon: Icon(Icons.arrow_drop_down, color: kGrey),
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

  Widget _buildItemCard(String id, String? imageUrl, String title, String description, String status) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/lost_item_view', arguments: id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: kSmallSpacing),
        decoration: BoxDecoration(
          color: kBackground,
          borderRadius: kDefaultBorderRadius,
          boxShadow: [
            kNeumorphicShadowDark,
            kNeumorphicShadowLight,
          ],
        ),
        child: Padding(
          padding: kMediumPadding,
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
                    ? Icon(
                        Icons.help_outline,
                        color: kGrey,
                        size: 40,
                      )
                    : null,
              ),
              const SizedBox(width: kMediumSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: kPrimaryBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: kExtraSmallSpacing),
                    Text(
                      description,
                      style: GoogleFonts.poppins(color: kGrey, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: kExtraSmallSpacing),
                    _buildStatusBadge(status), // Pass the status for badge
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

    switch (status.toLowerCase().trim()) {
      case 'not found':
        statusColor = kRedError;
        statusText = 'Not Found';
        break;
      case 'found':
        statusColor = kPrimaryYellow;
        statusText = 'Found';
        break;
      case 'claimed':
        statusColor = kPrimaryGreen;
        statusText = 'Claimed';
        break;
      case 'pending_approval':
        statusColor = kGrey;
        statusText = 'Pending Approval';
        break;
      case 'rejected':
        statusColor = kPrimaryBlack;
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
        statusText,
        style: GoogleFonts.poppins(
          color: kPrimaryWhite,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
