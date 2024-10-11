import 'package:flutter/material.dart';
import 'package:domo/src/features/authentication/model/shop_model.dart';
import 'package:domo/src/features/authentication/model/style_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopCard extends StatelessWidget {
  final ShopModel shop;
  final VoidCallback onTap;

  const ShopCard({Key? key, required this.shop, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: AppTheme.cardRadius),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppTheme.cardPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileImage(shop.profileImageUrl),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            shop.name,
                            style: AppTheme.textTheme.titleLarge!.copyWith(
                              color: AppTheme.button,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildLikeBookmarkStream(shop.id),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${shop.cityName}, ${shop.regionName}',
                      style: AppTheme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildServicesList(shop.services),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(String url) {
    return CircleAvatar(
      radius: 30,
      backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
      child: url.isEmpty
          ? const Icon(Icons.store, size: 30, color: AppTheme.icon)
          : null,
      backgroundColor: AppTheme.background,
    );
  }

  Widget _buildLikeBookmarkStream(String shopId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('shops').doc(shopId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final shopData = snapshot.data!.data() as Map<String, dynamic>?;
          final likes = shopData?['likes'] ?? 0;
          final booked = shopData?['booked'] ?? 0;
          return Row(
            children: [
              Icon(Icons.favorite, color: AppTheme.button, size: 20),
              SizedBox(width: 4),
              Text('$likes', style: AppTheme.textTheme.bodySmall),
              const SizedBox(width: 8),
              Icon(Icons.bookmark, color: AppTheme.button, size: 20),
              SizedBox(width: 4),
              Text('$booked', style: AppTheme.textTheme.bodySmall),
            ],
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildServicesList(List<String> services) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: services.take(3).map((service) => Chip(
        label: Text('# ${service}', style: AppTheme.textTheme.labelSmall),
        backgroundColor: AppTheme.button.withOpacity(0.3),
      )).toList(),
    );
  }
}