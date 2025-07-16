import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../ui_constants.dart';
import '../services/supabase_service.dart';
import '../widgets/message_modal.dart';

// Helper function to capitalize the first letter of a string
String capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return '';
  }
  return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
}

class ReportLostFormScreen extends StatefulWidget {
  const ReportLostFormScreen({super.key});

  @override
  State<ReportLostFormScreen> createState() => _ReportLostFormScreenState();
}

class _ReportLostFormScreenState extends State<ReportLostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _lostLocationController = TextEditingController();
  final TextEditingController _dateLostController = TextEditingController();

  String? _selectedCategory;
  File? _selectedImageFile;
  bool _isLoading = false;
  String? _userTelegramUsername; // To store the user's Telegram username

  final List<String> _categories = [
    'Electronics', 'Documents', 'Clothing', 'Keys', 'Bags', 'Jewelry',
    'Wallets', 'Books', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _dateLostController.text = DateTime.now().toLocal().toString().split(' ')[0]; // Set initial date to today
    _fetchUserTelegramUsername(); // Fetch user's Telegram username on init
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _lostLocationController.dispose();
    _dateLostController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserTelegramUsername() async {
    final User? currentUser = supabaseService.currentUser;
    if (currentUser != null) {
      try {
        final profile = await supabaseService.client
            .from('profiles')
            .select('telegram_username')
            .eq('id', currentUser.id)
            .single();
        setState(() {
          _userTelegramUsername = profile['telegram_username'];
        });
      } catch (e) {
        debugPrint('Error fetching user telegram username: $e');
        // If fetching fails, userTelegramUsername remains null, which is handled
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70); // Added imageQuality

    if (image != null) {
      setState(() {
        _selectedImageFile = File(image.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final String fileName = '${const Uuid().v4()}${p.extension(imageFile.path)}';
      // Use a path that includes the user's ID, similar to old working code
      final String path = 'lost_item_images/${supabaseService.currentUser!.id}/$fileName';

      // Debug prints for upload path
      debugPrint('Supabase Storage Upload Path: $path');

      await supabaseService.client.storage
          .from('item-image') // Ensure this bucket name is correct
          .upload(path, imageFile, fileOptions: const FileOptions(cacheControl: '3600', upsert: false)); // Changed upsert to false

      final String imageUrl = supabaseService.client.storage.from('item-image').getPublicUrl(path);
      return imageUrl;
    } on StorageException catch (e) {
      debugPrint('Error uploading image to Supabase Storage: ${e.message}');
      MessageModal.show(context, MessageType.error, 'Upload Failed', 'Failed to upload image: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('General image upload error: $e');
      MessageModal.show(context, MessageType.error, 'Upload Failed', 'An unexpected error occurred during image upload: $e');
      return null;
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImageFile == null) {
      MessageModal.show(context, MessageType.error, 'Error', 'Please select an image for the item.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? imageUrl;
    // Call the new _uploadImage method
    if (_selectedImageFile != null) {
      imageUrl = await _uploadImage(_selectedImageFile!);
      if (imageUrl == null) {
        setState(() { _isLoading = false; });
        return; // Stop if image upload failed
      }
    }


    try {
      final User? currentUser = supabaseService.currentUser;
      if (currentUser == null) {
        MessageModal.show(context, MessageType.error, 'Error', 'You must be logged in to report an item.');
        setState(() { _isLoading = false; });
        return;
      }

      // Debug prints before insert
      debugPrint('Inserting lost item data...');
      debugPrint('Item Name: ${_itemNameController.text.trim()}');
      debugPrint('Category: $_selectedCategory');
      debugPrint('Image URL: $imageUrl');
      debugPrint('Reporter ID: ${currentUser.id}');
      debugPrint('Reporter Telegram Username: $_userTelegramUsername');


      // Insert data into 'lost_items' table
      await supabaseService.client.from('lost_items').insert({
        'item_name': _itemNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'lost_location': _lostLocationController.text.trim(),
        'date_lost': _dateLostController.text,
        'image_url': imageUrl,
        'reporter_id': currentUser.id, // Changed from user_id to reporter_id
        // Removed 'reporter_name' as per your request
        'reporter_telegram_username': _userTelegramUsername, // Explicitly add telegram username
        'status': 'not found', // Default status
      });

      MessageModal.show(context, MessageType.success, 'Success', 'Lost item reported successfully!');
      Navigator.pop(context); // Go back to previous screen
    } on StorageException catch (e) {
      debugPrint('Supabase Storage Error: ${e.message}');
      MessageModal.show(context, MessageType.error, 'Upload Failed', 'Failed to upload image: ${e.message}');
    } on PostgrestException catch (e) {
      debugPrint('Supabase Database Error: ${e.message}');
      MessageModal.show(context, MessageType.error, 'Submission Failed', 'Failed to submit report: ${e.message}');
    } catch (e) {
      debugPrint('General Error: $e');
      MessageModal.show(context, MessageType.error, 'Error', 'An unexpected error occurred: $e');
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
        title: Text(
          'Report Lost Item',
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
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: kPrimaryBlack, strokeWidth: 2),
                  )
                : const Icon(Icons.check, color: kPrimaryBlack),
            onPressed: _isLoading ? null : _submitReport,
          ),
          const SizedBox(width: kSmallSpacing),
        ],
      ),
      body: SingleChildScrollView(
        padding: kDefaultPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Item Details',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryBlack,
                ),
              ),
              const SizedBox(height: kLargeSpacing),
              _buildImagePicker(), // This method is now defined below
              const SizedBox(height: kLargeSpacing),
              _buildTextField(
                controller: _itemNameController,
                labelText: 'Item Name',
                hintText: 'e.g., Black Wallet',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Item Name is required';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'e.g., Contains ID card and some cash',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              // Corrected call to _buildCategoryDropdown with required parameters
              _buildCategoryDropdown(
                labelText: 'Category',
                value: _selectedCategory,
                items: _categories,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Category is required';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _lostLocationController,
                labelText: 'Lost Location',
                hintText: 'e.g., Lecture Hall 1, Main Library',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lost Location is required';
                  }
                  return null;
                },
              ),
              _buildDateField(
                controller: _dateLostController,
                labelText: 'Date Lost',
              ),
              const SizedBox(height: kLargeSpacing),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryGreen,
                    foregroundColor: kPrimaryWhite,
                    padding: const EdgeInsets.symmetric(horizontal: kLargeSpacing, vertical: kMediumSpacing),
                    shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: kPrimaryWhite)
                      : Text('Submit Report', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Moved _buildImagePicker inside the _ReportLostFormScreenState class
  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: kLightGrey,
            borderRadius: kDefaultBorderRadius,
            border: Border.all(color: kGrey, width: 1),
            image: _selectedImageFile != null
                ? DecorationImage(
                    image: FileImage(_selectedImageFile!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _selectedImageFile == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 50, color: kGrey),
                    const SizedBox(height: kSmallSpacing),
                    Text(
                      'Tap to add image',
                      style: GoogleFonts.poppins(color: kGrey, fontSize: 16),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSmallSpacing),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          filled: true,
          fillColor: kPrimaryWhite,
          border: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: const BorderSide(color: kPrimaryBlack, width: 2), // Changed from kDarkRed
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: const BorderSide(color: kRedError, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: const BorderSide(color: kRedError, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: kMediumSpacing, vertical: kMediumSpacing),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(color: kPrimaryBlack),
        validator: validator,
      ),
    );
  }

  // Moved _buildCategoryDropdown inside the _ReportLostFormScreenState class
  Widget _buildCategoryDropdown({
    required String labelText,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSmallSpacing),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          filled: true,
          fillColor: kPrimaryWhite,
          border: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: const BorderSide(color: kPrimaryBlack, width: 2), // Changed from kDarkRed
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: const BorderSide(color: kRedError, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: const BorderSide(color: kRedError, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: kMediumSpacing, vertical: kMediumSpacing),
        ),
        dropdownColor: kBackground,
        style: GoogleFonts.poppins(color: kPrimaryBlack),
        icon: const Icon(Icons.arrow_drop_down, color: kGrey),
        items: items.map((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(capitalizeFirstLetter(category), style: GoogleFonts.poppins(color: kPrimaryBlack)),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSmallSpacing),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: GoogleFonts.poppins(color: kPrimaryBlack),
        decoration: InputDecoration(
          labelText: labelText,
          filled: true,
          fillColor: kPrimaryWhite,
          border: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: const BorderSide(color: kPrimaryBlack, width: 2), // Changed from kDarkRed
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today, color: kGrey),
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: kPrimaryBlack, // Header background color
                        onPrimary: kPrimaryWhite, // Header text color
                        onSurface: kPrimaryBlack, // Body text color
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: kPrimaryBlack, // Button text color
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                setState(() {
                  controller.text = pickedDate.toLocal().toString().split(' ')[0];
                });
              }
            },
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: const BorderSide(color: kRedError, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: const BorderSide(color: kRedError, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: kMediumSpacing, vertical: kMediumSpacing),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Date Lost is required';
          }
          return null;
        },
      ),
    );
  }
}
