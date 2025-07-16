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

class ReportFoundFormScreen extends StatefulWidget {
  const ReportFoundFormScreen({super.key});

  @override
  State<ReportFoundFormScreen> createState() => _ReportFoundFormScreenState();
}

class _ReportFoundFormScreenState extends State<ReportFoundFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _foundLocationController = TextEditingController();
  final TextEditingController _dateFoundController = TextEditingController();

  String? _selectedCategory;
  File? _selectedImageFile;
  bool _isLoading = false;
  String? _userTelegramUsername; // To store the fetched user's Telegram username

  final List<String> _categories = [
    'Electronics',
    'Documents',
    'Clothing',
    'Accessories',
    'Books',
    'Keys',
    'Wallets/Purses',
    'Bags',
    'Jewelry',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _dateFoundController.text = DateTime.now().toLocal().toString().split(' ')[0]; // Set initial date to today
    _fetchUserTelegramUsername(); // Fetch user's Telegram username on init
  }

  // New method to fetch the user's Telegram username
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
        // If there's an error, _userTelegramUsername will remain null
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      setState(() {
        _selectedImageFile = File(image.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final String fileName = '${const Uuid().v4()}${p.extension(imageFile.path)}';
      final String path = 'found_item_images/${supabaseService.currentUser!.id}/$fileName';

      await supabaseService.client.storage
          .from('item-image')
          .upload(path, imageFile,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false));

      final String imageUrl = supabaseService.client.storage
          .from('item-image')
          .getPublicUrl(path);

      return imageUrl;
    } on StorageException catch (e) {
      debugPrint('Error uploading image to Supabase Storage: ${e.message}');
      MessageModal.show(
        context,
        MessageType.error,
        'Upload Failed',
        'Failed to upload image: ${e.message}',
      );
      return null;
    } catch (e) {
      debugPrint('General image upload error: $e');
      MessageModal.show(
        context,
        MessageType.error,
        'Upload Failed',
        'An unexpected error occurred during image upload: $e',
      );
      return null;
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImageFile == null) {
      MessageModal.show(
        context,
        MessageType.error,
        'Missing Image',
        'Please select an image for the found item.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? imageUrl;
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

      await supabaseService.client.from('found_items').insert({
        'item_name': _itemNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'found_location': _foundLocationController.text.trim(),
        'date_found': _dateFoundController.text,
        'category': _selectedCategory,
        'image_url': imageUrl,
        'reporter_id': currentUser.id, // Link to the current user
        'reporter_telegram_username': _userTelegramUsername, // Use fetched Telegram username
        'status': 'unclaimed', // Default status for new found items
      });

      MessageModal.show(
        context,
        MessageType.success,
        'Success!',
        'Found item reported successfully. Thank you!',
      );
      if (mounted) {
        Navigator.pop(context); // Go back to the previous screen (Homepage)
      }
    } catch (e) {
      debugPrint('Error submitting found item report: $e');
      MessageModal.show(
        context,
        MessageType.error,
        'Submission Failed',
        'Failed to report found item: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _foundLocationController.dispose();
    _dateFoundController.dispose();
    // _telegramUsernameController.dispose(); // Removed as it's no longer used
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryYellowGreen,
      appBar: AppBar(
        backgroundColor: kDarkRed,
        title: Text(
          'Report Found Item',
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
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: kWhite, strokeWidth: 2),
                  )
                : const Icon(Icons.check, color: kWhite),
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
                  color: kDarkRed,
                ),
              ),
              const SizedBox(height: kLargeSpacing),
              _buildImagePicker(),
              const SizedBox(height: kLargeSpacing),
              _buildTextField(
                _itemNameController,
                'Item Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Item Name is required';
                  }
                  return null;
                },
              ),
              _buildTextField(
                _descriptionController,
                'Description',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              _buildCategoryDropdown(),
              _buildTextField(
                _foundLocationController,
                'Found Location',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Found Location is required';
                  }
                  return null;
                },
              ),
              _buildDatePicker(),
              // Removed the manual Telegram Username input field
              const SizedBox(height: kLargeSpacing),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSmallSpacing),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.poppins(color: kBlack),
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: kWhite,
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
            borderSide: const BorderSide(color: kDarkRed, width: 2),
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
        validator: validator,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSmallSpacing),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          hintText: 'Select Category',
          filled: true,
          fillColor: kWhite,
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
            borderSide: const BorderSide(color: kDarkRed, width: 2),
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
        dropdownColor: kLightYellow,
        style: GoogleFonts.poppins(color: kBlack),
        icon: const Icon(Icons.arrow_drop_down, color: kGrey),
        items: _categories.map((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(capitalizeFirstLetter(category)), // Use helper function
          );
        }).toList(),
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
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSmallSpacing),
      child: TextFormField(
        controller: _dateFoundController,
        readOnly: true,
        style: GoogleFonts.poppins(color: kBlack),
        decoration: InputDecoration(
          hintText: 'Date Found',
          filled: true,
          fillColor: kWhite,
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
            borderSide: const BorderSide(color: kDarkRed, width: 2),
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
                      colorScheme: ColorScheme.light(
                        primary: kDarkRed, // Header background color
                        onPrimary: kWhite, // Header text color
                        onSurface: kBlack, // Body text color
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: kDarkRed, // Button text color
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                setState(() {
                  _dateFoundController.text = pickedDate.toLocal().toString().split(' ')[0];
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
            return 'Date Found is required';
          }
          return null;
        },
      ),
    );
  }
}
