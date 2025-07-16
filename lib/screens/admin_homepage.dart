import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase types
import '../ui_constants.dart'; // Import your constants file
import '../services/supabase_service.dart'; // Import SupabaseService
import '../widgets/message_modal.dart'; // Import MessageModal

// Helper function to capitalize the first letter of a string
String capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return '';
  }
  return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
}

class AdminHomepageScreen extends StatefulWidget {
  const AdminHomepageScreen({super.key});

  @override
  State<AdminHomepageScreen> createState() => _AdminHomepageScreenState();
}

class _AdminHomepageScreenState extends State<AdminHomepageScreen> {
  String _adminFullName = 'Admin User'; // Placeholder, will fetch from profile
  int _selectedTabIndex = 0; // 0 for Items, 1 for Users

  List<Map<String, dynamic>> _reportedItems = []; // Combined lost and found items
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final User? currentUser = supabaseService.currentUser;
      if (currentUser != null) {
        final profile = await supabaseService.client
            .from('profiles')
            .select('full_name')
            .eq('id', currentUser.id)
            .single();
        setState(() {
          _adminFullName = profile['full_name'] ?? 'Admin User';
        });
      }

      // Fetch all lost items
      final lostItems = await supabaseService.client
          .from('lost_items')
          .select('*')
          .order('created_at', ascending: false);

      // Fetch all found items
      final foundItems = await supabaseService.client
          .from('found_items')
          .select('*')
          .order('created_at', ascending: false);

      // Combine and sort items (you might want more sophisticated sorting)
      List<Map<String, dynamic>> combinedItems = [];
      combinedItems.addAll(lostItems.map((item) => {...item, 'type': 'lost'}));
      combinedItems.addAll(foundItems.map((item) => {...item, 'type': 'found'}));

      // Sort by creation date if available, otherwise by item name
      combinedItems.sort((a, b) {
        final dateA = a['created_at'] ?? '';
        final dateB = b['created_at'] ?? '';
        return dateB.compareTo(dateA); // Newest first
      });

      // Fetch all users
      final users = await supabaseService.client
          .from('profiles')
          .select('*')
          .order('created_at', ascending: false);

