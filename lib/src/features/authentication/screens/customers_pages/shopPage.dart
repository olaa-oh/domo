import 'package:flutter/material.dart';
import 'package:domo/src/constants/shop_model.dart';
import 'package:domo/src/auth_repository/shopRepository.dart';
import 'package:domo/src/constants/style.dart';
import 'package:domo/src/constants/user_model.dart';
import 'package:domo/src/auth_repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:domo/src/constants/booking_model.dart';
import 'package:domo/src/auth_repository/booking_repository.dart';

class ShopPage extends StatefulWidget {
  final String shopId;
  final UserModel? userModel;

  const ShopPage({Key? key, required this.shopId, this.userModel})
      : super(key: key);

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final ShopRepository _shopRepository = ShopRepository();
  final UserRespository _userRepository = UserRespository.instance;
  final BookingRepository _bookingRepository = BookingRepository();
  late Future<void> _initFuture;
  bool _isLiked = false;
  late ShopModel _shop;
  late UserModel _userModel;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    if (widget.userModel != null) {
      _userModel = widget.userModel!;
    } else {
      // Fetch the current user's data
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        UserModel? user = await _userRepository.getUser(firebaseUser.email!);
        if (user != null) {
          _userModel = user;
        } else {
          throw Exception('User not found');
        }
      } else {
        throw Exception('No user logged in');
      }
    }
    await _loadShopAndStatus();
  }

  Future<void> _loadShopAndStatus() async {
    ShopModel? shop = await _shopRepository.getShopById(widget.shopId);
    if (shop != null) {
      _shop = shop;
      _isLiked = await _shopRepository.isShopLikedByUser(
          widget.shopId, _userModel.email);
      
      // Get the actual bookings count
      int bookingsCount = await _bookingRepository.getBookingsCountForShop(widget.shopId);
      
      // Update the shop's booked count if it's different
      if (bookingsCount != _shop.booked) {
        await _shopRepository.updateShopBookedCount(widget.shopId, bookingsCount);
        _shop = _shop.copyWith(booked: bookingsCount);
      }
    } else {
      throw Exception('Shop not found');
    }
  }

  Future<void> _refreshShop() async {
    await _loadShopAndStatus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Shop Details', style: AppTheme.textTheme.headlineSmall),
            actions: [
                 ElevatedButton(
                onPressed: _createBooking,
                child: Text('Book'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: AppTheme.button,
                ),
              ),   
              IconButton(
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? AppTheme.button : null,
                ),
                onPressed: _toggleLike,
              ),


            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshShop,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppTheme.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShopHeader(),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.border),
                  _buildSectionTitle('Description'),
                  Text(_shop.description, style: AppTheme.textTheme.bodyMedium),
                  const Divider(color: AppTheme.border),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Services'),
                  _buildServicesList(_shop.services),
                  const Divider(color: AppTheme.border),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Working Hours'),
                  _buildWorkingHours(_shop.workingHours),
                  const Divider(color: AppTheme.border),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Gallery'),
                  _buildGallery(_shop.galleryImageUrls),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShopHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileImage(_shop.profileImageUrl),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_shop.name,
                  style: AppTheme.textTheme.headlineMedium!
                      .copyWith(color: AppTheme.button)),
              const SizedBox(height: 8),
              _buildInfoRow(
                  Icons.location_on, '${_shop.cityName}, ${_shop.regionName}'),
              const SizedBox(height: 4),
              _buildInfoRow(Icons.phone, _shop.phoneNumber, isPhoneNumber: true),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.favorite, color: AppTheme.button, size: 20),
                  const SizedBox(width: 4),
                  Text('${_shop.likes} likes',
                      style: AppTheme.textTheme.bodyMedium),
                  const SizedBox(width: 8),
                  const Icon(Icons.bookmark, color: AppTheme.button, size: 20),
                  const SizedBox(width: 4),
                  Text('${_shop.booked} bookings',
                      style: AppTheme.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(String url) {
    return CircleAvatar(
      radius: 50,
      backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
      child: url.isEmpty
          ? const Icon(Icons.store, size: 50, color: AppTheme.icon)
          : null,
      backgroundColor: AppTheme.background,
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isPhoneNumber = false}) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.icon, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: isPhoneNumber
              ? GestureDetector(
                  onTap: () => _launchPhoneDialer(text),
                  child: Text(
                    text,
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.button,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              : Text(text, style: AppTheme.textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style:
              AppTheme.textTheme.titleLarge?.copyWith(color: AppTheme.button)),
    );
  }

  Widget _buildServicesList(List<String> services) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: services
          .map((service) => Chip(
                label:
                    Text('# ${service}', style: AppTheme.textTheme.bodySmall),
                backgroundColor: AppTheme.button.withOpacity(0.1),
              ))
          .toList(),
    );
  }

  Widget _buildWorkingHours(Map<String, WorkingHours> workingHours) {
    return Column(
      children: workingHours.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.key, style: AppTheme.textTheme.bodyMedium),
              Text('${entry.value.open} - ${entry.value.close}',
                  style: AppTheme.textTheme.bodyMedium),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGallery(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppTheme.button.withOpacity(0.1),
          borderRadius: AppTheme.cardRadius,
        ),
        child: Center(
          child: Text(
            'Gallery Images',
            style:
                AppTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.button),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: AppTheme.cardRadius,
              child: Image.network(
                imageUrls[index],
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _toggleLike() async {
    bool result = await _shopRepository.toggleShopLike(widget.shopId, _userModel.email);
    setState(() {
      _isLiked = result;
      if (_isLiked) {
        _shop = _shop.copyWith(likes: _shop.likes + 1);
      } else {
        _shop = _shop.copyWith(likes: _shop.likes - 1);
      }
    });
    await _updateFavorites();
  }

  void _launchPhoneDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: "tel", path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print("Cannot launch phone dialer");
    }
  }

  Future<void> _updateFavorites() async {
    if (_isLiked) {
      await _shopRepository.addShopToFavorites(_userModel.email, _shop);
    } else {
      await _shopRepository.removeShopFromFavorites(_userModel.email, _shop.id);
    }
  }

  Future<void> _createBooking() async {
    // Show date picker
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );

    if (pickedDate != null) {
      // Show time picker
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 9, minute: 0),
      );

      if (pickedTime != null) {
        // Combine date and time
        final DateTime bookingDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Create booking
        final newBooking = Booking(
          id: '', 
          shopId: widget.shopId,
          userEmail: _userModel.email,
          ownerId: _shop.ownerId,
          shopName: _shop.name,
          bookingDate: bookingDateTime,
          status: BookingStatus.pending,
        );

        try {
          await _bookingRepository.createBooking(newBooking);
          
          // After successful booking creation, update the bookings count
          int newBookingsCount = await _bookingRepository.getBookingsCountForShop(widget.shopId);
          await _shopRepository.updateShopBookedCount(widget.shopId, newBookingsCount);
          
          setState(() {
            _shop = _shop.copyWith(booked: newBookingsCount);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking created successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating booking: $e')),
          );
        }
      }
    }
  }
}