import 'package:domo/src/features/shop/view/shopPage.dart';
import 'package:flutter/material.dart';
import 'package:domo/src/features/authentication/model/shop_model.dart';
import 'package:domo/src/data/auth_repository/shopRepository.dart';
import 'package:domo/src/features/authentication/model/style_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopsPage extends StatefulWidget {
  const ShopsPage({Key? key}) : super(key: key);

  @override
  _ShopsPageState createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> {
  final ShopRepository _shopRepository = ShopRepository();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<ShopModel> _shops = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  String _errorMessage = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadMoreShops();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreShops();
    }
  }

  Future<void> _loadMoreShops() async {
    if (!_isLoading && _hasMore && !_isSearching) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final result = await _shopRepository.getAllShops(startAfter: _lastDocument);
        final List<ShopModel> newShops = result.shops;
        final DocumentSnapshot? lastDoc = result.lastDocument;

        setState(() {
          _isLoading = false;
          if (newShops.isNotEmpty) {
            _shops.addAll(newShops);
            _lastDocument = lastDoc;
          } else {
            _hasMore = false;
          }
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load shops. Please try again.';
        });
      }
    }
  }

  Future<void> _searchShops(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _shops = [];
        _hasMore = true;
        _lastDocument = null;
      });
      _loadMoreShops();
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final searchResults = await _shopRepository.searchShops(query);
      setState(() {
        _shops = searchResults;
        _isLoading = false;
        _hasMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to search shops. Please try again.';
      });
    }
  }

  Future<void> _refreshShops() async {
    setState(() {
      _shops = [];
      _lastDocument = null;
      _hasMore = true;
    });
    await _loadMoreShops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: AppTheme.button,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search shops by name, region, city, or service',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppTheme.button.withOpacity(0.5)),
          ),
          style: TextStyle(color: AppTheme.button),
          onChanged: (value) {
            _searchShops(value);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear, color: AppTheme.button),
            onPressed: () {
              _searchController.clear();
              _searchShops('');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshShops,
        child: _errorMessage.isNotEmpty
            ? Center(child: Text(_errorMessage))
            : _shops.isEmpty && _isLoading
                ? Center(child: CircularProgressIndicator())
                : _shops.isEmpty
                    ? Center(child: Text('No shops found'))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _shops.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _shops.length) {
                            return _buildLoaderListItem();
                          }
                          return _buildShopCard(_shops[index]);
                        },
                      ),
      ),
    );
  }

  Widget _buildShopCard(ShopModel shop) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: AppTheme.cardRadius),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShopPage(shopId: shop.id),
            ),
          );
        },
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
                          child: Text(shop.name, style: AppTheme.textTheme.titleLarge!.copyWith(color: AppTheme.button, fontWeight: FontWeight.bold)),
                        ),
                        _buildLikeBookmarkStream(shop.id),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${shop.cityName}, ${shop.regionName}', style: AppTheme.textTheme.bodyMedium),
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

  Widget _buildLoaderListItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListTile(
        leading: CircleAvatar(radius: 30),
        title: Container(height: 16, color: Colors.white),
        subtitle: Container(height: 16, color: Colors.white),
      ),
    );
  }
}