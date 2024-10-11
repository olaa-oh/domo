import 'package:flutter/material.dart';
import 'package:domo/src/features/authentication/model/style_model.dart';
import 'package:get/get.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: AppTheme.darkBackground),
                    onPressed: () => Get.back(),
                  ),
                  Text(
                    'Terms of Use',
                    style: AppTheme.textTheme.headlineSmall!.copyWith(
                      color: AppTheme.darkBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('1. Acceptance of Terms'),
                    _buildSectionContent(
                      'By using our artisan-customer connection app, you agree to these Terms of Use. If you do not agree, please do not use the app.',
                    ),
                    _buildSectionTitle('2. Description of Service'),
                    _buildSectionContent(
                      'Our app connects customers with skilled artisans in various fields such as plumbing, electrical work, carpentry, painting, and more. We provide a platform for artisans to showcase their skills and for customers to find and hire them. However, we do not employ the artisans and are not responsible for the quality of their work.',
                    ),
                    _buildSectionTitle('3. User Accounts'),
                    _buildSectionContent(
                      'You must create an account to use our service. You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account. For artisans, you agree to provide accurate and up-to-date information about your skills, experience, and availability.',
                    ),
                    _buildSectionTitle('4. User Conduct'),
                    _buildSectionContent(
                      'You agree not to use the app for any unlawful purpose or in any way that interrupts, damages, or impairs the service. This includes but is not limited to: harassing other users, posting false information, or attempting to access other users\' accounts.',
                    ),
                    _buildSectionTitle('5. Artisan Listings and Reviews'),
                    _buildSectionContent(
                      'We strive to provide accurate information about artisans, but we do not guarantee the accuracy, completeness, or quality of any artisan\'s work. Customers are encouraged to review artisan profiles, including ratings and reviews, before hiring. Customers can leave reviews after a job is completed. We reserve the right to remove reviews that violate our guidelines.',
                    ),
                    _buildSectionTitle('6. Booking and Payments'),
                    _buildSectionContent(
                      'When a customer books an artisan through our app, they agree to pay the specified rate. All payments are processed through secure third-party payment providers. We do not store your payment information. Artisans agree to complete the work as described in the booking. Any disputes should be reported to our customer service team.',
                    ),
                    _buildSectionTitle('7. Cancellations and Refunds'),
                    _buildSectionContent(
                      'Cancellation policies may vary depending on the artisan and the type of service. These will be clearly stated at the time of booking. Refunds, if applicable, will be processed according to our refund policy, which can be found in our Help Center.',
                    ),
                    _buildSectionTitle('8. Liability'),
                    _buildSectionContent(
                      'While we strive to maintain a high-quality platform, we are not responsible for the actions or negligence of artisans or customers using our app. Users agree to hold us harmless from any claims arising from interactions between artisans and customers.',
                    ),
                    _buildSectionTitle('9. Termination'),
                    _buildSectionContent(
                      'We reserve the right to terminate or suspend your account at our sole discretion, without notice, for conduct that we believe violates these Terms of Use or is harmful to other users, us, or third parties, or for any other reason.',
                    ),
                    _buildSectionTitle('10. Changes to Terms'),
                    _buildSectionContent(
                      'We reserve the right to modify these Terms of Use at any time. We will notify users of any significant changes via email or through the app.',
                    ),
                    _buildSectionTitle('11. Contact Information'),
                    _buildSectionContent(
                      'If you have any questions about these Terms of Use or need to report an issue, please contact our support team at support@artisanconnect.com or through the Help section in the app.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Text(
        title,
        style: AppTheme.textTheme.titleMedium!.copyWith(
          color: AppTheme.darkBackground,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: AppTheme.textTheme.bodyMedium!.copyWith(
        color: AppTheme.darkBackground.withOpacity(0.8),
      ),
    );
  }
}
