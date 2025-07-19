import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ui_constants.dart';
import '../services/supabase_service.dart'; // Make sure this path is correct and the file exists
import 'dart:async'; // Import for Timer

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return '';
  return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
}

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

  String? _selectedCategory;
  String? _selectedStatus;

  Timer? _debounce; // For debouncing search input
  String _lastSearchedText = ''; // To store the last text that triggered a search

  final List<String> _categories = [
    'All', 'Electronics', 'Documents', 'Clothing', 'Keys', 'Bags', 'Jewelry',
    'Wallets', 'Books', 'Other'
  ];
  final List<String> _statuses = ['All', 'Unclaimed', 'Claimed'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
    _selectedStatus = _statuses.first;
    _fetchAllFoundItems();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel(); // Cancel any active debounce timer
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_lastSearchedText != _searchController.text) {
        setState(() {
          _searchQuery = _searchController.text;
          _lastSearchedText = _searchController.text;
        });
        _fetchAllFoundItems(); // Re-fetch items with new search query
      }
    });
  }

  Future<void> _fetchAllFoundItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final supabaseClient = Supabase.instance.client;

      var query = supabaseClient
          .from('found_items')
          .select();

      if (_searchQuery.isNotEmpty) {
        query = query.ilike('item_name', '%$_searchQuery%');
      }

      if (_selectedCategory != 'All' && _selectedCategory != null) {
        query = query.eq('category', capitalizeFirstLetter(_selectedCategory!));
      }

      if (_selectedStatus != 'All' && _selectedStatus != null) {
        query = query.eq('status', _selectedStatus!.toLowerCase().replaceAll(' ', '_'));
      }

      final List data = await query.order('date_found', ascending: false);

      debugPrint('Fetched ${data.length} items for category: $_selectedCategory status: $_selectedStatus');

      setState(() {
        _foundItems = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint('Error fetching found items: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        title: Text('All Found Items',
            style: GoogleFonts.poppins(
              color: kPrimaryBlack,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: kPrimaryBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryYellow))
          : RefreshIndicator(
              onRefresh: _fetchAllFoundItems,
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
                    _foundItems.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(kLargeSpacing),
                              child: Text(
                                'No found items matching your criteria.',
                                style: GoogleFonts.poppins(color: kGrey),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _foundItems.length,
                            itemBuilder: (context, index) {
                              final item = _foundItems[index];
                              return _buildItemCard(
                                item['id'],
                                item['image_url'],
                                item['item_name'],
                                item['description'],
                                item['status'],
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
        boxShadow: [kNeumorphicShadowDark, kNeumorphicShadowLight],
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
                    _onSearchChanged(); // Clear search and re-fetch all items
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
          _fetchAllFoundItems(); // Perform search on submit
        },
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
              _fetchAllFoundItems();
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
              _fetchAllFoundItems();
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
        boxShadow: [kNeumorphicShadowDark, kNeumorphicShadowLight],
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
        Navigator.pushNamed(context, '/found_item_view', arguments: id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: kSmallSpacing),
        decoration: BoxDecoration(
          color: kBackground,
          borderRadius: kDefaultBorderRadius,
          boxShadow: [kNeumorphicShadowDark, kNeumorphicShadowLight],
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
                    ? Icon(Icons.search, color: kGrey, size: 40)
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
                    _buildStatusBadge(status),
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
      case 'unclaimed':
        statusColor = kRedError;
        statusText = 'Unclaimed';
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
