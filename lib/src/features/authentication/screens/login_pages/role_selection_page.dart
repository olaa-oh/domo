import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:domo/src/constants/style.dart';
import 'package:domo/src/features/authentication/screens/login_pages/create_account.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Container(
                height: 100,
                width: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.background,
                  image: DecorationImage(
                    image: AssetImage('assets/images/domoologo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Choose Your Role",
                  style: AppTheme.textTheme.titleMedium!.copyWith(
                    fontSize: 27,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Select the role that best describes you",
                textAlign: TextAlign.center,
                style: AppTheme.textTheme.bodyMedium!.copyWith(
                  color: AppTheme.button.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 60),
              _buildRoleButton(
                context: context,
                role: "Artisan",
                icon: Icons.build,
                description: "I provide services as an artisan",
              ),
              const SizedBox(height: 30),
              _buildRoleButton(
                context: context,
                role: "User",
                icon: Icons.person,
                description: "I'm looking for artisan services",
              ),
              const SizedBox(height: 60),
              // Text(
              //   "You can change your role later in settings",
              //   textAlign: TextAlign.center,
              //   style: AppTheme.textTheme.bodySmall!.copyWith(
              //     color: AppTheme.button.withOpacity(0.5),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required String role,
    required IconData icon,
    required String description,
  }) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(AppTheme.background),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppTheme.button),
          ),
        ),
      ),
      onPressed: () {
        // Navigate to SignUp page with the selected role
        // Get.to(() => SignUp(role: role));
      },
      child: Row(
        children: [
          Icon(icon, color: AppTheme.button, size: 30),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: AppTheme.textTheme.titleMedium!.copyWith(
                    color: AppTheme.button,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: AppTheme.textTheme.bodySmall!.copyWith(
                    color: AppTheme.button.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: AppTheme.button),
        ],
      ),
    );
  }
}