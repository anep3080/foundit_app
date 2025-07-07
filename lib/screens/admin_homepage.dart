import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui_constants.dart'; // Import your constants file

class AdminHomepageScreen extends StatefulWidget {
  const AdminHomepageScreen({super.key});

  @override
  State<AdminHomepageScreen> createState() => _AdminHomepageScreenState();
}

class _AdminHomepageScreenState extends State<AdminHomepageScreen> {
  String _adminFullName = 'Admin User'; // Placeholder
  int _selectedTabIndex = 0; // 0 for Items, 1 for Users

  // Placeholder data for items and users
  final List<Map<String, dynamic>> _reportedItems = [
    {
      'id': 1,
      'itemName': 'Lost Phone',
      'itemType': 'Lost',
      'reportedBy': 'Alice',
      'status': 'pending_approval',
      'dateReported': 'Oct 26, 2023 10:30 AM',
    },
    {
      'id': 2,
      'itemName': 'Found Wallet',
      'itemType': 'Found',
      'reportedBy': 'Bob',
      'status': 'unclaimed',
      'dateReported': 'Oct 25, 2023 09:00 AM',
    },
    {
      'id': 3,
      'itemName': 'Lost Backpack',
      'itemType': 'Lost',
      'reportedBy': 'Charlie',
      'status': 'not_found',
      'dateReported': 'Oct 24, 2023 02:15 PM',
    },
    {
      'id': 4,
      'itemName': 'Found Keys',
      'itemType': 'Found',
      'reportedBy': 'David',
      'status': 'claimed',
      'dateReported': 'Oct 23, 2023 11:45 AM',
    },
    {
      'id': 5,
      'itemName': 'Lost Laptop',
      'itemType': 'Lost',
      'reportedBy': 'Eve',
      'status': 'rejected',
      'dateReported': 'Oct 22, 2023 04:00 PM',
    },
  ];

  final List<Map<String, dynamic>> _users = [
    {
      'id': 101,
      'fullName': 'Alice Smith',
      'email': 'alice@example.com',
      'phone': '111-222-3333',
      'registered': 'Sep 15, 2023',
      'userType': 'user',
    },
    {
      'id': 102,
      'fullName': 'Bob Johnson',
      'email': 'bob@example.com',
      'phone': '444-555-6666',
      'registered': 'Aug 01, 2023',
      'userType': 'user',
    },
    {
      'id': 103,
      'fullName': 'Admin User',
      'email': 'admin@example.com',
      'phone': '777-888-9999',
      'registered': 'Jul 10, 2023',
      'userType': 'admin',
    },
  ];

