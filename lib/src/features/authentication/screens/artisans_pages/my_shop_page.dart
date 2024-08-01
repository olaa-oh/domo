import 'package:flutter/material.dart';
import 'package:domo/src/constants/shop_model.dart';
import 'package:domo/src/auth_repository/shopRepository.dart';
import 'package:domo/src/constants/style.dart';

class ShopDetailsPage extends StatefulWidget {
  final String ownerId;

  const ShopDetailsPage({Key? key, required this.ownerId}) : super(key: key);

  @override
  _ShopDetailsPageState createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage>
    with WidgetsBindingObserver {
  final ShopRepository _shopRepository = ShopRepository();
  late Future<ShopModel?> _shopFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshShopData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshShopData();
    }
  }

  Future<void> _refreshShopData() async {
    setState(() {
      _isLoading = true;
      _shopFuture = _shopRepository.getShopByOwnerId(widget.ownerId);
    });
    await _shopFuture;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: Text('Shop Details', style: AppTheme.textTheme.headlineSmall),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshShopData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<ShopModel?>(
                future: _shopFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${snapshot.error}'),
                          ElevatedButton(
                            onPressed: _refreshShopData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Shop not found or not created yet'),
                          const SizedBox(height: 16),
                          CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshShopData,
                            child: const Text('Reload'),
                          ),
                        ],
                      ),
                    );
                  }

                  ShopModel shop = snapshot.data!;
                  print('Shop data in widget: ${shop.toMap()}');
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppTheme.screenPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShopHeader(shop),
                        const SizedBox(height: 16),
                        const Divider(color: AppTheme.border),
                        _buildSectionTitle('Description'),
                        Text(shop.description, style: AppTheme.textTheme.bodyMedium),
                        const Divider(color: AppTheme.border),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Services'),
                        _buildServicesList(shop.services),
                        const Divider(color: AppTheme.border),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Working Hours'),
                        _buildWorkingHours(shop.workingHours),
                        const Divider(color: AppTheme.border),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Gallery'),
                        _buildGallery(shop.galleryImageUrls),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildShopHeader(ShopModel shop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileImage(shop.profileImageUrl),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(shop.name,
                  style: AppTheme.textTheme.headlineMedium!
                      .copyWith(color: AppTheme.button)),
              const SizedBox(height: 8),
              _buildInfoRow(
                  Icons.location_on, '${shop.cityName}, ${shop.regionName}'),
              const SizedBox(height: 4),
              _buildInfoRow(Icons.phone, shop.phoneNumber),
              Row(
                children: [
                  Icon(Icons.favorite, color: AppTheme.button, size: 20),
                  SizedBox(width: 4),
                  Text('${shop.likes}', style: AppTheme.textTheme.bodySmall),
                  const SizedBox(width: 8),
                  Icon(Icons.bookmark, color: AppTheme.button, size: 20),
                  SizedBox(width: 4),
                  Text('${shop.booked}', style: AppTheme.textTheme.bodySmall),
                ],
              )
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.icon, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTheme.textTheme.bodyMedium)),
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
}
