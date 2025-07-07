import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui_constants.dart'; // Import your constants file

class HomepageScreen extends StatelessWidget {
  const HomepageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryYellowGreen,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildNavbar(context),
              const SizedBox(height: 30),
              _buildSection(
                title: 'Recent found items',
                onViewAll: () => print('View all found items'),
                items: _buildFoundItems(), // Placeholder
              ),
              const SizedBox(height: 30),
              _buildSection(
                title: 'Recent lost items',
                onViewAll: () => print('View all lost items'),
                items: _buildLostItems(), // Placeholder
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFabContainer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildNavbar(BuildContext context) {
    return Row(
      children: [
        Text(
          'FoundIt',
          style: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for items...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                prefixIcon: const Icon(FontAwesomeIcons.search, size: 18, color: kBlack),
                filled: true,
                fillColor: kWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: kBlack, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: kBlack, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: kDarkRed, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              onSubmitted: (query) => print('Search query: $query'),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Row(
          children: [
            _buildNavIcon(FontAwesomeIcons.tachometerAlt, 'Dashboard', () => print('Dashboard')),
            _buildNavIcon(FontAwesomeIcons.user, 'Profile', () => print('Profile')),
            _buildNavIcon(FontAwesomeIcons.signOutAlt, 'Logout', () => print('Logout')),
          ],
        ),
      ],
    );
  }

  Widget _buildNavIcon(IconData icon, String tooltip, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7.5),
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

  Widget _buildSection({
    required String title,
    required VoidCallback onViewAll,
    required List<Widget> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: kLightYellow,
        borderRadius: kDefaultBorderRadius,
        boxShadow: const [kDefaultBoxShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    'View all >',
                    style: GoogleFonts.poppins(
                      color: kDarkRed,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          items.isEmpty
              ? Text(
                  'No items yet.',
                  style: GoogleFonts.poppins(color: Colors.grey[700]),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180, // minmax(180px, 1fr)
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.8, // Adjust as needed for content
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) => items[index],
                ),
        ],
      ),
    );
  }

  List<Widget> _buildFoundItems() {
    // Placeholder for actual data
    return List.generate(5, (index) {
      return _buildItemCard(
        itemName: 'Found Item ${index + 1}',
        description: 'A short description of the found item, possibly truncated.',
        imageUrl: 'https://via.placeholder.com/150/FFC107/000000?text=Found', // Placeholder image
        onTap: () => print('View Found Item ${index + 1}'),
      );
    });
  }

  List<Widget> _buildLostItems() {
    // Placeholder for actual data
    return List.generate(5, (index) {
      return _buildItemCard(
        itemName: 'Lost Item ${index + 1}',
        description: 'A short description of the lost item, possibly truncated.',
        imageUrl: 'https://via.placeholder.com/150/DC3545/FFFFFF?text=Lost', // Placeholder image
        onTap: () => print('View Lost Item ${index + 1}'),
      );
    });
  }

  Widget _buildItemCard({
    required String itemName,
    required String description,
    String? imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text(
                            'No Image',
                            style: GoogleFonts.poppins(color: Colors.grey[700]),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        'No Image',
                        style: GoogleFonts.poppins(color: Colors.grey[700]),
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              itemName,
              style: GoogleFonts.poppins(
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              description,
              style: GoogleFonts.poppins(
                color: const Color(0xFF555555),
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFabContainer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFab(FontAwesomeIcons.question, 'Report Lost Item', () => print('Report Lost')),
        const SizedBox(height: 15),
        _buildFab(FontAwesomeIcons.plus, 'Report Found Item', () => print('Report Found')),
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
        shape: const CircleBorder(),
        elevation: 4,
        child: Icon(icon, size: 24),
      ),
    );
  }
}