  String _itemSearchQuery = '';
  String _userSearchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildAdminHeader(),
              const SizedBox(height: 24),
              _buildTabButtons(),
              const SizedBox(height: 24),
              _selectedTabIndex == 0
                  ? _buildReportedItemsTab()
                  : _buildUserManagementTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: kSmallBorderRadius,
        boxShadow: const [kDefaultBoxShadow],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Admin Dashboard',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: kBlack,
            ),
          ),
          Row(
            children: [
              Icon(FontAwesomeIcons.user, color: kBlack, size: 18),
              const SizedBox(width: 8),
              Text(
                _adminFullName,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: kBlack,
                ),
              ),
              const SizedBox(width: 24),
              ElevatedButton.icon(
                onPressed: () => print('Logout'),
                icon: const Icon(
                  FontAwesomeIcons.signOutAlt,
                  size: 18,
                  color: kWhite,
                ),
                label: Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: kWhite,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF72585), // Danger color
                  shape: RoundedRectangleBorder(
                    borderRadius: kSmallBorderRadius,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButtons() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kLightGrey)),
      ),
      child: Row(
        children: [
          _buildTabButton(0, 'Reported Items', FontAwesomeIcons.box),
          _buildTabButton(1, 'User Management', FontAwesomeIcons.users),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String title, IconData icon) {
    final bool isActive = _selectedTabIndex == index;
    return TextButton.icon(
      onPressed: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      icon: Icon(
        icon,
        size: 18,
        color: isActive ? const Color(0xFF4361EE) : kGrey,
      ),
      label: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: isActive ? const Color(0xFF4361EE) : kGrey,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: const RoundedRectangleBorder(),
        side:
            isActive
                ? const BorderSide(color: Color(0xFF4361EE), width: 2)
                : BorderSide.none,
        alignment: Alignment.center,
      ),
    );
  }

  Widget _buildReportedItemsTab() {
    final filteredItems =
        _reportedItems.where((item) {
          final query = _itemSearchQuery.toLowerCase();
          return item['itemName'].toLowerCase().contains(query) ||
              item['description']?.toLowerCase().contains(query) == true ||
              item['reportedBy'].toLowerCase().contains(query) ||
              item['status'].toLowerCase().contains(query);
        }).toList();

    return Column(
      children: [
        _buildSearchExportRow(
          searchController: TextEditingController(text: _itemSearchQuery),
          onSearchChanged: (query) {
            setState(() {
              _itemSearchQuery = query;
            });
          },
          onExport: () => print('Export Items to Excel'),
        ),
        const SizedBox(height: 24),
        _buildCardContainer(
          title: 'Reported Items',
          count: filteredItems.length,
          child: _buildItemsTable(filteredItems),
        ),
      ],
    );
  }

  Widget _buildUserManagementTab() {
    final filteredUsers =
        _users.where((user) {
          final query = _userSearchQuery.toLowerCase();
          return user['fullName'].toLowerCase().contains(query) ||
              user['email'].toLowerCase().contains(query) ||
              user['phone'].toLowerCase().contains(query);
        }).toList();

    return Column(
      children: [
        _buildSearchExportRow(
          searchController: TextEditingController(text: _userSearchQuery),
          onSearchChanged: (query) {
            setState(() {
              _userSearchQuery = query;
            });
          },
          onExport: () => print('Export Users to Excel'),
        ),
        const SizedBox(height: 24),
        _buildCardContainer(
          title: 'Registered Users',
          count: filteredUsers.length,
          child: _buildUsersTable(filteredUsers),
        ),
      ],
    );
  }

  Widget _buildSearchExportRow({
    required TextEditingController searchController,
    required ValueChanged<String> onSearchChanged,
    required VoidCallback onExport,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(
                FontAwesomeIcons.search,
                size: 18,
                color: kGrey,
              ),
              border: OutlineInputBorder(
                borderRadius: kSmallBorderRadius,
                borderSide: const BorderSide(color: kLightGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: kSmallBorderRadius,
                borderSide: const BorderSide(color: kLightGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: kSmallBorderRadius,
                borderSide: const BorderSide(color: Color(0xFF4361EE)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: onExport,
          icon: const Icon(FontAwesomeIcons.fileExcel, size: 18, color: kWhite),
          label: Text(
            'Export',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: kWhite,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CC9F0), // Success color
            shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer({
    required String title,
    required int count,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: kSmallBorderRadius,
        boxShadow: const [kDefaultBoxShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: kBlack,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kLightGrey,
                  borderRadius: kCircularBorderRadius,
                ),
                child: Text(
                  '$count items',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildItemsTable(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return _buildEmptyState('No items found');
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        dataRowMinHeight: 50,
        dataRowMaxHeight: 60,
        headingRowColor: MaterialStateProperty.all(const Color(0xFFF8F9FA)),
        headingTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: kGrey,
          fontSize: 14,
        ),
        dataTextStyle: GoogleFonts.poppins(color: kBlack, fontSize: 14),
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Item Name')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Reported By')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Date Reported')),
          DataColumn(label: Text('Actions')),
        ],
        rows:
            items.map((item) {
              return DataRow(
                cells: [
                  DataCell(Text(item['id'].toString())),
                  DataCell(Text(item['itemName'])),
                  DataCell(Text(item['itemType'])),
                  DataCell(Text(item['reportedBy'])),
                  DataCell(_buildStatusBadge(item['status'], item['itemType'])),
                  DataCell(Text(item['dateReported'])),
                  DataCell(
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => print('View Item ${item['id']}'),
                          icon: const Icon(
                            FontAwesomeIcons.eye,
                            size: 16,
                            color: kWhite,
                          ),
                          label: Text(
                            'View',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: kWhite,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF4361EE,
                            ), // Primary color
                            shape: RoundedRectangleBorder(
                              borderRadius: kSmallBorderRadius,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed:
                              () => _showDeleteConfirmation(
                                item['id'],
                                item['itemName'],
                                'item',
                              ),
                          icon: const Icon(
                            FontAwesomeIcons.trash,
                            size: 16,
                            color: kWhite,
                          ),
                          label: Text(
                            'Delete',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: kWhite,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFF72585,
                            ), // Danger color
                            shape: RoundedRectangleBorder(
                              borderRadius: kSmallBorderRadius,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildUsersTable(List<Map<String, dynamic>> users) {
    if (users.isEmpty) {
      return _buildEmptyState('No registered users found');
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        dataRowMinHeight: 50,
        dataRowMaxHeight: 60,
        headingRowColor: MaterialStateProperty.all(const Color(0xFFF8F9FA)),
        headingTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: kGrey,
          fontSize: 14,
        ),
        dataTextStyle: GoogleFonts.poppins(color: kBlack, fontSize: 14),
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Full Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Phone')),
          DataColumn(label: Text('Registered')),
          DataColumn(label: Text('User Type')),
          DataColumn(label: Text('Actions')),
        ],
        rows:
            users.map((user) {
              return DataRow(
                cells: [
                  DataCell(Text(user['id'].toString())),
                  DataCell(Text(user['fullName'])),
                  DataCell(Text(user['email'])),
                  DataCell(Text(user['phone'] ?? 'N/A')),
                  DataCell(Text(user['registered'])),
                  DataCell(
                    DropdownButton<String>(
                      value: user['userType'],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            user['userType'] = newValue; // Simulate update
                          });
                          print('User ${user['id']} type changed to $newValue');
                        }
                      },
                      items:
                          <String>[
                            'user',
                            'admin',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value.toCapitalized()),
                            );
                          }).toList(),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        if (user['id'] == 103) // Simulate current admin
                          Text(
                            'Current Admin',
                            style: GoogleFonts.poppins(color: kGrey),
                          ),
                        if (user['id'] != 103)
                          ElevatedButton.icon(
                            onPressed:
                                () => _showDeleteConfirmation(
                                  user['id'],
                                  user['fullName'],
                                  'user',
                                ),
                            icon: const Icon(
                              FontAwesomeIcons.trash,
                              size: 16,
                              color: kWhite,
                            ),
                            label: Text(
                              'Delete',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: kWhite,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFFF72585,
                              ), // Danger color
                              shape: RoundedRectangleBorder(
                                borderRadius: kSmallBorderRadius,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildStatusBadge(String status, String itemType) {
    Color bgColor;
    Color textColor;
    String displayText;

    if (itemType == 'Lost') {
      switch (status) {
        case 'not_found':
          bgColor = const Color(0xFFFFE0E0);
          textColor = const Color(0xFFD9534F);
          displayText = 'Not Found';
          break;
        case 'found':
          bgColor = const Color(0xFFE6FFE6);
          textColor = const Color(0xFF5CB85C);
          displayText = 'Found';
          break;
        case 'pending_approval':
          bgColor = const Color(0xFFFFF3CD);
          textColor = const Color(0xFFF0AD4E);
          displayText = 'Pending Approval';
          break;
        case 'rejected':
          bgColor = const Color(0xFFE9ECEF);
          textColor = const Color(0xFF6C757D);
          displayText = 'Rejected';
          break;
        default:
          bgColor = Colors.grey[200]!;
          textColor = Colors.grey[700]!;
          displayText = status.replaceAll('_', ' ').toCapitalized();
      }
    } else {
      // Found items
      switch (status) {
        case 'unclaimed':
          bgColor = const Color(0xFFFFE0E0);
          textColor = const Color(0xFFD9534F);
          displayText = 'Unclaimed';
          break;
        case 'claimed':
          bgColor = const Color(0xFFE6FFE6);
          textColor = const Color(0xFF5CB85C);
          displayText = 'Claimed';
          break;
        case 'pending_approval':
          bgColor = const Color(0xFFFFF3CD);
          textColor = const Color(0xFFF0AD4E);
          displayText = 'Pending Approval';
          break;
        case 'rejected':
          bgColor = const Color(0xFFE9ECEF);
          textColor = const Color(0xFF6C757D);
          displayText = 'Rejected';
          break;
        default:
          bgColor = Colors.grey[200]!;
          textColor = Colors.grey[700]!;
          displayText = status.replaceAll('_', ' ').toCapitalized();
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        displayText,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.boxOpen,
            size: 48,
            color: const Color(0xFFDEE2E6),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(color: kGrey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int id, String name, String type) {
    String message;
    if (type == 'item') {
      message =
          'You are about to delete:\n$name (ID: $id)\nThis action cannot be undone!';
    } else {
      message =
          'You are about to delete user:\n$name (ID: $id)\nThis will permanently delete the user account and all their items!';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kWhite,
          shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius),
          title: Row(
            children: [
              Icon(
                FontAwesomeIcons.exclamationTriangle,
                color: kRedError,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Confirm Deletion',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.poppins(color: kGrey, fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: kLightGrey,
                foregroundColor: kBlack,
                shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                print('Confirmed delete $type: $id');
                // Implement actual delete logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF72585), // Danger color
                foregroundColor: kWhite,
                shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius),
              ),
              child: Text(
                'Confirm Delete',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }
}

extension StringExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}
