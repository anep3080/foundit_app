import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ui_constants.dart';
import '../services/supabase_service.dart';
import 'dart:async'; // Import for Timer

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  List<Map<String, dynamic>> _foundItems = [];
  List<Map<String, dynamic>> _lostItems = [];
  bool _isLoading = true;
  String? _currentUserUserType;
  final TextEditingController _searchController = TextEditingController();
  String _lastSearchedText = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserType();
    _fetchItems(); // Initial fetch
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentUserType() async {
    final User? currentUser = supabaseService.currentUser;
    if (currentUser != null) {
      try {
        final profile = await supabaseService.client
            .from('profiles')
            .select('user_type')
            .eq('id', currentUser.id)
            .single();
        setState(() {
          _currentUserUserType = profile['user_type'];
        });
      } catch (e) {
        debugPrint('Error fetching user type: $e');
        // Handle error, e.g., navigate to login or show a message
      }
    }
  }

  Future<void> _fetchItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Fetch latest 4 lost items
      final lostItemsResponse = await supabaseService.client
          .from('lost_items')
          .select('*')
          .order('created_at', ascending: false) // Order by creation date for "recently"
          .limit(4); // Fetch latest 4 lost items

      // Fetch latest 4 found items
      final foundItemsResponse = await supabaseService.client
          .from('found_items')
          .select('*')
          .order('created_at', ascending: false) // Order by creation date for "recently"
          .limit(4); // Fetch latest 4 found items

      setState(() {
        _foundItems = List<Map<String, dynamic>>.from(foundItemsResponse);
        _lostItems = List<Map<String, dynamic>>.from(lostItemsResponse);
      });
    } catch (e) {
      debugPrint('Error fetching items: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchItems(String query) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Search found items
      final foundItemsResponse = await supabaseService.client
          .from('found_items')
          .select('*')
          .ilike('item_name', '%$query%')
          .order('date_found', ascending: false)
          .limit(4); // Limit search results too

      // Search lost items
      final lostItemsResponse = await supabaseService.client
          .from('lost_items')
          .select('*')
          .ilike('item_name', '%$query%')
          .order('date_lost', ascending: false)
          .limit(4); // Limit search results too

      setState(() {
        _foundItems = List<Map<String, dynamic>>.from(foundItemsResponse);
        _lostItems = List<Map<String, dynamic>>.from(lostItemsResponse);
      });
    } catch (e) {
      debugPrint('Error searching items: $e');
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
          'FoundIt',
          style: GoogleFonts.poppins(
            color: kPrimaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: kPrimaryBlack), // Profile icon
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          if (_currentUserUserType == 'admin')
            IconButton(
              icon: Icon(Icons.admin_panel_settings, color: kPrimaryBlack), // Admin icon
              onPressed: () {
                Navigator.pushNamed(context, '/admin_homepage');
              },
            ),
          IconButton(
            icon: Icon(Icons.dashboard, color: kPrimaryBlack), // User Dashboard icon
            onPressed: () {
              Navigator.pushNamed(context, '/user_dashboard');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryYellow)) // Use yellow for loading
          : RefreshIndicator(
              onRefresh: _fetchItems,
              color: kPrimaryYellow, // Use yellow for refresh indicator
              child: SingleChildScrollView(
                padding: kDefaultPadding,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: kLargeSpacing),
                    // Display Lost Items section first
                    _buildSectionTitle('Recently Lost Items', () {
                      Navigator.pushNamed(context, '/all_lost_items');
                    }),
                    const SizedBox(height: kMediumSpacing),
                    _buildItemList(_lostItems, 'lost'),
                    const SizedBox(height: kLargeSpacing),
                    // Display Found Items section second
                    _buildSectionTitle('Recently Found Items', () {
                      Navigator.pushNamed(context, '/all_found_items');
                    }),
                    const SizedBox(height: kMediumSpacing),
                    _buildItemList(_foundItems, 'found'),
                    const SizedBox(height: kExtraLargeSpacing * 2), // Extra space for FAB
                  ],
                ),
              ),
            ),
      // Position FAB to bottom right
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFabContainer(),
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
                    _searchItems(''); // Clear search and re-fetch all items
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
          if (value.isEmpty) {
            _searchItems(''); // If search is cleared, fetch all items
          }
        },
        onSubmitted: (value) {
          _searchItems(value); // Perform search on submit
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kPrimaryBlack,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'View All',
            style: GoogleFonts.poppins(
              color: kPrimaryYellow, // Use yellow for links
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemList(List<Map<String, dynamic>> items, String itemType) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(kLargeSpacing),
          child: Text(
            'No ${itemType == 'found' ? 'found' : 'lost'} items yet.',
            style: GoogleFonts.poppins(color: kGrey),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // Ensure itemCount does not exceed 4 if more items are fetched but only 4 are desired for display
      itemCount: items.length > 4 ? 4 : items.length, // Limit to max 4 items
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(
          item['id'],
          item['image_url'],
          item['item_name'],
          item['description'],
          itemType,
        );
      },
    );
  }

  Widget _buildItemCard(String id, String? imageUrl, String title, String description, String itemType) {
    return GestureDetector(
      onTap: () {
        if (itemType == 'found') {
          Navigator.pushNamed(context, '/found_item_view', arguments: id);
        } else {
          Navigator.pushNamed(context, '/lost_item_view', arguments: id);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: kSmallSpacing),
        decoration: BoxDecoration(
          color: kBackground, // Match background for Neumorphism
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
                  color: kLightGrey, // Placeholder background
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
                        itemType == 'found' ? Icons.search : Icons.help_outline,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Adjusted _buildFabContainer for bottom-right positioning
  Widget _buildFabContainer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end, // Align children to the end (right)
      children: [
        _buildFab(
          FontAwesomeIcons.question,
          'Report Lost Item',
          () {
            Navigator.pushNamed(context, '/report_lost');
          },
          color: kPrimaryYellow, // Yellow for lost
        ),
        const SizedBox(height: kMediumSpacing),
        _buildFab(
          FontAwesomeIcons.plus,
          'Report Found Item',
          () {
            Navigator.pushNamed(context, '/report_found');
          },
          color: kPrimaryGreen, // Green for found
        ),
      ],
    );
  }

  Widget _buildFab(IconData icon, String tooltip, VoidCallback onPressed, {required Color color}) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            // Apply inner shadow on press down for debossed effect
          });
        },
        onTapUp: (_) {
          setState(() {
            // Revert to outer shadow on press up
          });
        } ,
        onTapCancel: () {
          setState(() {
            // Revert to outer shadow if tap is cancelled
          });
        },
        onTap: onPressed,
        child: Container(
          width: 60, // Standard FAB size
          height: 60,
          decoration: BoxDecoration(
            color: color, // Use the passed color
            shape: BoxShape.circle,
            boxShadow: [
              kNeumorphicShadowDark,
              kNeumorphicShadowLight,
            ],
          ),
          child: Icon(icon, color: kPrimaryWhite, size: 28), // White icon
        ),
      ),
    );
  }
}
