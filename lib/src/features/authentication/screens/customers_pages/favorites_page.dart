import 'package:flutter/material.dart';
import 'package:domo/src/constants/shop_model.dart';
import 'package:domo/src/constants/style.dart';
import 'package:domo/src/auth_repository/shopRepository.dart';
import 'package:domo/src/widgets/shopCard.dart';
import 'package:domo/src/features/authentication/screens/customers_pages/shopPage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final ShopRepository _shopRepository = ShopRepository();
  List<ShopModel> _likedShops = [];
  bool _isLoading = true;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _loadLikedShops();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _loadLikedShops() async {
    if (!_isMounted) return;

    setState(() {
      _isLoading = true;
    });

    String userId = FirebaseAuth.instance.currentUser?.email ?? '';
    List<ShopModel> shops = await _shopRepository.getLikedShops(userId);

    if (_isMounted) {
      setState(() {
        _likedShops = shops;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: AppTheme.button,
      appBar: AppBar(
        title: Text('Favorites', style: AppTheme.textTheme.headlineSmall),
      ),
      body: RefreshIndicator(
        onRefresh: _loadLikedShops,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _likedShops.isEmpty
                ? Center(child: Text('No favorite shops yet'))
                : ListView.builder(
                    itemCount: _likedShops.length,
                    itemBuilder: (context, index) {
                      return ShopCard(
                        shop: _likedShops[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShopPage(shopId: _likedShops[index].id),
                            ),
                          ).then((_) {
                            if (_isMounted) {
                              _loadLikedShops();
                            }
                          });
                        },
                      );
                    },
                  ),
      ),
    );
  }
}