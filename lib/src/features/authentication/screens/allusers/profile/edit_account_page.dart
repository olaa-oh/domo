import 'package:domo/src/features/authentication/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:domo/src/constants/style.dart';
import 'package:get/get.dart';
import 'package:domo/src/constants/user_model.dart';
import 'package:image_picker/image_picker.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.put(ProfileController());
  bool _isUploading = false;
  Future<UserModel?> _userFuture = Future.value(null);

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _userFuture = controller.getUser();
    });
  }

  Future<void> _pickImage() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        String? newPhotoUrl = await controller.uploadProfilePicture(image.path);

        if (newPhotoUrl != null) {
          Get.snackbar('Success', 'Profile picture updated successfully');
          _refreshData();
        }
      }
    } catch (e) {
      print("Error picking or uploading image: $e");
      Get.snackbar('Error', 'Failed to update profile picture');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Stack(
            children: [
              FutureBuilder<UserModel?>(
                future: _userFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return _buildContent(snapshot.data!);
                  } else {
                    return Center(child: Text('No user data found'));
                  }
                },
              ),
              if (_isUploading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(UserModel userData) {
    final email = TextEditingController(text: userData.email);
    final name = TextEditingController(text: userData.name);
    final phonenumber = TextEditingController(text: userData.phonenumber);
    final password = TextEditingController(text: userData.password);

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: AppTheme.darkBackground),
              onPressed: () => Get.back(),
            ),
            Text(
              'Edit Account',
              style: AppTheme.textTheme.headlineSmall!.copyWith(
                color: AppTheme.darkBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.button,
                backgroundImage: userData.imageUrl != null
                    ? NetworkImage(userData.imageUrl!)
                    : AssetImage('assets/images/domoologo.png') as ImageProvider,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: AppTheme.button,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt,
                        color: AppTheme.background),
                    onPressed: _pickImage,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: name,
                label: 'Name',
                icon: Icons.person,
              ),
              _buildTextField(
                controller: email,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                controller: phonenumber,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                controller: password,
                label: 'New Password',
                icon: Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.button,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate())  {
                    UserModel updatedUser = UserModel(
                      id: userData.id,
                      name: name.text.trim(),
                      email: email.text.trim(),
                      phonenumber: phonenumber.text.trim(),
                      password: password.text.trim(),
                      imageUrl: userData.imageUrl,
                      role: userData.role,
                      // isArtisan: userData.isArtisan,
                    );
                    await controller.updateUser(updatedUser);
                    _refreshData();
                  }
                },
                child: Text(
                  'Save Changes',
                  style: AppTheme.textTheme.titleMedium!.copyWith(
                    color: AppTheme.background,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.button),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppTheme.button, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}