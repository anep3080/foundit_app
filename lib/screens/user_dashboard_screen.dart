import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui_constants.dart';
import '../services/supabase_service.dart';
import '../widgets/message_modal.dart';

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

  @override
  void initState() {
    super.initState();
    _currentUserId = supabaseService.currentUser?.id;
    if (_currentUserId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        MessageModal.show(context, MessageType.error, 'Access Denied', 'You must be logged in to view this page.');
        Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
      });
    } else {
      _fetchUserReports();
    }
  }

  Future<void> _fetchUserReports() async {
    setState(() => _isLoading = true);
    try {
      final lostResponse = await supabaseService.client
          .from('lost_items')
          .select()
          .eq('reporter_id', _currentUserId!)
          .order('created_at', ascending: false);

      final foundResponse = await supabaseService.client
          .from('found_items')
          .select()
          .eq('reporter_id', _currentUserId!)
          .order('created_at', ascending: false);

      setState(() {
        _userLostItems = lostResponse;
        _userFoundItems = foundResponse;
      });
    } catch (e) {
      MessageModal.show(context, MessageType.error, 'Error', 'Failed to load your reports: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteReport(String itemId, String itemType) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryYellowGreen,
      appBar: AppBar(
        backgroundColor: kDarkRed,
        title: Text('My Reports', style: GoogleFonts.poppins(color: kWhite, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kDarkRed))
          : RefreshIndicator(
              onRefresh: _fetchUserReports,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: kDefaultPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

  Widget _buildSection(String title, List<Map<String, dynamic>> items, String itemType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: kDarkRed)),
        const SizedBox(height: kMediumSpacing),
        items.isEmpty
            ? _buildNoItemsMessage(itemType.toLowerCase())
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildReportCard(
                    id: item['id'],
                    itemName: item['item_name'],
                    description: item['description'],
                    imageUrl: item['image_url'],
                    status: item['status'],
                    date: itemType == 'Lost' ? item['date_lost'] : item['date_found'],
                    location: itemType == 'Lost' ? item['lost_location'] : item['found_location'],
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
    required String id,
    required String itemName,
    required String description,
    String? imageUrl,
    required String status,
    required String date,
    required String location,
    required String itemType,
  }) {
    final bool canDelete = !(itemType == 'Lost' && (status == 'found' || status == 'claimed')) &&
        !(itemType == 'Found' && status == 'claimed');

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
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: kDarkRed)),
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
                TextButton(
                  onPressed: () {
                    if (itemType == 'Lost') {
                      Navigator.pushNamed(context, '/lost_item_view', arguments: id);
                    } else {
                      Navigator.pushNamed(context, '/found_item_view', arguments: id);
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: kDarkRed),
                  child: Text('View Details', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                ),
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