      setState(() {
        _reportedItems = combinedItems;
        _users = List<Map<String, dynamic>>.from(users);
      });
    } catch (e) {
      debugPrint('Error fetching admin data: $e');
      MessageModal.show(context, MessageType.error, 'Error', 'Failed to load admin data.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(String itemId, String itemType) async {
    try {
      if (itemType == 'lost') {
        await supabaseService.client.from('lost_items').delete().eq('id', itemId);
      } else {
        await supabaseService.client.from('found_items').delete().eq('id', itemId);
      }
      MessageModal.show(context, MessageType.success, 'Success', 'Item deleted successfully.');
      _fetchAdminData(); // Refresh data
    } on PostgrestException catch (e) {
      debugPrint('Supabase Delete Item Error: ${e.message}');
      MessageModal.show(context, MessageType.error, 'Deletion Failed', e.message);
    } catch (e) {
      debugPrint('General Delete Item Error: $e');
      MessageModal.show(context, MessageType.error, 'Deletion Failed', 'An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      // First, delete associated lost items
      await supabaseService.client.from('lost_items').delete().eq('user_id', userId);
      // Then, delete associated found items
      await supabaseService.client.from('found_items').delete().eq('user_id', userId);
      // Finally, delete the user profile
      await supabaseService.client.from('profiles').delete().eq('id', userId);

      // Note: Deleting the user from Supabase Auth directly from client-side is not recommended
      // and usually requires admin privileges on the backend or a specific Supabase function.
      // This example assumes RLS allows profile deletion based on admin role.
      MessageModal.show(context, MessageType.info, 'User Deletion', 'User account deletion requires backend implementation. This is a placeholder.');

      MessageModal.show(context, MessageType.success, 'Success', 'User and associated items deleted successfully.');
      _fetchAdminData(); // Refresh data
    } on PostgrestException catch (e) {
      debugPrint('Supabase Delete User Error: ${e.message}');
      MessageModal.show(context, MessageType.error, 'Deletion Failed', e.message);
    } catch (e) {
      debugPrint('General Delete User Error: $e');
      MessageModal.show(context, MessageType.error, 'Deletion Failed', 'An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> _showConfirmationDialog(String type, String id, String message, VoidCallback onConfirm) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kPrimaryWhite,
          shape: RoundedRectangleBorder(borderRadius: kDefaultBorderRadius),
          title: Text('Confirm Deletion', style: GoogleFonts.poppins(color: kPrimaryBlack, fontWeight: FontWeight.bold)),
          content: Text(message, style: GoogleFonts.poppins(color: kGrey)),
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

    if (confirm == true) {
      onConfirm();
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
          'Admin Dashboard',
          style: GoogleFonts.poppins(
            color: kPrimaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: kPrimaryBlack),
            onPressed: _fetchAdminData,
          ),
          IconButton(
            icon: Icon(Icons.logout, color: kPrimaryBlack),
            onPressed: () async {
              try {
                await supabaseService.signOut();
                MessageModal.show(context, MessageType.success, 'Logged Out', 'Admin logged out successfully.');
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              } catch (e) {
                MessageModal.show(context, MessageType.error, 'Logout Failed', 'Failed to log out.');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryYellow))
          : Column(
              children: [
                Padding(
                  padding: kDefaultPadding,
                  child: Text(
                    'Welcome, $_adminFullName!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryBlack,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: kMediumSpacing),
                _buildTabBar(),
                Expanded(
                  child: _selectedTabIndex == 0
                      ? _buildItemsList()
                      : _buildUsersList(),
                ),
              ],
            ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: kDefaultPadding,
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: kSmallBorderRadius,
        boxShadow: [
          kNeumorphicShadowDark,
          kNeumorphicShadowLight,
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _buildTabButton('Items', 0),
          ),
          Expanded(
            child: _buildTabButton('Users', 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: kMediumSpacing),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryYellow : kBackground, // Yellow for selected tab
          borderRadius: kSmallBorderRadius,
          boxShadow: isSelected
              ? [
                  kNeumorphicInnerShadowDark, // Inner shadow for pressed effect
                  kNeumorphicInnerShadowLight,
                ]
              : [],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: isSelected ? kPrimaryWhite : kPrimaryBlack, // White text on yellow, black otherwise
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    if (_reportedItems.isEmpty) {
      return Center(
        child: Text(
          'No items reported yet.',
          style: GoogleFonts.poppins(color: kGrey),
        ),
      );
    }
    return ListView.builder(
      padding: kDefaultPadding,
      itemCount: _reportedItems.length,
      itemBuilder: (context, index) {
        final item = _reportedItems[index];
        return _buildItemCard(
          item['id'],
          item['image_url'],
          item['item_name'],
          item['description'],
          item['status'] ?? 'N/A',
          item['type'],
        );
      },
    );
  }

  Widget _buildItemCard(String id, String? imageUrl, String title, String description, String status, String itemType) {
    return Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                          itemType == 'lost' ? Icons.help_outline : Icons.search,
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
                      _buildStatusBadge(status, itemType),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: kSmallSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    if (itemType == 'lost') {
                      Navigator.pushNamed(context, '/lost_item_view', arguments: id);
                    } else {
                      Navigator.pushNamed(context, '/found_item_view', arguments: id);
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: kPrimaryYellow, // Yellow for links
                    shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius),
                  ),
                  child: Text('View Details', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: kSmallSpacing),
                IconButton(
                  icon: const Icon(Icons.delete, color: kRedError),
                  onPressed: () {
                    _showConfirmationDialog(
                      'Item',
                      id,
                      'Are you sure you want to delete this ${itemType == 'lost' ? 'lost' : 'found'} item?',
                      () => _deleteItem(id, itemType),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    if (_users.isEmpty) {
      return Center(
        child: Text(
          'No users found.',
          style: GoogleFonts.poppins(color: kGrey),
        ),
      );
    }
    return ListView.builder(
      padding: kDefaultPadding,
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return _buildUserCard(
          user['id'],
          user['full_name'] ?? 'N/A',
          user['email'] ?? 'N/A',
          user['user_type'] ?? 'user',
        );
      },
    );
  }

  Widget _buildUserCard(String id, String fullName, String email, String userType) {
    return Container(
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: kLightGrey,
              child: Icon(Icons.person, color: kGrey, size: 30),
            ),
            const SizedBox(width: kMediumSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: kPrimaryBlack,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    email,
                    style: GoogleFonts.poppins(color: kGrey, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Type: ${capitalizeFirstLetter(userType)}',
                    style: GoogleFonts.poppins(color: kGrey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                // Edit User Button
                TextButton(
                  onPressed: () {
                    // Ensure 'id' is not null or empty before navigating
                    if (id.isNotEmpty) {
                      Navigator.pushNamed(context, '/admin_edit_user', arguments: id);
                    } else {
                      MessageModal.show(context, MessageType.error, 'Error', 'User ID is missing for navigation.');
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: kPrimaryYellow, // Yellow for edit
                    shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius),
                  ),
                  child: Text('Edit', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: kSmallSpacing), // Consistent spacing
                // Delete User Button
                IconButton(
                  icon: const Icon(Icons.delete, color: kRedError), // Red for delete
                  onPressed: () {
                    _showConfirmationDialog(
                      'User',
                      id,
                      'Are you sure you want to delete user "$fullName"? This will delete their account and all associated items.',
                      () => _deleteUser(id),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, String itemType) {
    Color statusColor;
    String statusText;

    final normalizedStatus = status.toLowerCase().trim();

    if (itemType == 'lost') {
      switch (normalizedStatus) {
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
    } else { // Found items
      switch (normalizedStatus) {
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
