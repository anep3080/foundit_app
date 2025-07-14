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
        // Fetch admin's full name
        final Map<String, dynamic> adminProfile = await supabaseService.client
            .from('profiles')
            .select('full_name')
            .eq('id', currentUser.id)
            .single();
        _adminFullName = adminProfile['full_name'] ?? 'Admin User';
      }

      // Fetch all lost items
      final List<Map<String, dynamic>> lostItems = await supabaseService.client
          .from('lost_items')
          .select()
          .order('created_at', ascending: false);

      // Fetch all found items
      final List<Map<String, dynamic>> foundItems = await supabaseService.client
          .from('found_items')
          .select()
          .order('created_at', ascending: false);

      // Combine and sort items (you might want more sophisticated sorting)
      _reportedItems = [...lostItems, ...foundItems];
      _reportedItems.sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));

      // Fetch all users (excluding the current admin if desired, or filter by user_type)
      final List<Map<String, dynamic>> users = await supabaseService.client
          .from('profiles')
          .select()
          .order('full_name', ascending: true);
      _users = users;

    } catch (e) {
      debugPrint('Error fetching admin data: $e');
      MessageModal.show(
        context,
        MessageType.error,
        'Error',
        'Failed to load admin data: $e',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showConfirmationDialog(String type, String id, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kWhite,
          shape: RoundedRectangleBorder(borderRadius: kDefaultBorderRadius), // Use kDefaultBorderRadius
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: kDarkRed),
              const SizedBox(width: kSmallSpacing), // Use kSmallSpacing
              Text('Confirm Delete', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20)),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.poppins(color: kGrey, fontSize: 16), // Use kGrey
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: kLightGrey,
                foregroundColor: kBlack,
                shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius), // Use kSmallBorderRadius
              ),
              child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kRedError, // Danger color
                foregroundColor: kWhite,
                shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius), // Use kSmallBorderRadius
                elevation: 5, // Add elevation
              ),
              child: Text('Confirm Delete', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteItem(String itemId, String itemType) async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (itemType == 'Lost') {
        await supabaseService.client.from('lost_items').delete().eq('id', itemId);
      } else { // Found
        await supabaseService.client.from('found_items').delete().eq('id', itemId);
      }
      MessageModal.show(context, MessageType.success, 'Deleted', '$itemType item deleted successfully.');
      _fetchAdminData(); // Refresh data
    } catch (e) {
      debugPrint('Error deleting item: $e');
      MessageModal.show(context, MessageType.error, 'Error', 'Failed to delete item: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUser(String userId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Deleting from 'profiles' will cascade delete from 'auth.users' due to FK constraint
      await supabaseService.client.from('profiles').delete().eq('id', userId);
      MessageModal.show(context, MessageType.success, 'Deleted', 'User deleted successfully.');
      _fetchAdminData(); // Refresh data
    } catch (e) {
      debugPrint('Error deleting user: $e');
      MessageModal.show(context, MessageType.error, 'Error', 'Failed to delete user: $e');
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
          'Admin Dashboard',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: kWhite),
            onPressed: () async {
              await supabaseService.signOut();
              // Navigation to login is handled by main.dart's StreamBuilder
            },
          ),
          const SizedBox(width: kSmallSpacing), // Consistent spacing
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: kDefaultPadding, // Use kDefaultPadding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $_adminFullName!',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kDarkRed,
                  ),
                ),
                const SizedBox(height: kLargeSpacing), // Consistent spacing
                _buildTabSelection(),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kDarkRed))
                : RefreshIndicator( // Add RefreshIndicator for pull-to-refresh
                    onRefresh: _fetchAdminData,
                    child: _selectedTabIndex == 0
                        ? _buildItemsList()
                        : _buildUsersList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelection() {
    return Container(
      decoration: BoxDecoration(
        color: kLightYellow,
        borderRadius: kDefaultBorderRadius, // Use kDefaultBorderRadius
        boxShadow: const [kDefaultBoxShadow], // Use kDefaultBoxShadow
      ),
      child: Row(
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

  Widget _buildTabButton(String title, int index) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: kMediumSpacing), // Use kMediumSpacing
        decoration: BoxDecoration(
          color: isSelected ? kDarkRed : Colors.transparent,
          borderRadius: isSelected ? kDefaultBorderRadius : BorderRadius.zero,
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: isSelected ? kWhite : kDarkRed,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    if (_reportedItems.isEmpty) {
      return Center(
        child: Column( // Added Column for illustration and text
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: kGrey),
            const SizedBox(height: kSmallSpacing),
            Text(
              'No items reported yet.',
              style: GoogleFonts.poppins(color: kGrey, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: kDefaultPadding, // Use kDefaultPadding
      itemCount: _reportedItems.length,
      itemBuilder: (context, index) {
        final item = _reportedItems[index];
        final String itemType = item.containsKey('date_lost') ? 'Lost' : 'Found';
        final String dateField = item.containsKey('date_lost') ? 'date_lost' : 'date_found';
        final String locationField = item.containsKey('lost_location') ? 'lost_location' : 'found_location';

        return _buildItemListItem(
          item['id'] as String, // Explicitly cast to String
          item['item_name'],
          itemType,
          item['reported_by_full_name'] ?? 'N/A', // Assuming a 'reported_by_full_name' field
          item['status'],
          item[dateField],
          item[locationField],
          item['image_url'],
        );
      },
    );
  }

  Widget _buildItemListItem(
    String id,
    String itemName,
    String itemType,
    String reportedBy,
    String status,
    String date,
    String location,
    String? imageUrl,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: kSmallSpacing), // Consistent spacing
      shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius), // Use kSmallBorderRadius
      elevation: 3, // Consistent elevation
      child: Padding(
        padding: kMediumPadding, // Use kMediumPadding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: kLightGrey,
                    borderRadius: kSmallBorderRadius, // Use kSmallBorderRadius
                    image: imageUrl != null && imageUrl.isNotEmpty
                        ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: imageUrl == null || imageUrl.isEmpty
                      ? Icon(Icons.image_not_supported, size: 30, color: kGrey)
                      : null,
                ),
                const SizedBox(width: kMediumSpacing), // Consistent spacing
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$itemName (${capitalizeFirstLetter(itemType)})', // Use helper function
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: kDarkRed,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Status: ${capitalizeFirstLetter(status)}', // Use helper function
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: kGrey,
                        ),
                      ),
                      Text(
                        'Date: $date',
                        style: GoogleFonts.poppins(fontSize: 14, color: kGrey),
                      ),
                      Text(
                        'Location: $location',
                        style: GoogleFonts.poppins(fontSize: 14, color: kGrey),
                      ),
                      Text(
                        'Reported By: $reportedBy',
                        style: GoogleFonts.poppins(fontSize: 14, color: kGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: kSmallSpacing), // Consistent spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // View Details Button
                TextButton(
                  onPressed: () {
                    // Ensure 'id' is not null or empty before navigating
                    if (id.isNotEmpty) {
                      if (itemType == 'Lost') {
                        Navigator.pushNamed(context, '/lost_item_view', arguments: id);
                      } else {
                        Navigator.pushNamed(context, '/found_item_view', arguments: id);
                      }
                    } else {
                      MessageModal.show(context, MessageType.error, 'Error', 'Item ID is missing for navigation.');
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: kDarkRed,
                    shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius),
                  ),
                  child: Text('View Details', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: kSmallSpacing), // Consistent spacing
                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete, color: kRedError),
                  onPressed: () {
                    _showConfirmationDialog(
                      itemType,
                      id,
                      'Are you sure you want to delete this $itemType item?',
                      () => _deleteItem(id, itemType),
                    );
                  },
                ),
                // Add Approve/Reject buttons here for 'pending_approval' status
                // if (status == 'pending_approval') ...[
                //   IconButton(
                //     icon: const Icon(Icons.check_circle, color: kGreenSuccess),
                //     onPressed: () {
                //       // Implement approve logic
                //       print('Approve $itemType: $id');
                //     },
                //   ),
                //   IconButton(
                //     icon: const Icon(Icons.cancel, color: kRedError),
                //     onPressed: () {
                //       // Implement reject logic
                //       print('Reject $itemType: $id');
                //     },
                //   ),
                // ],
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
        child: Column( // Added Column for illustration and text
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_alt_outlined, size: 60, color: kGrey),
            const SizedBox(height: kSmallSpacing),
            Text(
              'No users found.',
              style: GoogleFonts.poppins(color: kGrey, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: kDefaultPadding, // Use kDefaultPadding
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return _buildUserListItem(
          user['id'] as String, // Explicitly cast to String
          user['full_name'] ?? 'N/A',
          user['email'] ?? 'N/A',
          user['user_type'] ?? 'user',
        );
      },
    );
  }

  Widget _buildUserListItem(
    String id,
    String fullName,
    String email,
    String userType,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: kSmallSpacing), // Consistent spacing
      shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius), // Use kSmallBorderRadius
      elevation: 3, // Consistent elevation
      child: Padding(
        padding: kMediumPadding, // Use kMediumPadding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: kPrimaryYellowGreen,
                  child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(color: kDarkRed, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: kMediumSpacing), // Consistent spacing
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: kDarkRed,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        email,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: kGrey,
                        ),
                      ),
                      Text(
                        'Type: ${capitalizeFirstLetter(userType)}', // Use helper function
                        style: GoogleFonts.poppins(fontSize: 14, color: kGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: kSmallSpacing), // Consistent spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
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
                    foregroundColor: kYellowEdit,
                    shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius),
                  ),
                  child: Text('Edit', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: kSmallSpacing), // Consistent spacing
                // Delete User Button
                IconButton(
                  icon: const Icon(Icons.delete, color: kRedError),
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
}
