import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui_constants.dart'; // Import your constants file

class ReportLostFormScreen extends StatefulWidget {
  final String? itemId; // Null for new report, ID for edit

  const ReportLostFormScreen({super.key, this.itemId});

  @override
  State<ReportLostFormScreen> createState() => _ReportLostFormScreenState();
}

class _ReportLostFormScreenState extends State<ReportLostFormScreen> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateLostController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _selectedCategory;
  String? _imagePreviewUrl; // For displaying existing image or new upload

  @override
  void initState() {
    super.initState();
    if (widget.itemId != null) {
      // Simulate fetching data for editing
      _itemNameController.text = 'Lost Wallet';
      _descriptionController.text = 'Black leather wallet with ID cards and some cash.';
      _dateLostController.text = '2023-10-26';
      _locationController.text = 'University Library';
      _selectedCategory = 'Wallets';
      _imagePreviewUrl = 'https://via.placeholder.com/150/DC3545/FFFFFF?text=Wallet'; // Placeholder
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _dateLostController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateLostController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _handleImageUpload() {
    // Simulate image picking
    setState(() {
      _imagePreviewUrl = 'https://via.placeholder.com/150/00FF00/000000?text=New+Image'; // Simulate new image
    });
    print('Image upload clicked');
  }

  @override
  Widget build(BuildContext context) {
    final String pageTitle = widget.itemId == null ? 'Report Lost Item' : 'Edit Lost Item';

    return Scaffold(
      backgroundColor: kPrimaryYellowGreen,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              color: kLightYellow,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [kDefaultBoxShadow],
            ),
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FoundIt',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(2, 2),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => print('Home icon pressed'),
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: kBlack, width: 2),
                        ),
                        child: const Icon(FontAwesomeIcons.home, color: kBlack, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    pageTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      color: const Color(0xFF333333),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                _buildTextField(_itemNameController, 'Item Name', required: true),
                _buildTextArea(_descriptionController, 'Description', required: true),
                const SizedBox(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date Lost',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF333333)),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _dateLostController,
                                decoration: _inputDecoration('YYYY-MM-DD'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: _handleImageUpload,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCCCCCC), width: 2, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Upload Image',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 10),
                              const Icon(FontAwesomeIcons.upload, size: 40, color: kDarkRed),
                              if (_imagePreviewUrl != null && _imagePreviewUrl!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Image.network(
                                    _imagePreviewUrl!,
                                    height: 100,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Item Category',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF333333)),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: _inputDecoration('Select Category'),
                            items: _buildCategoryDropdownItems(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            },
                            validator: (value) => value == null ? 'Please select a category' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _buildTextField(_locationController, 'Location Lost', required: true),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
                      print('Submit button pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDarkRed,
                      foregroundColor: kWhite,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                      minimumSize: const Size(150, 48),
                    ),
                    child: const Text('SUBMIT'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: kWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kDarkRed),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.5),
      child: TextField(
        controller: controller,
        decoration: _inputDecoration(hintText),
      ),
    );
  }

  Widget _buildTextArea(TextEditingController controller, String hintText, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.5),
      child: TextField(
        controller: controller,
        maxLines: 5,
        minLines: 3,
        decoration: _inputDecoration(hintText),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildCategoryDropdownItems() {
    final List<String> categories = [
      'Electronics', 'Clothing', 'Accessories', 'Documents', 'Keys',
      'Bags', 'Wallets', 'Jewelry', 'Books', 'Other'
    ];
    return categories.map((String category) {
      return DropdownMenuItem<String>(
        value: category,
        child: Text(category, style: GoogleFonts.poppins()),
      );
    }).toList();
  }
}