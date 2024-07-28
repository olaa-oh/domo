import 'package:domo/src/constants/user_model.dart';
import 'package:domo/src/features/authentication/controllers/create_account_controller.dart';
import 'package:domo/src/features/authentication/controllers/profile_controller.dart';
import 'package:domo/src/features/authentication/screens/allusers/profile/edit_account_page.dart';
import 'package:domo/src/features/authentication/screens/allusers/profile/favorites_page.dart';
import 'package:domo/src/features/authentication/screens/allusers/profile/notifications_page.dart';
import 'package:domo/src/features/authentication/screens/allusers/profile/terms_of_use_page.dart';
import 'package:domo/src/features/authentication/screens/login_pages/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:domo/src/constants/style.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final controller = Get.put(ProfileController());
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
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      children: [
        Row(
          children: [
            user?.imageUrl != null
                ? CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.button,
                    backgroundImage: NetworkImage(user!.imageUrl!),
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
              style: AppTheme.textTheme.headlineMedium!.copyWith(
                color: AppTheme.darkBackground,
                // fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // SizedBox(height: 20),
        // Divider(color: AppTheme.border.withOpacity(0.5)),
        const SizedBox(height: 50),
        _buildListTile(Icons.favorite, "Favorites"),
        _buildListTile(Icons.edit, "Edit Account"),
        _buildListTile(Icons.notifications, "Notifications"),
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
              case "Edit Account":
                Get.to(() => const EditAccountPage());
                break;
              case "Notifications":
                Get.to(() => const NotificationsPage());
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
