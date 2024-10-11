import 'package:domo/src/data/auth_repository/city_repository.dart';
import 'package:domo/src/data/auth_repository/region_repository.dart';
import 'package:domo/src/features/authentication/model/city_model.dart';
import 'package:domo/src/features/authentication/model/region_model.dart';
import 'package:domo/src/features/authentication/model/shop_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:domo/src/features/authentication/model/style_model.dart';
import 'package:domo/src/features/shop/view/my_shop_page.dart';
import 'package:uuid/uuid.dart';

class CreateShopPage extends StatefulWidget {
  @override
  _CreateShopPageState createState() => _CreateShopPageState();
}

class _CreateShopPageState extends State<CreateShopPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final servicesController = TextEditingController();

  final RegionRepository _regionRepository = RegionRepository();
  final CityRepository _cityRepository = CityRepository();

  File? _profileImage;
  List<File> _galleryImages = [];
  Position? _currentPosition;

  String? selectedRegionId;
  String? selectedCityId;
  List<RegionModel> regions = [];
  List<CityModel> cities = [];

  Map<String, WorkingHours> workingHours = {
    'Monday': WorkingHours(open: '', close: ''),
    'Tuesday': WorkingHours(open: '', close: ''),
    'Wednesday': WorkingHours(open: '', close: ''),
    'Thursday': WorkingHours(open: '', close: ''),
    'Friday': WorkingHours(open: '', close: ''),
    'Saturday': WorkingHours(open: '', close: ''),
    'Sunday': WorkingHours(open: '', close: ''),
  };

  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    _fetchRegions();
    _loadShopIfExists();
  }

  Future<void> _fetchRegions() async {
    regions = await _regionRepository.getRegions();
    setState(() {});
  }

  Future<void> _fetchCities(String regionId) async {
    cities = await _cityRepository.getCities(regionId);
    setState(() {});
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _pickImage(ImageSource source, {bool isProfile = true}) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          _profileImage = File(pickedFile.path);
        } else {
          _galleryImages.add(File(pickedFile.path));
        }
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    String fileName = Uuid().v4();
    Reference storageRef = FirebaseStorage.instance.ref().child('shops/$fileName');
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() => null);
    return await storageSnapshot.ref.getDownloadURL();
  }

  Future<void> _loadShopIfExists() async {
    // Fetch the current user's shop data from Firestore
    final shopDoc = await FirebaseFirestore.instance
        .collection('shops')
        .where('ownerId', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get();

    if (shopDoc.docs.isNotEmpty) {
      final shopData = shopDoc.docs.first.data();
      setState(() {
        nameController.text = shopData['name'] ?? '';
        selectedRegionId = shopData['region'];
        selectedCityId = shopData['city'];
        phoneNumberController.text = shopData['phoneNumber'] ?? '';
        descriptionController.text = shopData['description'] ?? '';
        servicesController.text = (shopData['services'] as List).join(', ') ?? '';
        workingHours = (shopData['workingHours'] as Map<String, dynamic>).map(
          (day, hours) => MapEntry(day, WorkingHours.fromMap(hours)),
        );
        isEditMode = true;
      });
      if (selectedRegionId != null) {
        await _fetchCities(selectedRegionId!);
      }
    }
  }

  Future<void> _createOrEditShop() async {
    if (_formKey.currentState!.validate() && _validateWorkingHours()) {
      String? profileImageUrl;
      List<String> galleryImageUrls = [];

      if (_profileImage != null) {
        profileImageUrl = await _uploadImage(_profileImage!);
      }

      for (File image in _galleryImages) {
        String imageUrl = await _uploadImage(image);
        galleryImageUrls.add(imageUrl);
      }

      final shopData = {
    'name': nameController.text,
    'regionId': selectedRegionId,
    'regionName': regions.firstWhere((r) => r.regionId == selectedRegionId).name,
    'cityId': selectedCityId,
    'cityName': cities.firstWhere((c) => c.id == selectedCityId).name,
    'phoneNumber': phoneNumberController.text,
    'workingHours': workingHours.map((day, hours) => MapEntry(day, hours.toMap())),
    'description': descriptionController.text,
    'services': servicesController.text.split(',').map((e) => e.trim()).toList(),
    'ownerId': FirebaseAuth.instance.currentUser!.email,
    'profileImageUrl': profileImageUrl,
    'galleryImageUrls': galleryImageUrls,
    'location': _currentPosition != null ? GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude) : null,
};      

      if (isEditMode) {
        // Update the existing shop document
        final shopDoc = await FirebaseFirestore.instance
            .collection('shops')
            .where('ownerId', isEqualTo: FirebaseAuth.instance.currentUser!.email)
            .get();
        await FirebaseFirestore.instance.collection('shops').doc(shopDoc.docs.first.id).update(shopData);
        Get.snackbar('Success', 'Shop updated successfully');
      } else {
        // Create a new shop document
        await FirebaseFirestore.instance.collection('shops').add(shopData);
        Get.snackbar('Success', 'Shop created successfully');
      }

      // Get.offAll(() => ShopDetailsPage(ownerId: FirebaseAuth.instance.currentUser!.email!));
    }
  }

  bool _validateWorkingHours() {
    bool isValid = true;
    workingHours.forEach((day, hours) {
      if ((hours.open.isNotEmpty && hours.close.isEmpty) || (hours.open.isEmpty && hours.close.isNotEmpty)) {
        isValid = false;
      }
    });
    if (!isValid) {
      Get.snackbar('Error', 'Please select both open and close times for each day that has one of them filled.');
    }
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Shop' : 'Create Shop', style: AppTheme.textTheme.headlineMedium!.copyWith(color: AppTheme.darkBackground)),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            children: [
              _buildImagePicker(),
              const SizedBox(height: 30),
              _buildTextField(nameController, 'Business Name'),
              _buildRegionDropdown(),
              _buildCityDropdown(),
              _buildTextField(phoneNumberController, 'Business Phone Number', keyboardType: TextInputType.phone),
              _buildTextField(descriptionController, 'Bio', maxLines: 3),
              _buildTextField(servicesController, 'Services (comma-separated)'),
              const SizedBox(height: 20),
              Text('Working Hours', style: AppTheme.textTheme.headlineSmall),
              SizedBox(height: 10),
              _buildWorkingHoursInput(),
              const SizedBox(height: 20),
              // _buildLocationButton(),
              const SizedBox(height: 20),
              _buildGalleryImagePicker(),
              const SizedBox(height: 20),
              _buildCreateOrEditShopButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () => _pickImage(ImageSource.gallery),
      child: CircleAvatar(
        radius: 60,
        backgroundColor: AppTheme.button,
        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
        child: _profileImage == null
            ? const Icon(Icons.camera_alt, size: 40, color: AppTheme.background)
            : null,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTheme.textTheme.bodyLarge!.copyWith(color: AppTheme.darkBackground),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.darkBackground),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRegionDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: selectedRegionId,
          hint: Text('Select Region', style: AppTheme.textTheme.bodyLarge),
          onChanged: (String? newValue) {
            setState(() {
              selectedRegionId = newValue;
              selectedCityId = null;
              cities = [];
              if (selectedRegionId != null) {
                _fetchCities(selectedRegionId!);
              }
            });
          },
          items: regions.map((RegionModel region) {
            return DropdownMenuItem<String>(
              value: region.regionId,
              child: Text(region.name),
            );
          }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.darkBackground),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a region';
            }
            return null;
          },
          menuMaxHeight: 200, // Set a fixed height to make it scrollable
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: selectedCityId,
          hint: Text('Select City', style: AppTheme.textTheme.bodyLarge),
          onChanged: (String? newValue) {
            setState(() {
              selectedCityId = newValue;
            });
          },
          items: cities.map((CityModel city) {
            return DropdownMenuItem<String>(
              value: city.id,
              child: Text(city.name),
            );
          }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.darkBackground),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a city';
            }
            return null;
          },
          menuMaxHeight: 200, // Set a fixed height to make it scrollable
        ),
      ),
    );
  }

  // Widget _buildLocationButton() {
  //   return ElevatedButton.icon(
  //     icon: const Icon(Icons.location_on),
  //     label: Text('Get Location', style: AppTheme.textTheme.bodyLarge!.copyWith(color: AppTheme.background)),
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: AppTheme.button,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //       minimumSize: const Size.fromHeight(50),
  //     ),
  //     onPressed: _getLocation,
  //   );
  // }

  Widget _buildGalleryImagePicker() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add_photo_alternate),
          label: Text('Add Gallery Images', style: AppTheme.textTheme.bodyLarge!.copyWith(color: AppTheme.background)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.button,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: () => _pickImage(ImageSource.gallery, isProfile: false),
        ),
        const SizedBox(height: 10),
        Visibility(
          visible: _galleryImages.isNotEmpty,
          child: SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _galleryImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Image.file(_galleryImages[index]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateOrEditShopButton() {
    return ElevatedButton(
      onPressed: _createOrEditShop,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.button,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size.fromHeight(50),
      ),
      child: Text(isEditMode ? 'Update Shop' : 'Create Shop', style: AppTheme.textTheme.bodyLarge!.copyWith(color: AppTheme.background)),
    );
  }

  Widget _buildWorkingHoursInput() {
    return Table(
      border: TableBorder.all(color: AppTheme.darkBackground),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          children: [
            _buildCenteredTableCell('Day'),
            _buildCenteredTableCell('Open'),
            _buildCenteredTableCell('Close'),
          ],
        ),
        ...workingHours.keys.map((day) {
          return TableRow(
            children: [
              _buildCenteredTableCell(day),
              _buildTimePickerCell(day, isOpen: true),
              _buildTimePickerCell(day, isOpen: false),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCenteredTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          text,
          style: AppTheme.textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildTimePickerCell(String day, {required bool isOpen}) {
    return TextButton(
      onPressed: () async {
        TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        setState(() {
          if (selectedTime != null) {
            if (isOpen) {
              workingHours[day] = WorkingHours(
                open: selectedTime.format(context),
                close: workingHours[day]!.close,
              );
            } else {
              workingHours[day] = WorkingHours(
                open: workingHours[day]!.open,
                close: selectedTime.format(context),
              );
            }
          } else {
            if (isOpen) {
              workingHours[day] = WorkingHours(open: '', close: workingHours[day]!.close);
            } else {
              workingHours[day] = WorkingHours(open: workingHours[day]!.open, close: '');
            }
          }
        });
      },
      child: Text(
        isOpen ? (workingHours[day]!.open.isNotEmpty ? workingHours[day]!.open : '00:00') 
               : (workingHours[day]!.close.isNotEmpty ? workingHours[day]!.close : '00:00'),
        style: AppTheme.textTheme.bodyLarge!.copyWith(color: AppTheme.darkBackground),
      ),
    );
  }
}

class WorkingHours {
  String open;
  String close;

  WorkingHours({required this.open, required this.close});

  Map<String, String> toMap() {
    return {
      'open': open,
      'close': close,
    };
  }

  factory WorkingHours.fromMap(Map<String, dynamic> map) {
    return WorkingHours(
      open: map['open'] ?? '',
      close: map['close'] ?? '',
    );
  }
}
