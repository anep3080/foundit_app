import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../ui_constants.dart'; // Import your constants
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
        if (mounted) { // Guard against async gap
          setState(() {
            _userTelegramUsername = profile['telegram_username'];
          });
        }
      } catch (e) {
        debugPrint('Error fetching user telegram username: $e');
        // If there's an error, _userTelegramUsername will remain null
      }
    }
  }

  // Method to show image source selection (Camera or Gallery)
  Future<void> _showImageSourceSelection() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a picture'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Modified _pickImage to accept ImageSource
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source, imageQuality: 70);

    if (image != null) {
      if (mounted) { // Guard against async gap
        setState(() {
          _selectedImageFile = File(image.path);
        });
      }
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final String fileName = '${const Uuid().v4()}${p.extension(imageFile.path)}';
      // Corrected: Use 'item-image' bucket and 'found_item_images' subfolder
      final String path = 'found_item_images/${supabaseService.currentUser!.id}/$fileName';

      await supabaseService.client.storage
          .from('item-image') // Corrected bucket name
          .upload(path, imageFile,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false));

      final String imageUrl = supabaseService.client.storage
          .from('item-image') // Corrected bucket name
          .getPublicUrl(path);

      return imageUrl;
    } on StorageException catch (e) {
      debugPrint('Error uploading image to Supabase Storage: ${e.message}');
      if (mounted) { // Guard against async gap
        MessageModal.show(
          context,
          MessageType.error,
          'Upload Failed',
          'Failed to upload image: ${e.message}',
        );
      }
      return null;
    } catch (e) {
      debugPrint('General image upload error: $e');
      if (mounted) { // Guard against async gap
        MessageModal.show(
          context,
          MessageType.error,
          'Upload Failed',
          'An unexpected error occurred during image upload: $e',
        );
      }
      return null;
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImageFile == null) {
      if (mounted) { // Guard against async gap
        MessageModal.show(
          context,
          MessageType.error,
          'Missing Image',
          'Please select an image for the found item.',
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? imageUrl;
    if (_selectedImageFile != null) {
      imageUrl = await _uploadImage(_selectedImageFile!);
      if (imageUrl == null) {
        if (mounted) { // Guard against async gap
          setState(() { _isLoading = false; });
        }
        return; // Stop if image upload failed
      }
    }

    try {
      final User? currentUser = supabaseService.currentUser;
      if (currentUser == null) {
        if (mounted) { // Guard against async gap
          MessageModal.show(context, MessageType.error, 'Error', 'You must be logged in to report an item.');
          setState(() { _isLoading = false; });
        }
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

      if (mounted) { // Guard against async gap
        MessageModal.show(
          context,
          MessageType.success,
          'Report Success!',
          'Your found item has been reported successfully!',
        );
        Navigator.pop(context); // Go back to the previous screen (Homepage)
      }
    } catch (e) {
      debugPrint('Error submitting found item report: $e');
      if (mounted) { // Guard against async gap
        MessageModal.show(
          context,
          MessageType.error,
          'Submission Failed',
          'Failed to report found item: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) { // Guard against async gap
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _foundLocationController.dispose();
    _dateFoundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Use theme background color
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // Use theme AppBar color
        title: Text(
          'Report Found Item',
          style: GoogleFonts.poppins(
            color: Theme.of(context).appBarTheme.foregroundColor, // Use theme AppBar text color
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).appBarTheme.foregroundColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton( // Replaced NeumorphicButton with IconButton
            onPressed: _isLoading ? null : _submitReport,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: kBlack, strokeWidth: 2), // kBlack is now defined
                  )
                : const Icon(Icons.check, color: kBlack), // kBlack is now defined
          ),
          const SizedBox(width: kSmallSpacing),
        ],
      ),
      body: SingleChildScrollView(
        padding: kDefaultPadding,
        child: Container( // Replaced NeumorphicButton with Container
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? kCardColor, // Fallback, kCardColor is now defined
            borderRadius: kDefaultBorderRadius,
            boxShadow: const [kNeumorphicShadowDark, kNeumorphicShadowLight],
          ),
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
                    color: kPrimaryYellow, // Use primary yellow
                  ),
                ),
                const SizedBox(height: kLargeSpacing),
                _buildImagePicker(),
                const SizedBox(height: kLargeSpacing),
                _buildTextField(
                  _itemNameController,
                  'Item Name',
                  Icons.label, // Added icon
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
                  Icons.description, // Added icon
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
                  Icons.location_on, // Added icon
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Found Location is required';
                    }
                    return null;
                  },
                ),
                _buildDatePicker(),
                const SizedBox(height: kLargeSpacing),
                Center(
                  child: ElevatedButton( // Replaced NeumorphicButton with ElevatedButton
                    onPressed: _isLoading ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryYellow, // Yellow button
                      foregroundColor: kBlack, // Black text, kBlack is now defined
                      padding: const EdgeInsets.symmetric(horizontal: kLargeSpacing, vertical: kMediumSpacing),
                      shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius),
                      elevation: 5, // Add some elevation for a raised effect
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: kBlack) // kBlack is now defined
                        : Text(
                            'Submit Report',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector( // Replaced NeumorphicButton with GestureDetector
        onTap: _showImageSourceSelection, // Call the new method
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? kCardColor, // Fallback, kCardColor is now defined
            borderRadius: kDefaultBorderRadius,
            boxShadow: const [kNeumorphicShadowDark, kNeumorphicShadowLight], // Apply neumorphic shadows
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
    String hintText,
    IconData icon, { // Added icon parameter
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
        style: GoogleFonts.poppins(color: Theme.of(context).textTheme.bodyMedium?.color ?? kPrimaryTextColor), // Fallback, kPrimaryTextColor is now defined
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: kGrey), // Use icon parameter
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? kCardColor, // Fallback, kCardColor is now defined
          border: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide.none, // No border for neumorphic look
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide(color: kPrimaryYellow, width: 2), // Accent color on focus
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
          prefixIcon: Icon(Icons.category, color: kGrey), // Added icon
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? kCardColor, // Fallback, kCardColor is now defined
          border: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide.none, // No border for neumorphic look
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide(color: kPrimaryYellow, width: 2), // Accent color on focus
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
        dropdownColor: Theme.of(context).cardTheme.color ?? kCardColor, // Fallback, kCardColor is now defined
        style: GoogleFonts.poppins(color: Theme.of(context).textTheme.bodyMedium?.color ?? kPrimaryTextColor), // Fallback, kPrimaryTextColor is now defined
        icon: Icon(Icons.arrow_drop_down, color: kGrey),
        items: _categories.map((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(
              capitalizeFirstLetter(category),
              style: GoogleFonts.poppins(color: Theme.of(context).textTheme.bodyMedium?.color ?? kPrimaryTextColor), // Fallback, kPrimaryTextColor is now defined
            ),
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
        style: GoogleFonts.poppins(color: Theme.of(context).textTheme.bodyMedium?.color ?? kPrimaryTextColor), // Fallback, kPrimaryTextColor is now defined
        decoration: InputDecoration(
          hintText: 'Date Found',
          prefixIcon: Icon(Icons.calendar_today, color: kGrey), // Added icon
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? kCardColor, // Fallback, kCardColor is now defined
          border: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide.none, // No border for neumorphic look
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide(color: kPrimaryYellow, width: 2), // Accent color on focus
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today, color: kGrey),
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light( // Ensure date picker theme matches app theme
                        primary: kPrimaryYellow, // Header background color
                        onPrimary: kBlack, // Header text color, kBlack is now defined
                        onSurface: Theme.of(context).textTheme.bodyMedium?.color ?? kBlack, // Body text color, with fallback, kBlack is now defined
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: kPrimaryYellow, // Button text color
                        ),
                      ),
                      // For dark mode, you might need to adjust more properties like dialogBackgroundColor
                      dialogBackgroundColor: Theme.of(context).cardTheme.color ?? kCardColor, // Fallback, kCardColor is now defined
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                if (mounted) { // Guard against async gap
                  setState(() {
                    _dateFoundController.text = pickedDate.toLocal().toString().split(' ')[0];
                  });
                }
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
