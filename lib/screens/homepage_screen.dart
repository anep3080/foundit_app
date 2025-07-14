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
        setState(() {
          _currentUserUserType = 'user';
        });
      }
    } else {
      setState(() {
        _currentUserUserType = 'guest';
      });
    }
  }

  Future<void> _fetchItems({String? searchQuery}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      var foundQuery = supabaseService.client.from('found_items').select();
      var lostQuery = supabaseService.client.from('lost_items').select();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final pattern = '%$searchQuery%';
        foundQuery = foundQuery.or(
            'item_name.ilike.$pattern,description.ilike.$pattern,category.ilike.$pattern,found_location.ilike.$pattern');
        lostQuery = lostQuery.or(
            'item_name.ilike.$pattern,description.ilike.$pattern,category.ilike.$pattern,lost_location.ilike.$pattern');
      }

      final foundItems = await foundQuery.order('created_at', ascending: false).limit(5);
      final lostItems = await lostQuery.order('created_at', ascending: false).limit(5);

      setState(() {
        _foundItems = foundItems;
        _lostItems = lostItems;
      });
    } catch (e) {
      debugPrint('Fetch error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleSearch() {
    final input = _searchController.text.trim();
    if (input != _lastSearchedText) {
      _lastSearchedText = input;
      _fetchItems(searchQuery: input);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _lastSearchedText = '';
    _fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryYellowGreen,
      appBar: AppBar(
        backgroundColor: kDarkRed,
        title: Text('FoundIt', style: GoogleFonts.poppins(color: kWhite, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // New: User Dashboard Button
          IconButton(
            icon: const Icon(Icons.dashboard, color: kWhite), // Or a different icon like Icons.folder_shared
            onPressed: () => Navigator.pushNamed(context, '/user_dashboard'),
            tooltip: 'My Reports',
          ),
          IconButton(
            icon: const Icon(Icons.person, color: kWhite),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          if (_currentUserUserType == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: kWhite),
              onPressed: () => Navigator.pushNamed(context, '/admin_homepage'),
            ),
          const SizedBox(width: kSmallSpacing),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kDarkRed))
          : RefreshIndicator(
              onRefresh: () => _fetchItems(searchQuery: _searchController.text),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: kDefaultPadding,
                child: Column(
                  children: [
                    const SizedBox(height: kLargeSpacing),
                    _buildSearchBar(),
                    const SizedBox(height: kLargeSpacing),
                    _buildSection(
                      title: 'Recent Found Items',
                      onViewAll: () => Navigator.pushNamed(context, '/all_found_items'),
                      items: _foundItems,
                      itemType: 'found',
                    ),
                    const SizedBox(height: kLargeSpacing),
                    _buildSection(
                      title: 'Recent Lost Items',
                      onViewAll: () => Navigator.pushNamed(context, '/all_lost_items'),
                      items: _lostItems,
                      itemType: 'lost',
                    ),
                    const SizedBox(height: kLargeSpacing),
                  ],
                ),
              ),
            ),
      floatingActionButton: _buildFabContainer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: kSmallBorderRadius,
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: kGrey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search items...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: GoogleFonts.poppins(color: kBlack),
                    onSubmitted: (_) => _handleSearch(),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: _clearSearch,
                    child: const Icon(Icons.clear, color: kGrey),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _handleSearch,
          style: ElevatedButton.styleFrom(
            backgroundColor: kDarkRed,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text('Search', style: GoogleFonts.poppins(color: kWhite, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required VoidCallback onViewAll,
    required List<Map<String, dynamic>> items,
    required String itemType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: kDarkRed)),
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(foregroundColor: kGrey),
              child: Text('View All', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: kMediumSpacing),
        items.isEmpty
            ? Center(
                child: Padding(
                  padding: kDefaultPadding,
                  child: Column(
                    children: [
                      Icon(itemType == 'found' ? Icons.search : Icons.help_outline, size: 60, color: kGrey),
                      const SizedBox(height: kSmallSpacing),
                      Text('No $itemType items reported yet.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: kGrey, fontSize: 16)),
                    ],
                  ),
                ),
              )
            : SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildItemCard(
                      context,
                      item['id'] as String, // Explicitly cast to String
                      item['item_name'],
                      item['description'],
                      item['image_url'],
                      itemType,
                    );
                  },
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
    String itemType,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
            context, itemType == 'lost' ? '/lost_item_view' : '/found_item_view',
            arguments: itemId);
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: kMediumSpacing),
        decoration: BoxDecoration(
          color: kLightYellow,
          borderRadius: kDefaultBorderRadius,
          boxShadow: const [kDefaultBoxShadow],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover)
                    : Image.network('https://placehold.co/700x700/CCCCCC/FFFFFF?text=No+Image', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: kSmallSpacing),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSmallSpacing),
              child: Text(
                itemName,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF333333),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSmallSpacing),
              child: Text(
                description,
                style: GoogleFonts.poppins(color: kGrey, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: kSmallSpacing),
          ],
        ),
      ),
    );
  }

  Widget _buildFabContainer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFab(FontAwesomeIcons.question, 'Report Lost Item', () {
          Navigator.pushNamed(context, '/report_lost');
        }),
        const SizedBox(height: kMediumSpacing),
        _buildFab(FontAwesomeIcons.plus, 'Report Found Item', () {
          Navigator.pushNamed(context, '/report_found');
        }),
      ],
    );
  }

  Widget _buildFab(IconData icon, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: kDarkRed,
        foregroundColor: kWhite,
        heroTag: tooltip,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: kCircularBorderRadius),
        child: Icon(icon),
      ),
    );
  }
}
