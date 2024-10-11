import 'package:domo/src/features/authentication/model/user_model.dart';
import 'package:domo/src/features/authentication/controllers/create_account_controller.dart';
import 'package:domo/src/features/authentication/controllers/profile_controller.dart';
import 'package:domo/src/features/authentication/view/edit_account_page.dart';
import 'package:domo/src/features/interactions/view/favorites_page.dart';
import 'package:domo/src/features/authentication/view/terms_of_use_page.dart';
import 'package:domo/src/features/authentication/view/accountArt.dart';
import 'package:domo/src/features/authentication/view/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:domo/src/features/authentication/model/style_model.dart';
import 'package:domo/src/data/auth_repository/authentication_repository.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final controller = Get.put(ProfileController());
  final authRepo = Get.find<AuthenticationRepository>();
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = controller.getUser();
  }

  Future<void> _refreshData() async {
    setState(() {
      _userFuture = controller.getUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: FutureBuilder<UserModel?>(
            future: _userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else {
                UserModel? user = snapshot.data;
                return _buildProfileContent(user);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(UserModel? user) {
    bool isArtisan = user?.role?.toLowerCase() == 'artisan';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      children: [
        Row(
          children: [
            user?.imageUrl != null && user!.imageUrl!.isNotEmpty
                ? CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.button,
                    backgroundImage: NetworkImage(user.imageUrl!),
                  )
                : const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.button,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppTheme.background,
                    ),
                  ),
            const SizedBox(width: 20),
            Text(
              "Hello, ${user?.name ?? 'User'}",
              softWrap: true,
              style: AppTheme.textTheme.headlineMedium!.copyWith(
                color: AppTheme.darkBackground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 50),
        _buildListTile(
          isArtisan ? Icons.store : Icons.favorite,
          isArtisan ? "Shop" : "Favorites",
        ),
        _buildListTile(Icons.edit, "Edit Account"),
        _buildListTile(Icons.description, "Terms of Use"),
        const SizedBox(height: 120),
        Center(child: _buildLogoutButton()),
      ],
    );
  }

  Widget _buildListTile(IconData icon, String title) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppTheme.button),
          title: Text(
            title,
            style: AppTheme.textTheme.titleMedium!
                .copyWith(color: AppTheme.darkBackground, fontSize: 20),
          ),
          trailing: const Icon(Icons.arrow_forward_ios,
              color: AppTheme.button, size: 18),
          onTap: () {
            switch (title) {
              case "Favorites":
                Get.to(() => const FavoritesPage());
                break;
              case "Shop":
                Get.to(() => CreateShopPage());
                break;
              case "Edit Account":
                Get.to(() => const EditAccountPage());
                break;
              case "Terms of Use":
                Get.to(() => const TermsOfUsePage());
                break;
            }
            print("Navigating to $title");
          },
        ),
        Divider(color: AppTheme.border.withOpacity(0.5)),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(AppTheme.button),
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      onPressed: () async {
        await CreateAccountController.instance.signOut();
        Get.offAll(() => const Login());
      },
      child: Text(
        'Logout',
        style: AppTheme.textTheme.titleMedium!.copyWith(
          color: AppTheme.background,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
